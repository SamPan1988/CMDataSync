//
//  CMSyncSendManager.h
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/3.
//

#import "CMSyncDefine.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface CMSyncConnectManager : NSObject

+ (instancetype) shared;

/// 作为发送方建立连接，注意，每次关闭连接前，host，port，解释协议实例均不会变化
/// @param host 目的地址
/// @param port 目的port
/// @param resolveProtocol 解释数据代理实例
- (void) startConnectWithHost:(NSString *) host
                         port:(uint16_t) port
              resolveProtocol:(id <CMSyncResolveProtocol> ) resolveProtocol;


/// 作为接收方等待连接建立，建立监听成功后，返回本机地址作公告之用
/// @param port 监听port
/// @param resolveProtocol 解释数据代理实例
/// @param error 错误回调
- (NSString *) startWaitingForConnectOnPort:(uint16_t) port
                            resolveProtocol:(id <CMSyncResolveProtocol>) resolveProtocol
                                      error:(NSError * *) error;

- (void) stopConnect;

- (void) sendData:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
