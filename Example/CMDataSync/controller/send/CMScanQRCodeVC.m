//
//  CMScanQRCodeVC.m
//  CMDataSync_Example
//
//  Created by HeQingliang on 2021/11/4.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import "CMScanQRCodeVC.h"
#import <CMDataSync/CMDataSync.h>
#import "SenderResolveProtocolManager.h"
#import "SelectNotebookViewController.h"

static void *kCMSenderResolveStatusContext = &kCMSenderResolveStatusContext;
static void *kCMSenderResolveStatusStringContext = &kCMSenderResolveStatusStringContext;
static void *kCMSenderResolveProgressContext = &kCMSenderResolveProgressContext;
static void *kCMSenderResolveTransmitContext = &kCMSenderResolveTransmitContext;
static void *kCMSenderResolveFileNameContext = &kCMSenderResolveFileNameContext;

@interface CMScanQRCodeVC ()<SelectNotebookViewDelegate>

@property (strong, nonatomic) UIView *boxView;
@property (nonatomic) BOOL isReading;
@property (strong, nonatomic) CALayer *scanLayer;
@property (strong, nonatomic) UILabel *fileNameLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *transmitLabel;
@property (strong, nonatomic) UILabel *progeressLabel;
@end

@implementation CMScanQRCodeVC

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.textColor = [UIColor blackColor];
    }
    return _statusLabel;
}

- (UILabel *) transmitLabel {
    if (!_transmitLabel) {
        _transmitLabel = [[UILabel alloc] init];
        _transmitLabel.textColor = [UIColor blackColor];
    }
    return _transmitLabel;
}

- (UILabel *) progeressLabel {
    if (!_progeressLabel) {
        _progeressLabel = [[UILabel alloc] init];
        _progeressLabel.textColor = [UIColor blackColor];
    }
    return _progeressLabel;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] init];
        _fileNameLabel.textColor = [UIColor blackColor];
    }
    return _fileNameLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"扫描二维码";
    
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(20, 80, GH_WIDTH-40, 50)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=@"扫描二维码";
    [labIntroudction sizeToFit];
    labIntroudction.center = CGPointMake(GH_WIDTH / 2, GH_HEIGHT / 2 - 40);
    [self.view addSubview:labIntroudction];
    
    [self.view addSubview:self.statusLabel];
    self.statusLabel.center = CGPointMake(GH_WIDTH / 2, GH_HEIGHT/2);
    
    [self.view addSubview:self.progeressLabel];
    self.progeressLabel.center = CGPointMake(GH_WIDTH / 2, GH_HEIGHT / 2 + 40);
    
    [self.view addSubview:self.transmitLabel];
    self.transmitLabel.center = CGPointMake(GH_WIDTH / 2, GH_HEIGHT / 2 + 60);
    
    [self.view addSubview:self.fileNameLabel];
    self.fileNameLabel.center = CGPointMake(GH_WIDTH / 2, GH_HEIGHT / 2 + 90);
    
    SenderResolveProtocolManager *sender = [SenderResolveProtocolManager shared];
    [ sender addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:NSKeyValueObservingOptionNew context:kCMSenderResolveStatusContext];
    [ sender addObserver:self forKeyPath:NSStringFromSelector(@selector(statusStr)) options:NSKeyValueObservingOptionNew context:kCMSenderResolveStatusStringContext];
    [sender addObserver:self forKeyPath:NSStringFromSelector(@selector(bigFileProgress)) options:NSKeyValueObservingOptionNew context:kCMSenderResolveProgressContext];
    [sender addObserver:self forKeyPath:NSStringFromSelector(@selector(transmitStr)) options:NSKeyValueObservingOptionNew context:kCMSenderResolveTransmitContext];
    [sender addObserver:self forKeyPath:NSStringFromSelector(@selector(currentFileName)) options:NSKeyValueObservingOptionNew context:kCMSenderResolveFileNameContext];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [CMDataSyncQRCodeTCPquickStarter startConnectionWithScanView:self.view senderResolveProtocol:[SenderResolveProtocolManager shared]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [CMDataSyncQRCodeTCPquickStarter stopScanning];
}

- (void)dealloc {
    SenderResolveProtocolManager *sender = [SenderResolveProtocolManager shared];
    [sender removeObserver:self forKeyPath:NSStringFromSelector(@selector(statusStr)) context:kCMSenderResolveStatusStringContext];
    [sender removeObserver:self forKeyPath:NSStringFromSelector(@selector(bigFileProgress)) context:kCMSenderResolveProgressContext];
    [sender removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:kCMSenderResolveStatusContext];
    [sender removeObserver:self forKeyPath:NSStringFromSelector(@selector(transmitStr)) context:kCMSenderResolveTransmitContext];
    [sender removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentFileName)) context:kCMSenderResolveFileNameContext];
}

#pragma mark - 取消按钮
-(void)backAction {

}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                        context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (context == kCMSenderResolveStatusContext) {
            CMSyncConnectStatus status = [change[NSKeyValueChangeNewKey] integerValue];
            if (status == CMSyncConnectStatusConnected) {
                [CMDataSyncQRCodeTCPquickStarter stopScanning];
                //链接成功，跳转到选择笔记本页面
                SelectNotebookViewController *noteController = [[SelectNotebookViewController alloc] init];
                noteController.delegate = self;
                [self addChildViewController:noteController];
                [self.view addSubview:noteController.view];
                [noteController didMoveToParentViewController:self];
            }
        }
        else if (context == kCMSenderResolveStatusStringContext) {
            NSString *statusStr = change[NSKeyValueChangeNewKey];
            self.statusLabel.text = statusStr;
        } else if (context == kCMSenderResolveProgressContext) {
            float progress = [change[NSKeyValueChangeNewKey] floatValue];
            NSString *progressStr = [NSString stringWithFormat:@"传输进度:%.2f",progress];
            self.progeressLabel.text = progressStr;
        } else if (context == kCMSenderResolveTransmitContext) {
            NSString *transmitStatusStr = change[NSKeyValueChangeNewKey];
            self.transmitLabel.text = transmitStatusStr;
        } else if (context == kCMSenderResolveFileNameContext) {
            NSString *fileName = change[NSKeyValueChangeNewKey];
            self.fileNameLabel.text = fileName;
        }
    });
}

-(void)sendDataTable:(SelectNotebookViewController *)table
   selectedNotebooks:(NSArray<NotebookModel *> *)selectedNotebooks {
    //选择传输的字典模型
    SenderResolveProtocolManager *sender = [SenderResolveProtocolManager shared];
    [sender sendNotebooks:selectedNotebooks];
    //关闭选择页面
    UIViewController *noteVC = self.childViewControllers.firstObject;
    [noteVC willMoveToParentViewController:nil];
    [noteVC.view removeFromSuperview];
    [noteVC removeFromParentViewController];
}


@end
