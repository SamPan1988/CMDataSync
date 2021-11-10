//
//  CMCustomResolveProtocol.m
//  CMDataSync_Example
//
//  Created by 潘绍森 on 2021/11/8.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import "SenderResolveProtocolManager.h"
#import "CMResolveProtocolTool.h"

@interface SenderResolveProtocolManager()
@property (nonatomic, assign, readwrite) float bigFileProgress; //大文件发送进度
@property (nonatomic, assign, readwrite) CMSyncConnectStatus status; //连接状态,kvo
@property (nonatomic, copy, readwrite) NSString *statusStr; //连接状态,kvo
@property (nonatomic, copy, readwrite) NSString *transmitStr; //传输状态,kvo
@end

@implementation SenderResolveProtocolManager

+ (instancetype) shared {
    dispatch_once_t CMSenderConnectToken;
    static SenderResolveProtocolManager *shared;
    dispatch_once(&CMSenderConnectToken, ^{
        shared = [[SenderResolveProtocolManager alloc] init];
    });
    return shared;
}


- (void) didReceiveConnectStatus:(CMSyncConnectStatus) status error:(NSError *) connectError {
    self.status = status;
    self.statusStr = [CMResolveProtocolTool convertStauts:status];
    switch (status) {
        case CMSyncConnectStatusIdle:
            NSLog(@"CMDataSync:发送方，初始状态");
            break;
        case CMSyncConnectStatusConnectWaiting:
            NSLog(@"CMDataSync:发送方，等待状态");
            break;
        case CMSyncConnectStatusConnecting:
            NSLog(@"CMDataSync:发送方，链接中状态");
            break;
        case CMSyncConnectStatusConnected:
            NSLog(@"CMDataSync:发送方，链接成功");
            break;
        case CMSyncConnectStatusDisconnect:
            NSLog(@"CMDataSync:发送方，断开链接");
            break;
        case CMSyncConnectStatusConnectError:
            NSLog(@"CMDataSync:发送方，链接失败");
            break;
    }
}


- (void) sendedLength:(NSUInteger) sendedLength
                   tag:(NSUInteger) tag
       transmitStatus:(CMSyncTransmitStatus) status {
    
}


- (void) resolveReceivedData:(NSMutableData *) buffer
                     address:(NSString *) address
               receiveLength:(NSUInteger) receivedLength
                         tag:(NSUInteger) tag
              transmitStatus:(CMSyncTransmitStatus) transmitStatus {
    self.transmitStr = [CMResolveProtocolTool convertTransmitStatus:transmitStatus];
    
    switch (transmitStatus) {
        case CMSyncTransmitStatusWaiting:
            
            break;
        case CMSyncTransmitStatusTimeout:
            NSLog(@"接收超时");
            break;
        case CMSyncTransmitStatusSending:
            break;
        case CMSyncTransmitStatusComplete:
            [CMResolveProtocolTool resolveIncomeData:buffer complete:^(UInt8 code, UInt8 status, NSData * _Nonnull receivedData) {
                if (status != 1) {
                    NSLog(@"接收失败");
                    return;
                }
                if (code == kCMNoteModelTransferCode) {
                    NSLog(@"笔记模型接收成功");
                    //传输笔记的id和数据长度
                    
                } else if (code == kCMNoteMetaTransferCode) {
                    NSLog(@"笔记的meta传输成功");
                    //传输笔记内容
                } else if (code == kCMNoteContentTransferCode) {
                    NSLog(@"笔记的内容传输成功");
                    //传输下一个笔记本或者断开链接
                }
                
            }];
            break;
    }
}

@end
