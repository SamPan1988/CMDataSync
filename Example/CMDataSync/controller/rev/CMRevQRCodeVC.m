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

static void *kCMReceiverResolveStatusContext = &kCMReceiverResolveStatusContext;
static void *kCMReceiverResolveStatusStringContext = &kCMReceiverResolveStatusStringContext;
static void *kCMReceiverResolveProgressContext = &kCMReceiverResolveProgressContext;
static void *kCMReceiverResolveTransmitContext = &kCMReceiverResolveTransmitContext;
static void *kCMReceiverResolveFileContext = &kCMReceiverResolveFileContext;

@interface CMRevQRCodeVC ()
@property (nonatomic, strong) UIImageView *qrCodeImageView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *transmitStatusLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *fileNameLabel;
@end

@implementation CMRevQRCodeVC

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
    }
    return _statusLabel;
}

- (UILabel *) transmitStatusLabel {
    if (!_transmitStatusLabel) {
        _transmitStatusLabel = [[UILabel alloc] init];
    }
    return _transmitStatusLabel;
}

- (UILabel *) progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
    }
    return _progressLabel;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] init];
    }
    return _fileNameLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    ReceiverResolveProtocolManager *receiver = [ReceiverResolveProtocolManager shared];
    self.title = @"接收数据";
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *image = [CMDataSyncQRCodeTCPquickStarter waitForConnectionWithSize:150 receiverResolveProtocol: receiver];
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
    
    [self.view addSubview:self.progressLabel];
    self.progressLabel.hidden = YES;
    self.progressLabel.center = CGPointMake(GH_WIDTH / 2, GH_HEIGHT / 2 + 40);
    [self.view addSubview:self.transmitStatusLabel];
    self.transmitStatusLabel.hidden = YES;
    self.transmitStatusLabel.center = CGPointMake(GH_WIDTH / 2, GH_HEIGHT / 2 + 100);
    [self.view addSubview:self.fileNameLabel];
    self.fileNameLabel.hidden = YES;
    self.fileNameLabel.center = CGPointMake(GH_WIDTH / 2, GH_HEIGHT/2 + 150);
    
    [ receiver addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:NSKeyValueObservingOptionNew context:kCMReceiverResolveStatusContext];
    [ receiver addObserver:self forKeyPath:NSStringFromSelector(@selector(statusStr)) options:NSKeyValueObservingOptionNew context:kCMReceiverResolveStatusStringContext];
    [receiver addObserver:self forKeyPath:NSStringFromSelector(@selector(bigFileProgress)) options:NSKeyValueObservingOptionNew context:kCMReceiverResolveProgressContext];
    [receiver addObserver:self forKeyPath:NSStringFromSelector(@selector(transmitStr)) options:NSKeyValueObservingOptionNew context:kCMReceiverResolveTransmitContext];
    [receiver addObserver:self forKeyPath:NSStringFromSelector(@selector(currentFileName)) options:NSKeyValueObservingOptionNew context:kCMReceiverResolveFileContext];
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                        context:(void *)context {
    if (context == kCMReceiverResolveStatusContext) {
        CMSyncConnectStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == CMSyncConnectStatusConnected) {
            //链接成功，隐藏二维码
            self.qrCodeImageView.hidden = YES;
            self.statusLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 80);
            self.progressLabel.hidden = NO;
            self.transmitStatusLabel.hidden = NO;
            self.fileNameLabel.hidden = NO;
        }
    }
    else if (context == kCMReceiverResolveStatusStringContext) {
        NSString *statusStr = change[NSKeyValueChangeNewKey];
        self.statusLabel.text = statusStr;
    } else if (context == kCMReceiverResolveProgressContext) {
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        NSString *progressStr = [NSString stringWithFormat:@"传输进度:%.2f",progress];
        self.progressLabel.text = progressStr;
    } else if (context == kCMReceiverResolveTransmitContext) {
        NSString *transmitStatusStr = change[NSKeyValueChangeNewKey];
        self.transmitStatusLabel.text = transmitStatusStr;
    } else if (context == kCMReceiverResolveFileContext) {
        NSString *fileName = change[NSKeyValueChangeNewKey];
        self.fileNameLabel.text = fileName;
    }
}

- (void)dealloc {
    ReceiverResolveProtocolManager *receiver = [ReceiverResolveProtocolManager shared];
    [receiver removeObserver:self forKeyPath:NSStringFromSelector(@selector(statusStr)) context:kCMReceiverResolveStatusStringContext];
    [receiver removeObserver:self forKeyPath:NSStringFromSelector(@selector(bigFileProgress)) context:kCMReceiverResolveProgressContext];
    [receiver removeObserver:self forKeyPath:NSStringFromSelector(@selector(status)) context:kCMReceiverResolveStatusContext];
    [receiver removeObserver:self forKeyPath:NSStringFromSelector(@selector(transmitStr)) context:kCMReceiverResolveTransmitContext];
    [receiver removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentFileName)) context:kCMReceiverResolveFileContext];
}


@end
