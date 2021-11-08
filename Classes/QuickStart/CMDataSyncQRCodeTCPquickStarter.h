//
//  CMDataSyncQRCodeTCPquickStarter.h
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CMSyncDefine.h>

NS_ASSUME_NONNULL_BEGIN

/// 该类提供快速集成文件传输能力，通过二维码发现服务，并使用TCP协议作数据传输
@interface CMDataSyncQRCodeTCPquickStarter : NSObject

/// 扫描二维码后尝试建立连接
/// @param view 扫描使用的view
/// @param senderResolveProtocol 发送方数据解释类
+ (void) startConnectionWithScanView:(UIView *) view
               senderResolveProtocol:(id <CMSyncResolveProtocol>) senderResolveProtocol;

/// 生成二维码并开展链接监听, 如果失败，则返回nil，并在解释类中回调失败error
/// @param size 二维码的大小
/// @param receiveResolveProtocol 接收方数据解释类
+ (UIImage *) waitForConnectionWithSize:(CGFloat ) size
                receiverResolveProtocol:(id <CMSyncResolveProtocol>) receiveResolveProtocol;

@end

NS_ASSUME_NONNULL_END
