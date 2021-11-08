//
//  CMDataSyncTool.h
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMDataSyncTool : NSObject

/// 获取本机ip地址
+ (NSString *)getCurrentMachineIpAddress;
@end

NS_ASSUME_NONNULL_END
