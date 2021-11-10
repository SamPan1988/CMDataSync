//
//  ReceiverResolveProtocolManager.h
//  CMDataSync_Example
//
//  Created by 潘绍森 on 2021/11/8.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CMDataSync/CMDataSync.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReceiverResolveProtocolManager : NSObject <CMSyncResolveProtocol>

@property (nonatomic, assign, readonly) float bigFileProgress; //大文件接收进度
@property (nonatomic, assign, readonly) CMSyncConnectStatus status; //连接状态,kvo
@property (nonatomic, copy, readonly) NSString *statusStr; //连接状态,kvo
@property (nonatomic, copy, readonly) NSString *transmitStr; //传输状态,kvo

+ (instancetype) shared;

/// 用于接收当前连接状态
/// @param status 网络连接状态
/// @param connectError 连接错误时，回调的错误信息
- (void) didReceiveConnectStatus:(CMSyncConnectStatus) status error:(NSError *) connectError;


/// 发送进度回调
/// @param sendedLength 已发送的字节数
/// @param tag 被发送数据的tag值，作标识用
/// @param status 传输状态
- (void) sendedLength:(NSUInteger) sendedLength
                   tag:(NSUInteger) tag
        transmitStatus:(CMSyncTransmitStatus) status;


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
              transmitStatus:(CMSyncTransmitStatus) transmitStatus;
@end

NS_ASSUME_NONNULL_END
