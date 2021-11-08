//
//  QRCodeServiceManager.m
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/8.
//

#import "QRCodeServiceManager.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeServiceManager()<AVCaptureMetadataOutputObjectsDelegate>
@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) CMScanComplete scanComplete;
@end

@implementation QRCodeServiceManager

- (void) startToScanWithView:(UIView *) view
                    complete:(CMScanComplete) scanComplete {
    self.scanComplete = scanComplete;
    
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
    [ _output setRectOfInterest : view.bounds];
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = view.layer.bounds;
    [view.layer insertSublayer:_preview atIndex:0];
    [ _session startRunning ];
}

//生成二维码
- (UIImage *)generateQRCodeWithString:(NSString *)string Size:(CGFloat)size
{
    //创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //过滤器恢复默认
    [filter setDefaults];
    //给过滤器添加数据<字符串长度893>
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:data forKey:@"inputMessage"];
    //获取二维码过滤器生成二维码
    CIImage *image = [filter outputImage];
    UIImage *img = [self createNonInterpolatedUIImageFromCIImage:image WithSize:size];
    return img;
}

//二维码清晰
- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image WithSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    //创建bitmap
    size_t width = CGRectGetWidth(extent)*scale;
    size_t height = CGRectGetHeight(extent)*scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //保存图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
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
        if (self.scanComplete) {
            self.scanComplete(stringValue);
        }
    }
}


@end
