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
    CMSyncConnectStatusConnecting,
    CMSyncConnectStatusConnected,
    CMSyncConnectStatusDisconnect,
    CMSyncConnectStatusConnectError,
} CMSyncConnectStatus;

typedef enum : NSUInteger {
    CMSyncTransmitStatusWaiting = 0,
    CMSyncTransmitStatusTimeout,
    CMSyncTransmitStatusSending,
    CMSyncTransmitStatusComplete
} CMSyncTransmitStatus;

typedef enum : NSUInteger {
    CMSyncDisconnectOptionPendingNone = 0, //不等待读写完成，直接断开链接
    CMSyncDisconnectOptionPendingSend = 1, //断开链接，并完成所有已有的发送
    CMSyncDisconnectOptionPendingReceive = 1 << 1 //断开链接，并完成所有已有的接收
} CMSyncDisconnectOption;

///CMSyncResolveProtocol 抽象类代表库使用方自定义的网络应用层实现，关注数据解释和传输顺序
@protocol CMSyncResolveProtocol <NSObject>

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

#endif /* CMSyncConstants_h */
