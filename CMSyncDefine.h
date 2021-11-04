//
//  CMSyncConstants.h
//  CMDataSync
//
//  Created by 潘绍森 on 2021/11/3.
//

#ifndef CMSyncConstants_h
#define CMSyncConstants_h

//用于描述TCP链接的状态
typedef enum : NSUInteger {
    CMSyncConnectStatusIdle,
    CMSyncConnectStatusConnectTimeout,
    CMSyncConnectStatusConnecting,
    CMSyncConnectStatusConnected,
    CMSyncConnectStatusConnectError,
} CMSyncConnectStatus;

typedef enum : NSUInteger {
    SyncStatusWaiting = 0,
    SyncStatusSending,
    SyncStatusComplete
} CMSyncTransmitStatus;


#endif /* CMSyncConstants_h */
