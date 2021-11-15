//
//  CMCustomResolveProtocol.m
//  CMDataSync_Example
//
//  Created by 潘绍森 on 2021/11/8.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import "SenderResolveProtocolManager.h"
#import "CMResolveProtocolTool.h"
#import "NotebookModel.h"
#import <YYModel/YYModel.h>

@interface SenderResolveProtocolManager()
//Status
@property (nonatomic, assign, readwrite) float bigFileProgress; //大文件发送进度
@property (nonatomic, assign, readwrite) CMSyncConnectStatus status; //连接状态,kvo
@property (nonatomic, copy, readwrite) NSString *statusStr; //连接状态,kvo
@property (nonatomic, copy, readwrite) NSString *transmitStr; //传输状态,kvo
@property (nonatomic, copy, readwrite) NSString *currentFileName;
//Model record
@property (nonatomic, strong) NSArray <NotebookModel *> *notebooklist;
@property (nonatomic, assign) NSUInteger currentModelIndex;
@property (nonatomic, strong) NotebookModel *currentNotebook;
@property (nonatomic, assign) NSUInteger currentAttachmentSize;
@end

@implementation SenderResolveProtocolManager

+ (instancetype) shared {
    static dispatch_once_t CMSenderConnectToken;
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
    self.transmitStr = [CMResolveProtocolTool convertTransmitStatus:status];
    if (tag == CMNoteContentTransferCode) {
        self.bigFileProgress = sendedLength / self.currentAttachmentSize;
    }
}


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
                if (status != 1) {
                    NSLog(@"接收失败");
                    return;
                }
                if (code == CMNoteModelTransferCode) {
                    NSLog(@"笔记模型接收成功");
                    //传输笔记附件的id和附件数据长度
                    NSData *attachData = [NSData dataWithContentsOfFile:self.currentNotebook.attachment];
                   NSString *fileName = [[self.currentNotebook.attachment lastPathComponent] stringByDeletingPathExtension];
                    self.currentFileName = fileName;
                    self.currentAttachmentSize = attachData.length;
                    NSDictionary *dict = @{
                        kCMNoteBookIdOfAttachment: self.currentNotebook.notebookID,
                        kCMNoteBookSizeOfAttachment: @(self.currentAttachmentSize),
                        kCMNoteBookNameOfAttachment: fileName
                    };
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
                    NSData *transmitData = [CMResolveProtocolTool appendHeaderOnData:jsonData withCode:CMNoteMetaTransferCode status:0];
                    [CMDataSyncQRCodeTCPquickStarter sendData:transmitData withTag:CMNoteMetaTransferCode];
                } else if (code == CMNoteMetaTransferCode) {
                    NSLog(@"笔记的meta传输成功");
                    NSData *attachData = [NSData dataWithContentsOfFile:self.currentNotebook.attachment];
                    NSData *transmitData = [CMResolveProtocolTool appendHeaderOnData:attachData withCode:CMNoteContentTransferCode status:0];
                    [CMDataSyncQRCodeTCPquickStarter sendData:transmitData withTag:CMNoteContentTransferCode];
                    //传输笔记内容
                } else if (code == CMNoteContentTransferCode) {
                    NSLog(@"笔记的内容传输成功");
                    //传输下一个笔记本或者断开链接
                    if (self.currentModelIndex + 1 >= self.notebooklist.count) {
                        //已经全部传输完毕，关闭链接
                        [CMDataSyncQRCodeTCPquickStarter stopConnection];
                        return;
                    }
                    self.bigFileProgress = 0;
                    self.currentModelIndex += 1;
                    self.currentNotebook = self.notebooklist[self.currentModelIndex];
                    NSData *modelData = [self.currentNotebook yy_modelToJSONData];
                    NSData *dataWithHeader = [CMResolveProtocolTool appendHeaderOnData:modelData withCode:CMNoteModelTransferCode status:0];
                    [CMDataSyncQRCodeTCPquickStarter sendData:dataWithHeader withTag:CMNoteModelTransferCode];
                }
                
            }];
            break;
    }
}

- (void) sendNotebooks:(NSArray <NotebookModel *> *) noteBooklist {
    if (!noteBooklist ||
        !noteBooklist.firstObject ) {
        return;
    }
    //发送第一个
    self.notebooklist = noteBooklist;
    self.currentModelIndex = 0;
    self.currentNotebook = noteBooklist.firstObject;
    NSData *modelData = [self.currentNotebook yy_modelToJSONData];
    NSData *dataWithHeader = [CMResolveProtocolTool appendHeaderOnData:modelData withCode:CMNoteModelTransferCode status:0];
    [CMDataSyncQRCodeTCPquickStarter sendData:dataWithHeader withTag:CMNoteModelTransferCode];
}




@end
