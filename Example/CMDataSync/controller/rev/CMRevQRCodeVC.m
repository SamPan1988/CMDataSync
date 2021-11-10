//
//  CMRevQRCodeVC.m
//  CMDataSync_Example
//
//  Created by HeQingliang on 2021/11/4.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import "CMRevQRCodeVC.h"
#import "ReceiverResolveProtocolManager.h"
#import <CMDataSync/CMDataSync.h>

@interface CMRevQRCodeVC ()
@property (nonatomic, strong) UIImageView *qrCodeImageView;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation CMRevQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.title = @"接收数据";
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *image = [CMDataSyncQRCodeTCPquickStarter waitForConnectionWithSize:150 receiverResolveProtocol:[ReceiverResolveProtocolManager shared]];
    _qrCodeImageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:_qrCodeImageView];
    _qrCodeImageView.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 50)];
    _statusLabel.center = CGPointMake(self.view.center.x, self.view.center.y + 80);
    _statusLabel.numberOfLines = 0;
    _statusLabel.text = @"请使用发送端扫描此二维码\n收发的手机必须连接同一个WiFi";
    _statusLabel.font = [UIFont systemFontOfSize:13];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_statusLabel];
}


@end
