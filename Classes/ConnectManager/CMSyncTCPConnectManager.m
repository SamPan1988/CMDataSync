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

@property (nonatomic, strong) NSData *firstResponseEndData;
@property (nonatomic, assign) NSUInteger firstResponseLength;

@property (nonatomic, strong) NSMutableDictionary *currentWrittingDataDict;
@property (nonatomic, strong) NSMutableDictionary *currentReadBufferDict;

@property (nonatomic, strong) NSMutableDictionary *currentSendLengthDict;
@property (nonatomic, strong) NSMutableDictionary *currentReceiveLengthDict;

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

- (NSMutableDictionary *) currentSendLengthDict {
    if (!_currentSendLengthDict) {
        _currentSendLengthDict = [[NSMutableDictionary alloc] init];
    }
    return _currentSendLengthDict;
}

- (NSMutableDictionary *) currentReceiveLengthDict {
    if (!_currentReceiveLengthDict) {
        _currentReceiveLengthDict = [[NSMutableDictionary alloc] init];
    }
    return _currentReceiveLengthDict;
}

- (dispatch_queue_t) delegateQueue {
    if (!_delegateQueue) {
        _delegateQueue = dispatch_queue_create("com.delegateQueue.CMSynConnect", DISPATCH_QUEUE_SERIAL);
    }
    return _delegateQueue;
}

+ (instancetype) shared {
    static dispatch_once_t CMTcpConnectToken;
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
                      expectResponseEndData:(NSData *) endData
                       expectResponseLength:(NSUInteger) length
                            resolveProtocol:(id <CMSyncResolveProtocol>) resolveProtocol{
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
    self.firstResponseLength = length;
    self.firstResponseEndData = endData;
    self.port = port;
    self.resolveDelegate = resolveProtocol;
    selfAdress = [CMDataSyncTool getCurrentMachineIpAddress];
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

- (void) sendData:(NSData *) data expectResponseEndData:(NSData *) endData expectResponseLength:(NSUInteger) length
              tag:(NSUInteger) tag {
    dispatch_async(self.delegateQueue, ^{
        GCDAsyncSocket *socketBeUsed =  self.listeningSocket ? self.listeningSocket : self.socket;
        if (!socketBeUsed || !socketBeUsed.isConnected) { return;}
        //一读一写是相对的
        if (endData) {
            [socketBeUsed readDataToData:endData withTimeout:-1 tag:tag];
        } else {
            [socketBeUsed readDataToLength:length withTimeout:-1 tag:tag];
        }
        self.currentWrittingDataDict[@(tag)] = data;
        [socketBeUsed writeData:data withTimeout:-1 tag:tag];
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
    NSUInteger totalSendLength = 0;
    NSNumber *currentSendLength = self.currentSendLengthDict[@(tag)];
    if (currentSendLength) {
        totalSendLength = [currentSendLength unsignedIntegerValue] + partialLength;
    } else {
        totalSendLength = partialLength;
    }
    self.currentSendLengthDict[@(tag)] = @(totalSendLength);
    [self.resolveDelegate sendedLength:totalSendLength tag:tag transmitStatus:CMSyncTransmitStatusSending];
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
    if (self.firstResponseEndData) {
        [self.listeningSocket readDataToData:self.firstResponseEndData withTimeout:-1 tag:kCMListenInitialTag];
    } else {
        [self.listeningSocket readDataToLength:self.firstResponseLength withTimeout:-1 tag:kCMListenInitialTag];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [self.resolveDelegate resolveReceivedData:[[NSMutableData alloc] initWithData:data]
                                      address:self.senderAdress
                                receiveLength:data.length
                                          tag:tag transmitStatus:CMSyncTransmitStatusComplete];
    self.currentReceiveLengthDict[@(tag)] = nil;
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSUInteger totalReceiveLength = 0;
    NSNumber *currentReceiveLength = self.currentReceiveLengthDict[@(tag)];
    if (currentReceiveLength) {
        totalReceiveLength = [currentReceiveLength unsignedIntegerValue] + partialLength;
    } else {
        totalReceiveLength = partialLength;
    }
    self.currentReceiveLengthDict[@(tag)] = @(totalReceiveLength);
    [self.resolveDelegate resolveReceivedData:nil
                                      address:self.senderAdress
                                receiveLength:totalReceiveLength
                                          tag:tag
                               transmitStatus:CMSyncTransmitStatusSending];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    [self.resolveDelegate resolveReceivedData:nil
                                      address:self.senderAdress
                                receiveLength:length
                                          tag:tag
                               transmitStatus:CMSyncTransmitStatusTimeout];
    return 0;
}



@end
    
