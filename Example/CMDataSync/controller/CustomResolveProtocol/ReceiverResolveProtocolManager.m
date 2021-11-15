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
#import <CMDataSync/CMDataSync.h>

@interface ReceiverResolveProtocolManager()
@property (nonatomic, assign, readwrite) float bigFileProgress; //大文件接收进度,kvo
@property (nonatomic, assign, readwrite) CMSyncConnectStatus status; //连接状态,kvo

@property (nonatomic, copy, readwrite) NSString *statusStr; //连接状态,kvo
@property (nonatomic, copy, readwrite) NSString *transmitStr; //传输状态,kvo

//Model record
@property (nonatomic, assign) CMNoteTransferCode currentCode;
@property (nonatomic, strong) NotebookModel *currentNotebook;
@property (nonatomic, copy, readwrite) NSString *currentFileName;
@property (nonatomic, assign) NSUInteger currentAttachmentSize;
@end

@implementation ReceiverResolveProtocolManager

+ (instancetype) shared {
    dispatch_once_t ReceiverConnectToken;
    static ReceiverResolveProtocolManager *shared;
    dispatch_once(&ReceiverConnectToken, ^{
        shared = [[ReceiverResolveProtocolManager alloc] init];
    });
    return shared;
}


/// 用于接收当前连接状态
/// @param status 网络连接状态
/// @param connectError 连接错误时，回调的错误信息
- (void) didReceiveConnectStatus:(CMSyncConnectStatus) status error:(NSError *) connectError {
    self.status = status;
    self.statusStr = [CMResolveProtocolTool convertStauts:status];
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
    self.transmitStr = [CMResolveProtocolTool convertTransmitStatus:transmitStatus];
    switch (transmitStatus) {
        case CMSyncTransmitStatusWaiting:
            break;
        case CMSyncTransmitStatusTimeout:
            NSLog(@"接收超时");
            break;
        case CMSyncTransmitStatusSending:
            //当前正在接收大文件，则显示进度；
            if (self.currentCode == CMNoteMetaTransferCode) {
                self.bigFileProgress = receivedLength / self.currentAttachmentSize;
            }
            break;
        //TODO: 如果实际不会停，得重新想个逻辑
        case CMSyncTransmitStatusComplete:
            [CMResolveProtocolTool resolveIncomeData:buffer complete:^(UInt8 code, UInt8 status, NSData * _Nonnull receivedData) {
                self.currentCode = code;
                //没有收到数据的话
                if (!receivedData) {
                    //返回接收失败
                    NSData *responseFailData = [CMResolveProtocolTool appendHeaderOnData:nil withCode:code status:-1];
                    [CMDataSyncQRCodeTCPquickStarter sendData:responseFailData withTag:-1];
                    return;
                }
                if (code == CMNoteModelTransferCode) {
                    NSLog(@"笔记模型接收");
                    self.currentNotebook = [NotebookModel yy_modelWithJSON:receivedData];
                    
                } else if (code == CMNoteMetaTransferCode) {
                    NSLog(@"笔记的meta接收");
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingAllowFragments error:nil];
                    if (![dict isKindOfClass:[NSDictionary class]]) {
                        NSData *responseFailData = [CMResolveProtocolTool appendHeaderOnData:nil withCode:code status:-1];
                        [CMDataSyncQRCodeTCPquickStarter sendData:responseFailData withTag:-1];
                        return;
                    }
                    NSString *notebookid = dict[kCMNoteBookIdOfAttachment];
                    if (![self.currentNotebook.notebookID isEqualToString:notebookid]) {
                        NSData *responseFailData = [CMResolveProtocolTool appendHeaderOnData:nil withCode:code status:-1];
                        [CMDataSyncQRCodeTCPquickStarter sendData:responseFailData withTag:-1];
                        return;
                    }
                    self.currentAttachmentSize = [dict[kCMNoteBookSizeOfAttachment] integerValue];
                    self.currentFileName = dict[kCMNoteBookNameOfAttachment];
                   
                } else if (code == CMNoteContentTransferCode) {
                    NSLog(@"笔记的内容接收");
                    if (receivedData.length != self.currentAttachmentSize) {
                        NSData *responseFailData = [CMResolveProtocolTool appendHeaderOnData:nil withCode:code status:-1];
                        [CMDataSyncQRCodeTCPquickStarter sendData:responseFailData withTag:-1];
                        return;
                    }
                    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    NSURL *pathURL = [NSURL URLWithString:paths];
                    [pathURL URLByAppendingPathComponent:self.currentFileName];
                    self.currentNotebook.attachment = pathURL;
                    [[NSFileManager defaultManager] createFileAtPath:pathURL.absoluteString contents:receivedData attributes:nil];
                    //TODO: 保存到数据库里
                    NSLog(@"保存到数据库");
                    //清空中间值
                    self.currentNotebook = nil;
                    self.currentAttachmentSize = 0;
                }
                //回复接收成功
                NSData *responseSucceedData = [CMResolveProtocolTool appendHeaderOnData:nil withCode:code status:1];
                [CMDataSyncQRCodeTCPquickStarter sendData:responseSucceedData withTag:1];
            }];
            break;
    }
}
@end
