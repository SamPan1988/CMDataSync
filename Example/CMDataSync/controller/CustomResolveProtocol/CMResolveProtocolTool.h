//
//  CMResolveProtocolTool.h
//  CMDataSync_Example
//
//  Created by 潘绍森 on 2021/11/9.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CMResolveCompletor)(UInt8 code, UInt8 status, NSData *receivedData);

@interface CMResolveProtocolTool : NSObject


/// 给数据添加上头部信息
/// @param data 被添加头部信息的数据，可为空
/// @param code 步骤码
/// @param status 状态码
+ (NSData *) appendHeaderOnData:( NSData * _Nullable ) data
                       withCode:(UInt8) code
                         status:(UInt8) status;


/// 接收数据，分离头部信息和实际数据
/// @param data 接收到的数据
/// @param completor 分离后的结果
+ (void) resolveIncomeData:(NSData *) data
                  complete:(CMResolveCompletor) completor;


@end

NS_ASSUME_NONNULL_END
