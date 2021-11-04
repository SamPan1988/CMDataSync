//
//  CMSyncSendManager.m
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/3.
//

#import "CMSyncConnectManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface CMSyncConnectManager()
/// 当前网络连接状态
@property (nonatomic, assign) CMSyncConnectStatus connectStatus;
@property (nonatomic, weak) id <CMSyncResolveProtocol> resolveDelegate;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) uint16_t port;
@end

@implementation CMSyncConnectManager

+ (instancetype) shared {
    dispatch_once_t connectToken;
    static CMSyncConnectManager *shared;
    dispatch_once(&connectToken, ^{
        shared = [[CMSyncConnectManager alloc] init];
    });
    return shared;
}

- (void) startConnectWithHost:(NSString *) host
                         port:(uint16_t) port
              resolveProtocol:(id <CMSyncResolveProtocol> ) resolveProtocol {
    
}

- (NSString *) startWaitingForConnectOnPort:(uint16_t) port
                            resolveProtocol:(id <CMSyncResolveProtocol>) resolveProtocol
                                      error:(NSError * *) error {
    NSString *selfAdress;
    return selfAdress;
}

- (void) stopConnect {
    
}

- (void) sendData:(NSData *) data {
    
}

@end
