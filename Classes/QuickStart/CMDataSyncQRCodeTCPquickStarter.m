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

+ (UIImage *) waitForConnectionWithSize:(CGFloat ) size
                receiverResolveProtocol:(id <CMSyncResolveProtocol>) receiveResolveProtocol {
    NSError *error;
    NSString *address = [[CMSyncTCPConnectManager shared] startWaitingForConnectOnPort:kCMDataSyncDefaultPort resolveProtocol:receiveResolveProtocol error:&error];
    if (error || !address) {
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

+ (void) sendData:(NSData *) data withTag: (NSUInteger) tag {
    CMLatestSendingDataSize = data.length;
    [[CMSyncTCPConnectManager shared] sendData:data tag:tag];
}

@end
