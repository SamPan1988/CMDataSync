//
//  SendDataView.h
//  QPen
//
//  Created by XW Mac on 2020/8/31.
//  Copyright © 2020 Tb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotebookModel.h"

@class SelectNotebookViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol SelectNotebookViewDelegate <NSObject>

-(void)sendDataTable:(SelectNotebookViewController *)table selectedNotebooks:(NSArray<NotebookModel *> *)selectedNotebooks;

@end

@interface SelectNotebookViewController : UIViewController

@property (nonatomic,weak) id<SelectNotebookViewDelegate> delegate;

/**
 要显示的笔记本列表
 * 不要使用”->“语法赋值。
 */
@property (nonatomic, strong) NSArray<NotebookModel*> *notebookListData;

/**
 readonly. 选择模式下，选中的笔记本。
 */
@property (nonatomic, strong, readonly) NSArray<NotebookModel *> *selectedNotebooks;



@end


NS_ASSUME_NONNULL_END
