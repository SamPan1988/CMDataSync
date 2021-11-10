//
//  CMSyncSendManager.m
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/3.
//

#import "CMSyncTCPConnectManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "CMDataSyncTool.h"

@interface CMSyncTCPConnectManager()<GCDAsyncSocketDelegate>
/// 当前网络连接状态
@property (nonatomic, assign) CMSyncConnectStatus connectStatus;
@property (nonatomic, strong) id <CMSyncResolveProtocol> resolveDelegate;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, strong) GCDAsyncSocket *listeningSocket;
@property (nonatomic, strong) NSString *senderAdress;

@property (nonatomic, strong) NSMutableDictionary *currentWrittingDataDict;
@property (nonatomic, strong) NSMutableDictionary *currentReadBufferDict;

@property (nonatomic, strong) dispatch_queue_t delegateQueue;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@end

@implementation CMSyncTCPConnectManager

- (NSMutableDictionary *) currentWrittingDataDict {
    if (!_currentWrittingDataDict) {
        _currentWrittingDataDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _currentWrittingDataDict;
}

- (NSMutableDictionary *) currentReadBufferDict {
    if (!_currentReadBufferDict) {
        _currentReadBufferDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _currentReadBufferDict;
}

- (dispatch_queue_t) delegateQueue {
    if (!_delegateQueue) {
        _delegateQueue = dispatch_queue_create("com.delegateQueue.CMSynConnect", DISPATCH_QUEUE_SERIAL);
    }
    return _delegateQueue;
}

+ (instancetype) shared {
    dispatch_once_t CMTcpConnectToken;
    static CMSyncTCPConnectManager *shared;
    dispatch_once(&CMTcpConnectToken, ^{
        shared = [[CMSyncTCPConnectManager alloc] init];
    });
    return shared;
}

- (void) startConnectWithHost:(NSString *) host
                         port:(uint16_t) port
              resolveProtocol:(id <CMSyncResolveProtocol> ) resolveProtocol {
    dispatch_async(self.delegateQueue, ^{
        if (self.socket && self.socket.isConnected) {
            NSError *error = [NSError errorWithDomain:@"CMDataSync: Connection already exists.\n" code:kCMSyncErrorCodeConnected userInfo:nil];
            self.connectStatus = CMSyncConnectStatusConnectError;
            [resolveProtocol didReceiveConnectStatus:CMSyncConnectStatusConnectError error:error];
            return;
        }
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
        NSError *error;
        self.connectStatus = CMSyncConnectStatusConnecting;
        [self.socket connectToHost:host onPort:port withTimeout:-1 error:&error];
        if (error) {
            self.connectStatus = CMSyncConnectStatusConnectError;
            [resolveProtocol didReceiveConnectStatus:CMSyncConnectStatusConnectError error:error];
            return;
        }
        self.host = host;
        self.port = port;
        self.resolveDelegate = resolveProtocol;
    });
}

- (NSString *) startWaitingForConnectOnPort:(uint16_t) port
                            resolveProtocol:(id <CMSyncResolveProtocol>) resolveProtocol {
    NSString *selfAdress;
    __block NSError *innerError;
    dispatch_sync(self.delegateQueue, ^{
        if (self.socket && self.socket.isConnected) {
            NSError *reconnectError = [NSError errorWithDomain:@"CMDataSync: Connection already exists.\n" code:kCMSyncErrorCodeConnected userInfo:nil];
            self.connectStatus = CMSyncConnectStatusConnectError;
            [resolveProtocol didReceiveConnectStatus:CMSyncConnectStatusConnectError error:reconnectError];
            innerError = reconnectError;
            return;
        }
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
        self.connectStatus = CMSyncConnectStatusConnectWaiting;
        [self.socket acceptOnPort:port error:&innerError];
    });
    if (innerError) {
        self.connectStatus = CMSyncConnectStatusConnectError;
        [resolveProtocol didReceiveConnectStatus:CMSyncConnectStatusConnectError error:innerError];
        return selfAdress;
    }
    self.port = port;
    self.resolveDelegate = resolveProtocol;
    selfAdress = [CMDataSyncTool getCurrentMachineIpAddress];
    NSMutableData *readBuffer = [[NSMutableData alloc] init];
    self.currentReadBufferDict[@(kCMListenInitialTag)] = readBuffer;
    [self.socket readDataWithTimeout:-1 buffer:readBuffer bufferOffset:0 tag:kCMListenInitialTag];
    return selfAdress;
}

- (void) stopConnect:(CMSyncDisconnectOption) option {
    dispatch_async(self.delegateQueue, ^{
        [self.socket setDelegate:nil delegateQueue:NULL];
        if (option == CMSyncDisconnectOptionPendingNone ) {
            [self.socket disconnect];
        } else if (option == CMSyncDisconnectOptionPendingSend) {
            [self.socket disconnectAfterWriting];
        } else if (option == CMSyncDisconnectOptionPendingReceive) {
            [self.socket disconnectAfterReading];
        } else if (option == (CMSyncDisconnectOptionPendingSend | CMSyncDisconnectOptionPendingReceive)) {
            [self.socket disconnectAfterReadingAndWriting];
        }
        self.socket = nil;
        self.listeningSocket = nil;
        self.host = nil;
        self.port = 0;
        [self.resolveDelegate didReceiveConnectStatus:CMSyncConnectStatusDisconnect error:nil];
        self.resolveDelegate = nil;
        self.connectStatus = CMSyncConnectStatusIdle;
    });
}

- (void) sendData:(NSData *) data tag:(NSUInteger) tag {
    dispatch_async(self.delegateQueue, ^{
        if (!self.socket || !self.socket.isConnected) { return;}
        //一读一写是相对的
        NSMutableData *readBuffer = [[NSMutableData alloc] init];
        self.currentReadBufferDict[@(tag)] = readBuffer;
        [self.socket readDataWithTimeout:-1 buffer:readBuffer bufferOffset:0 tag:tag];
        self.currentWrittingDataDict[@(tag)] = data;
        [self.socket writeData:data withTimeout:10 tag:tag];
    });
}

//MARK: - Connect delegate method
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self.connectStatus = CMSyncConnectStatusConnected;
    [self.resolveDelegate didReceiveConnectStatus:self.connectStatus error:nil];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self.connectStatus = CMSyncConnectStatusDisconnect;
    [self.resolveDelegate didReceiveConnectStatus:self.connectStatus error:err];
}

// MARK: - Send delegate method
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSData *data = self.currentWrittingDataDict[@(tag)];
    [self.resolveDelegate sendedLength:data.length tag:tag transmitStatus:CMSyncTransmitStatusComplete];
    //clean data reference
    self.currentWrittingDataDict[@(tag)] = nil;
}


- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    [self.resolveDelegate sendedLength:partialLength tag:tag transmitStatus:CMSyncTransmitStatusSending];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock
    shouldTimeoutWriteWithTag:(long)tag
                    elapsed:(NSTimeInterval)elapsed
                bytesDone:(NSUInteger)length {
    [self.resolveDelegate sendedLength:length tag:tag transmitStatus:CMSyncTransmitStatusTimeout];
    //clean data reference
    self.currentWrittingDataDict[@(tag)] = nil;
    return 0;
}

// MARK: - Receive delegate method
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    self.listeningSocket = newSocket;
    self.senderAdress = self.listeningSocket.connectedHost;
    self.connectStatus = CMSyncConnectStatusConnected;
    [self.resolveDelegate didReceiveConnectStatus:self.connectStatus error:nil];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSMutableData *dataBuffer = self.currentReadBufferDict[@(tag)];
    [self.resolveDelegate resolveReceivedData:dataBuffer
                                      address:self.senderAdress
                                receiveLength:dataBuffer.length
                                          tag:tag transmitStatus:CMSyncTransmitStatusComplete];
    self.currentReadBufferDict[@(tag)] = nil;
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSMutableData *dataBuffer = self.currentReadBufferDict[@(tag)];
    [self.resolveDelegate resolveReceivedData:dataBuffer
                                      address:self.senderAdress
                                receiveLength:partialLength
                                          tag:tag
                               transmitStatus:CMSyncTransmitStatusSending];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    NSMutableData *dataBuffer = self.currentReadBufferDict[@(tag)];
    [self.resolveDelegate resolveReceivedData:dataBuffer
                                      address:self.senderAdress
                                receiveLength:length
                                          tag:tag
                               transmitStatus:CMSyncTransmitStatusTimeout];
    self.currentReadBufferDict[@(tag)] = nil;
    return 0;
}



@end
    
