//
//  NotebookModel.m
//  QPen
//
//  Created by Youzige on 2019/4/9.
//  Copyright © 2019 Tb. All rights reserved.
//

#import "NotebookModel.h"

@implementation NotebookModel


+ (NSArray<NSString *> *)ignoredProperties {
    return @[@"location", @"detailList", @"remoteSyncVersion", @"remoteName", @"remoteCover"];
}

+ (NSString *)primaryKey {
    return @"notebookID";
}

@end


