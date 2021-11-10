//
//  CMScanQRCodeVC.m
//  CMDataSync_Example
//
//  Created by HeQingliang on 2021/11/4.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import "CMScanQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import <CMDataSync/CMDataSync.h>
#import "SenderResolveProtocolManager.h"


@interface CMScanQRCodeVC ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) UIView *boxView;
@property (nonatomic) BOOL isReading;
@property (strong, nonatomic) CALayer *scanLayer;
@end

@implementation CMScanQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    self.title = @"扫描二维码";
    
    
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(20, 80, GH_WIDTH-40, 50)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=@"扫描二维码";
    [labIntroudction sizeToFit];
    labIntroudction.center = CGPointMake(self.view.center.x, GH_HEIGHT*0.4+GH_WIDTH*0.5f + 30);
    [self.view addSubview:labIntroudction];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [CMDataSyncQRCodeTCPquickStarter startConnectionWithScanView:self.view senderResolveProtocol:[SenderResolveProtocolManager shared]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [CMDataSyncQRCodeTCPquickStarter stopScanning];
}

#pragma mark - 取消按钮
-(void)backAction {

}

@end
