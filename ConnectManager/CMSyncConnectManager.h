//
//  CMSyncSendManager.h
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/3.
//

#import "CMSyncDefine.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NSInteger CMSyncErrorCode;
const CMSyncErrorCode CMSyncConnected = 750;


/// CMSyncConnectManager 负责链接的建立和状态跟踪
@interface CMSyncConnectManager : NSObject

+ (instancetype) shared;

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

/// 关闭链接
/// @param option 关闭链接选项，可以设定是否等待在列的接收发送完成
- (void) stopConnect:(CMSyncDisconnectOption) option;

/// 发送数据，发送后即会开始监听接收方的反馈，若链接还没有建立，该方法调用无效
/// @param data 被发送的数据
/// @param tag 被发送数据的tag
- (void) sendData:(NSData *) data tag:(NSUInteger) tag;

@end

NS_ASSUME_NONNULL_END
