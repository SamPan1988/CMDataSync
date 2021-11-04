//
//  CMViewController.m
//  CMDataSync
//
//  Created by panshaosen on 11/02/2021.
//  Copyright (c) 2021 panshaosen. All rights reserved.
//

#import "CMViewController.h"
#import "CMRevQRCodeVC.h"
#import "CMScanQRCodeVC.h"

@interface CMViewController ()
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *revButton;

@end

@implementation CMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.title = @"数据传输";
    
    self.sendButton.layer.cornerRadius = 5;
    self.sendButton.layer.masksToBounds = YES;
    self.revButton.layer.cornerRadius = 5;
    self.revButton.layer.masksToBounds = YES;
}

- (void)initSendData {
    //初始化发送方沙盒数据
    NSFileManager *fm = [NSFileManager defaultManager];
    NSData *noteData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"]];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"notebook"];
    NSLog(@"Document:%@", path);
    [fm removeItemAtPath:path error:nil];
    [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    NSInteger phone = 13802880001;
    for (NSInteger i=0; i<5; i++) {
        NSString *subPath = [NSString stringWithFormat:@"%@/%ld", path, phone];
        [fm createDirectoryAtPath:subPath withIntermediateDirectories:YES attributes:nil error:nil];
        for (NSInteger j=0; j<5; j++) {
            NSTimeInterval notebook = [[NSDate date] timeIntervalSince1970]*1000*1000;
            NSString *notebookPath = [NSString stringWithFormat:@"%@/%.0lf", subPath, notebook];
            [fm createDirectoryAtPath:notebookPath withIntermediateDirectories:YES attributes:nil error:nil];
            for (NSInteger k=1; k<16; k++) {
                NSString *page = [NSString stringWithFormat:@"%03ld", k];
                NSString *pagePath = [NSString stringWithFormat:@"%@/%@",notebookPath, page];
                [fm createDirectoryAtPath:pagePath withIntermediateDirectories:YES attributes:nil error:nil];
                NSString *filePath = [NSString stringWithFormat:@"%@/%03ld.txt", pagePath, k];
                [fm createFileAtPath:filePath contents:noteData attributes:nil];
            }
        }
        phone += 1;
    }
}

- (void)initRevData {
    //初始化接收方沙盒数据
    //清空数据
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"notebook"];
    NSLog(@"Document:%@", path);
    [fm removeItemAtPath:path error:nil];
    
    //覆盖数据
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Action

- (IBAction)sendBtnAction:(id)sender {
    [self initSendData];
    CMScanQRCodeVC *vc = [[CMScanQRCodeVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)revBtnAction:(id)sender {
    [self initRevData];
    CMRevQRCodeVC *vc = [[CMRevQRCodeVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
