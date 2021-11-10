//
//  CMResolveProtocolTool.m
//  CMDataSync_Example
//
//  Created by 潘绍森 on 2021/11/9.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import "CMResolveProtocolTool.h"
const static NSUInteger kCMReserveHeaderLength = 8;

@implementation CMResolveProtocolTool

+ (NSData *) appendHeaderOnData:(NSData * _Nullable) data withCode:(UInt8) code status:(UInt8) status {
    NSData *resultData;
    NSUInteger len = [data length] <= 0 ? 1 : [data length];
    Byte *byteData = (Byte*)malloc(len);
    if (data) {
        memcpy(byteData, [data bytes], len);
    }
    Byte byteResultData[len + kCMReserveHeaderLength];
    for (NSInteger i = 0; i < len + kCMReserveHeaderLength; i++) {
        if (i == 0) {
            byteResultData[i] = code;
        } else if (i == 1) {
            byteResultData[i] = status;
        } else if (i < kCMReserveHeaderLength) {
            byteResultData[i] = 0;
        } else if(data) {
            byteResultData[i] = byteData[i - kCMReserveHeaderLength];
        }
    }
    resultData = [NSData dataWithBytes:byteResultData length:sizeof(byteResultData)];
    free(byteData);
    return resultData;
}

+ (void) resolveIncomeData:(NSData *) data complete:(CMResolveCompletor) completor {
    UInt8 code = 0;
    UInt8 status = 0;
    NSData *resultData = nil;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    NSUInteger resultDataSize = len - kCMReserveHeaderLength <= 0 ? 1 : len - kCMReserveHeaderLength;
    Byte resultByteData[resultDataSize];
    memcpy(byteData, [data bytes], len);
    for (NSInteger i = 0; i < len; i++) {
        if (i == 0) {
            code = byteData[i];
        } else if (i == 1) {
            status = byteData[i];
        } else if (i < kCMReserveHeaderLength) {
            continue;
        } else if (len - kCMReserveHeaderLength > 0){
            resultByteData[i - kCMReserveHeaderLength] = byteData[i];
        }
    }
    if (len - kCMReserveHeaderLength > 0) {
        resultData = [NSData dataWithBytes:resultByteData length:resultDataSize];
    }
    free(byteData);
    completor(code, status, resultData);
}

+ (NSString *) convertStauts:(CMSyncConnectStatus) status {
    switch (status) {
        case CMSyncConnectStatusIdle:
            return @"链接初始状态";
        case CMSyncConnectStatusConnectWaiting:
            return @"等待链接";
        case CMSyncConnectStatusConnecting:
            return @"正在链接";
        case CMSyncConnectStatusConnected:
            return @"成功链接";
        case CMSyncConnectStatusDisconnect:
            return @"链接断开";
        case CMSyncConnectStatusConnectError:
            return @"链接失败";
    }
}

+ (NSString *) convertTransmitStatus:(CMSyncTransmitStatus) transmitStatus {
    switch (transmitStatus) {
        case CMSyncTransmitStatusWaiting:
            return @"等待传输中";
        case CMSyncTransmitStatusTimeout:
            return @"传输超时";
        case CMSyncTransmitStatusSending:
            return @"正在传输";
        case CMSyncTransmitStatusComplete:
            return @"传输结束";
    }
}

@end
