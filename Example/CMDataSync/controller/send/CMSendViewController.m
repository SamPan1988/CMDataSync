//
//  CMSendViewController.m
//  CMDataSync_Example
//
//  Created by HeQingliang on 2021/11/4.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import "CMSendViewController.h"
#import "SelectNotebookView.h"
#import "CMSyncDefine.h"

@interface CMSendViewController ()
@property (nonatomic,strong) UILabel *tipsLabel;
@end

@implementation CMSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发送数据";
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"正在连接...";
    [self.view addSubview:label];
    [label sizeToFit];
    label.center = self.view.center;
    self.tipsLabel = label;
}

- (void)sendNotebookUpdateStatus:(CMSyncConnectStatus)status {
    switch (status) {
        case CMSyncConnectStatusIdle:
            break;
        case CMSyncConnectStatusConnecting:
            break;
        case CMSyncConnectStatusConnected:
//            [self.tipsLabel removeFromSuperview];
//            self.tipsLabel = nil;
//            [self setSendTable];
            break;
        case CMSyncConnectStatusConnectTimeout:
//            [self showConnectTimeoutAlert];
            break;;
    }
}

@end
