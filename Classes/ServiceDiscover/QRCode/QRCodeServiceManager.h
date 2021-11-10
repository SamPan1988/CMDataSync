//
//  QRCodeServiceManager.h
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^CMScanComplete)(NSString *);

/// 服务发现类，提供以二维码方式公告服务的存在
@interface QRCodeServiceManager : NSObject

- (void) startToScanWithView:(UIView *) view complete:(CMScanComplete) scanComplete;

- (UIImage *)generateQRCodeWithString:(NSString *)string Size:(CGFloat)size;

- (void) stopScanning;

@end

NS_ASSUME_NONNULL_END
