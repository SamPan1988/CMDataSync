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

+ (NSData *) appendHeaderOnData:( NSData * _Nullable ) data
                       withCode:(UInt8) code
                         status:(UInt8) status
                         endData:(NSData *) endData {
    NSMutableData *resultData = [[NSMutableData alloc] init];
    Byte header[kCMReserveHeaderLength];
    for (NSUInteger i = 0; i < kCMReserveHeaderLength; i++) {
        if (i == 0) {
            header[i] = code;
        } else if (i == 1) {
            header[i] = status;
        } else if (i < kCMReserveHeaderLength) {
            header[i] = 0;
        }
    }
    [resultData appendBytes:&header length:kCMReserveHeaderLength];
    if (data && [data length] > 0) {
        NSData *base64Data = [data base64EncodedDataWithOptions:0];
        NSUInteger len = [base64Data length];
        Byte *byteData = (Byte *) malloc(len);
        [base64Data getBytes:byteData length:len];
        [resultData appendBytes:byteData length:len];
        free(byteData);
    }
    if (endData) {
        NSUInteger len = [endData length];
        Byte *byteData = (Byte *) malloc(len);
        [endData getBytes:byteData length:len];
        [resultData appendBytes:byteData length:len];
        free(byteData);
    }
    return resultData;
}

+ (void) resolveIncomeData:(NSData *) data
                   endData:(NSData *) endDdata
                  complete:(CMResolveCompletor) completor {
    UInt8 code = 0;
    UInt8 status = 0;
    if (!data) {
        completor(code,status,nil);
        return;
    }
 
    NSUInteger len = data.length;
    UInt8 *codeBuffer = malloc(1);
    [data getBytes:(void *) codeBuffer range:NSMakeRange(0, 1)];
    code = *codeBuffer;
    free(codeBuffer);
    
    UInt8 *statusBuffer = malloc(1);
    [data getBytes:(void *) statusBuffer range:NSMakeRange(1, 1)];
    status = *statusBuffer;
    free(statusBuffer);
    
    //自然会截除尾部
    NSInteger resultDataLen = len - kCMReserveHeaderLength;
    if (resultDataLen <= 0) {
        completor(code,status,nil);
        return;
    }
    void *resultDataBuffer = malloc(resultDataLen);
    [data getBytes:resultDataBuffer range:NSMakeRange(kCMReserveHeaderLength, resultDataLen)];
    NSData *base64Data = [[NSData alloc] initWithBytes:resultDataBuffer length:resultDataLen];
    free(resultDataBuffer);
    NSData *resultData = [[NSData alloc] initWithBase64EncodedData:base64Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
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

+ (NSData *)CRLFData
{
    return [NSData dataWithBytes:"\x0D\x0A" length:2];
}

+ (NSData *)CRData
{
    return [NSData dataWithBytes:"\x0D" length:1];
}

+ (NSData *)LFData
{
    return [NSData dataWithBytes:"\x0A" length:1];
}

+ (NSData *)ZeroData
{
    return [NSData dataWithBytes:"" length:1];
}

@end
