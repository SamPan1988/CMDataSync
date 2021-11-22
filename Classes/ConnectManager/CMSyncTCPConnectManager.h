//
//  CMSyncSendManager.h
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/3.
//

#import "CMSyncDefine.h"
#import <Foundation/Foundation.h>

#define kCMSyncErrorCodeConnected 750
static const long kCMListenInitialTag = -9394;

NS_ASSUME_NONNULL_BEGIN

/// CMSyncConnectManager 负责链接的建立和状态跟踪
@interface CMSyncTCPConnectManager : NSObject <CMSyncConnectManager>

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
/// @param endData 预期首次返回数据的终止符
/// @param length 预期首次返回数据的长度，若已设定终止符，则忽略长度
/// @param resolveProtocol  解释数据代理实例, manager对代理实例有强引用，直到链接结束
- (NSString *) startWaitingForConnectOnPort:(uint16_t) port
                      expectResponseEndData:(NSData *) endData
                       expectResponseLength:(NSUInteger) length
                            resolveProtocol:(id <CMSyncResolveProtocol>) resolveProtocol;

/// 关闭链接
/// @param option 关闭链接选项，可以设定是否等待在列的接收发送完成
- (void) stopConnect:(CMSyncDisconnectOption) option;

/// 发送数据，发送后即会开始监听接收方的反馈，若链接还没有建立，该方法调用无效
/// @param data 被发送的数据
/// @param endData 预期返回数据的终止符
/// @param length 预期返回数据的长度，如果终止符已设置，则忽略长度
/// @param tag 被发送数据的tag
- (void) sendData:(NSData *) data expectResponseEndData:(NSData *) endData expectResponseLength:(NSUInteger) length
              tag:(NSUInteger) tag;

@end

NS_ASSUME_NONNULL_END
