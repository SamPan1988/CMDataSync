//
//  CMDataSyncQRCodeTCPquickStarter.m
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/8.
//

#import "CMDataSyncQRCodeTCPquickStarter.h"
#import "QRCodeServiceManager.h"
#import "CMSyncTCPConnectManager.h"

static NSString const *kCMDataSyncAddHead = @"CMDataSync";
static const NSUInteger kCMDataSyncDefaultPort = 5488;

static QRCodeServiceManager *tempHolder;
static const NSUInteger kCMSendDataConstraint = 1 * 1024 * 1024;
static NSUInteger CMLatestSendingDataSize = 0;

@implementation CMDataSyncQRCodeTCPquickStarter

+ (void) startConnectionWithScanView:(UIView *) view
               senderResolveProtocol:(id <CMSyncResolveProtocol>) senderResolveProtocol {
    //TODO: 这里的内存管理方式怪怪的，以后想想怎么改
    tempHolder = [[QRCodeServiceManager alloc] init];
    [tempHolder startToScanWithView:view complete:^(NSString * receiveAddress) {
       NSArray <NSString *> *stringArrs = [receiveAddress componentsSeparatedByString:@"_"];
        if (![stringArrs.firstObject isEqualToString:(NSString *) kCMDataSyncAddHead]) {
            tempHolder = nil;
            return;
        }
        if (stringArrs.count < 3) {
            tempHolder = nil;
            return;
        }
        NSString *address = stringArrs[1];
        NSUInteger port = [stringArrs[2] integerValue];
        [[CMSyncTCPConnectManager shared] startConnectWithHost:address port:port resolveProtocol:senderResolveProtocol];
        tempHolder = nil;
    }];
}

+ (void) stopScanning {
    [tempHolder stopScanning];
}

+ (UIImage *) waitForConnectionWithSize:(CGFloat ) size
                expectedResponseEndData:(NSData *) endData expectedResponseLength:(NSUInteger) length
                receiverResolveProtocol:(id <CMSyncResolveProtocol>) receiveResolveProtocol {
   
    NSString *address = [[CMSyncTCPConnectManager shared] startWaitingForConnectOnPort:kCMDataSyncDefaultPort expectResponseEndData:endData expectResponseLength:length resolveProtocol:receiveResolveProtocol];
    if (!address) {
        return nil;
    }
    NSMutableString *commpleteAddress = [[NSMutableString alloc] initWithString:(NSString *)kCMDataSyncAddHead];
    [commpleteAddress appendString:@"_"];
    [commpleteAddress appendString:address];
    [commpleteAddress appendString:@"_"];
    [commpleteAddress appendString:@(kCMDataSyncDefaultPort).stringValue];
    QRCodeServiceManager *qrCodeManager = [[QRCodeServiceManager alloc] init];
    UIImage *qrCodeImage = [qrCodeManager generateQRCodeWithString:commpleteAddress Size:size];
    return qrCodeImage;
}

+ (void) stopConnection {
    if (CMLatestSendingDataSize <= kCMSendDataConstraint) {
        [[CMSyncTCPConnectManager shared] stopConnect:CMSyncDisconnectOptionPendingSend];
    } else {
        [[CMSyncTCPConnectManager shared] stopConnect:CMSyncDisconnectOptionPendingNone];
    }
}

+ (void) sendData:(NSData *) data expectResponseEndData:(NSData *) endData expectResponseLength:(NSUInteger) length
              tag:(NSUInteger) tag {
    CMLatestSendingDataSize = data.length;
    [[CMSyncTCPConnectManager shared] sendData:data expectResponseEndData:endData expectResponseLength:length tag:tag];
}

@end
