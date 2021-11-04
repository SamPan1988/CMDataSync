//
//  CMScanQRCodeVC.m
//  CMDataSync_Example
//
//  Created by HeQingliang on 2021/11/4.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import "CMScanQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>



@interface CMScanQRCodeVC ()<AVCaptureMetadataOutputObjectsDelegate>
@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;

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
    
    _device = [ AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [ AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    _output = [[ AVCaptureMetadataOutput alloc]init];
    [ _output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[ AVCaptureSession alloc]init];
    [ _session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([ _session canAddInput:self.input]) {
        [ _session addInput:self.input];
    }
    if ([ _session canAddOutput:self.output]) {
        [ _session addOutput:self.output];
    }
    
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    [ _output setRectOfInterest : self.view.bounds];
//    CGRectMake (( 50 )/ GH_HEIGHT ,(( GH_WIDTH - 220 )/ 2 )/ GH_WIDTH , 220 / GH_HEIGHT , 220 / GH_WIDTH )
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.view.layer.bounds;
    //    _preview.tor
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    [ _session startRunning ];
    
    
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self backAction];
}

#pragma mark - 取消按钮
-(void)backAction
{
    [ _session startRunning];
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:( AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] > 0 ) {
        // 停止扫描
        [ _session stopRunning ];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;

        if ([stringValue hasPrefix:@"QPen_"]) {
            NSLog(@"扫描结果：%@",stringValue);
            
//            SendViewController *vc = [SendViewController new];
//            vc.ip = [stringValue substringFromIndex:5];
//            [self.navigationController pushViewController:vc animated:YES];
        } else {
            NSLog(@"扫描到不符合规则的二维码：%@",stringValue);
            [self backAction];
        }
    }
}
@end
