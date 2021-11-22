//
//  NotebookModel.h
//  QPen
//
//  Created by Youzige on 2019/4/9.
//  Copyright © 2019 Tb. All rights reserved.
//

#import <Realm.h>

//@class APIPageModel;



NS_ASSUME_NONNULL_BEGIN

/**
 笔记本Model
 */
@interface NotebookModel : RLMObject


//@property (nonatomic, assign) NotebookLocation location;

/**
 用作笔记本的主键
 */
@property (nonatomic, copy) NSString * notebookID;

/**
 云端的笔记本ID，由服务器生成。
 为0表示未同步到服务器，需要添加到服务器
 大于0的表示已同步到云端。
 */
@property (nonatomic, assign) NSInteger cloudID;

/**
 笔记本的版本号
 */
@property (nonatomic, assign) NSInteger syncVersion;

/**
 云端笔记本的版本号。
 */
@property (nonatomic, assign) NSInteger remoteSyncVersion;

/**
 云端的信息
 */
//@property (nonatomic, strong) NSArray<APIPageModel*> * detailList;

/**
 创建日期，时间戳，
 */
@property (nonatomic, assign) NSTimeInterval  createDate;

/**
 上次打开的日期，时间戳
 */
@property (nonatomic, assign) NSTimeInterval lastOpenDate;

/**
 笔记本类型。相当于AFNode的book_no
 */
@property (nonatomic, assign) NSInteger notebookType;

/**
 笔记本的宽度。最大X值
 */
@property (nonatomic, assign) NSInteger notebookWidth;

/**
 笔记本的高度。最大Y值
 */
@property (nonatomic, assign) NSInteger notebookHeight;

/**
 笔记本的名字
 */
@property (nonatomic, copy) NSString * name;

/**
 云端笔记本的名字
 */
@property (nonatomic, copy) NSString * remoteName;

/**
 笔记本封面 1-16
 */
@property (nonatomic, copy) NSString * cover;

/**
 云端的封面
 */
@property (nonatomic, copy) NSString * remoteCover;
/**
 标签。标签之间用英文逗号隔开
 */
@property (nonatomic, strong) NSString * tags;

/**
 收藏的日期
 */
@property (nonatomic, assign) NSTimeInterval favoriteDate;

/**
 是否被删除
 */
@property (nonatomic, assign, getter=isDeleted) BOOL deleted;

/**
 排序索引
 */
@property (nonatomic, assign) NSInteger sortIndex;

@property (nonatomic, copy) NSString *attachment;

@end


NS_ASSUME_NONNULL_END
