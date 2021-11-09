//
//  ReceiverResolveProtocolManager.m
//  CMDataSync_Example
//
//  Created by 潘绍森 on 2021/11/8.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import "ReceiverResolveProtocolManager.h"
#import "CMResolveProtocolTool.h"
#import "NotebookModel.h"
#import <YYModel/YYModel.h>

@interface ReceiverResolveProtocolManager()
@property (nonatomic, assign, readwrite) float bigFileProgress; //大文件接收进度
@property (nonatomic, strong) NotebookModel *receiveModel;
@end

@implementation ReceiverResolveProtocolManager
/// 用于接收当前连接状态
/// @param status 网络连接状态
/// @param connectError 连接错误时，回调的错误信息
- (void) didReceiveConnectStatus:(CMSyncConnectStatus) status error:(NSError *) connectError {
    
}


/// 发送进度回调
/// @param sendedLength 已发送的字节数
/// @param tag 被发送数据的tag值，作标识用
/// @param status 传输状态
- (void) sendedLength:(NSUInteger) sendedLength
                   tag:(NSUInteger) tag
       transmitStatus:(CMSyncTransmitStatus) status {
    
}


/// 接收数据解释方法
/// @param buffer 已接收的数据
/// @param address 发送方的地址
/// @param receivedLength 已接收的数据长度
/// @param tag buffer的标识
/// @param transmitStatus 传输状态
- (void) resolveReceivedData:(NSMutableData *) buffer
                     address:(NSString *) address
               receiveLength:(NSUInteger) receivedLength
                         tag:(NSUInteger) tag
              transmitStatus:(CMSyncTransmitStatus) transmitStatus {
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
                if (code == kCMNoteModelTransferCode) {
                    NSLog(@"笔记模型接收");
                    //传输笔记的id和数据长度
                    
                } else if (code == kCMNoteMetaTransferCode) {
                    NSLog(@"笔记的meta接收");
                    //传输笔记内容
                } else if (code == kCMNoteContentTransferCode) {
                    NSLog(@"笔记的内容接收");
                    //传输下一个笔记本或者断开链接
                }
                
            }];
            break;
    }
}
@end
