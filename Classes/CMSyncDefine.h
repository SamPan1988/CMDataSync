//
//  CMSyncConstants.h
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/3.
//

#ifndef CMSyncDefine_h
#define CMSyncDefine_h

//用于描述TCP链接的状态
typedef enum : NSUInteger {
    CMSyncConnectStatusIdle,
    CMSyncConnectStatusConnectWaiting, //作为监听方等待被连接
    CMSyncConnectStatusConnectTimeout,
    CMSyncConnectStatusConnecting,
    CMSyncConnectStatusConnected,
    CMSyncConnectStatusConnectError,
} CMSyncConnectStatus;

typedef enum : NSUInteger {
    CMSyncTransmitStatusWaiting = 0,
    CMSyncTransmitStatusSending,
    CMSyncTransmitStatusComplete
} CMSyncTransmitStatus;


@protocol CMSyncResolveProtocol <NSObject>

/// 用于接收当前连接状态
/// @param status 网络连接状态
/// @param connectError 连接错误时，回调的错误信息
- (void) didReceiveConnectStatus:(CMSyncConnectStatus) status error:(NSError *) connectError;


/// 用于解释接收到的数据
/// @param data 接收的数据
/// @param address 发送方的地址
- (void) resolveReceivedData:(NSData *) data address:(NSData *) address;

@end

#endif /* CMSyncConstants_h */
