//
//  CMDataSyncQRCodeTCPquickStarter.h
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CMSyncDefine.h"

NS_ASSUME_NONNULL_BEGIN

/// 该类提供快速集成文件传输能力，通过二维码发现服务，并使用TCP协议作数据传输
@interface CMDataSyncQRCodeTCPquickStarter : NSObject

/// 扫描二维码后尝试建立连接
/// @param view 扫描使用的view
/// @param senderResolveProtocol 发送方数据解释类，解释类实例会被强引用直到链接断开
+ (void) startConnectionWithScanView:(UIView *) view
               senderResolveProtocol:(id <CMSyncResolveProtocol>) senderResolveProtocol;

+ (void) stopScanning;

/// 生成二维码并开展链接监听, 如果失败，则返回nil，并在解释类中回调失败error
/// @param size 二维码的大小
/// @param endData 预期首次返回数据的终止符
/// @param length 预期首次返回数据的长度, 若终止符已设置，则忽略长度
/// @param receiveResolveProtocol 接收方数据解释类，解释类实例会被强引用直到链接断开
+ (UIImage *) waitForConnectionWithSize:(CGFloat ) size
                expectedResponseEndData:(NSData *) endData
                 expectedResponseLength:(NSUInteger) length
                receiverResolveProtocol:(id <CMSyncResolveProtocol>) receiveResolveProtocol;


/// 发送数据，发送后即会开始监听接收方的反馈，若链接还没有建立，该方法调用无效
/// @param data 被发送的数据
/// @param endData 预期返回数据的终止符
/// @param length 预期返回数据的长度，如果终止符已设置，则忽略长度
/// @param tag 被发送数据的tag
+ (void) sendData:(NSData *) data expectResponseEndData:(NSData *) endData expectResponseLength:(NSUInteger) length
              tag:(NSUInteger) tag;


/// 断开链接
+ (void) stopConnection;

@end

NS_ASSUME_NONNULL_END
