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

/// CMSyncConnectManager 为链接管理器的抽象类，提供公共接口
@protocol CMSyncConnectManager <NSObject>

@optional
/// 作为发送方建立连接，注意，每次关闭连接前，host，port，解释协议实例均不会变化, 即只会同时存在一个链接
/// @param host 目的地址
/// @param port 目的port
/// @param resolveProtocol 解释数据代理实例, manager对代理实例有强引用，直到链接结束
- (void) startConnectWithHost:(NSString *) host
                         port:(uint16_t) port
              resolveProtocol:(id <CMSyncResolveProtocol> ) resolveProtocol;


/// 作为接收方等待连接建立，建立监听成功后，返回本机地址作公告之用
/// @param port 监听port
/// @param resolveProtocol  解释数据代理实例, manager对代理实例有强引用，直到链接结束
/// @param error 错误回调
- (NSString *) startWaitingForConnectOnPort:(uint16_t) port
                            resolveProtocol:(id <CMSyncResolveProtocol>) resolveProtocol
                                      error:(NSError * *) error;

@required
/// 关闭链接
/// @param option 关闭链接选项，可以设定是否等待在列的接收发送完成
- (void) stopConnect:(CMSyncDisconnectOption) option;

/// 发送数据，发送后即会开始监听接收方的反馈，若链接还没有建立，该方法调用无效
/// @param data 被发送的数据
/// @param tag 被发送数据的tag
- (void) sendData:(NSData *) data tag:(NSUInteger) tag;

@end

#endif /* CMSyncConstants_h */
