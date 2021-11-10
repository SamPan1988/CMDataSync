//
//  SendDataView.m
//  QPen
//
//  Created by XW Mac on 2020/8/31.
//  Copyright © 2020 Tb. All rights reserved.
//

#import "SelectNotebookViewController.h"


@interface SelectNotebookViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,strong) UIButton *sendButton;
@property (nonatomic,strong) UIButton *selectAllButton;

@property (nonatomic,copy) NSMutableSet <NSIndexPath *>*selectedIndexPaths;
@end

@implementation SelectNotebookViewController


#pragma mark - init


- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedIndexPaths = [NSMutableSet new];
    [self initUI];
}

- (void)initUI {
    UIView *tipsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GH_WIDTH, 40)];
    tipsView.backgroundColor = [UIColor colorWithRGB:0xF4F4F4];
    [self.view addSubview:tipsView];
    
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, GH_WIDTH-10, 40)];
    tipsLabel.text = @"请确认发送的数据是否相同，相同的数据将会覆盖。";
    tipsLabel.numberOfLines = 2;
    tipsLabel.font = [UIFont systemFontOfSize:12];
    [tipsView addSubview:tipsLabel];
    
    self.mainTableView.frame = CGRectMake(0, 40, GH_WIDTH, GH_HEIGHT - 40 - 64);
    [self.view addSubview:self.mainTableView];
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, GH_HEIGHT - 64 - 80, GH_WIDTH, 80)];
    bottomView.backgroundColor = [UIColor colorWithRGB:0xF3F3F3];
    [self.view addSubview:bottomView];
    
    _selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectAllButton.frame = CGRectMake(0, 0, GH_WIDTH/2, 40);
    [_selectAllButton setTitle:@"全选" forState:UIControlStateNormal];
    [_selectAllButton setTitleColor:[UIColor colorWithRGB:0x02C2A0] forState:UIControlStateNormal];
    [_selectAllButton addTarget:self action:@selector(selectAllAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_selectAllButton];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectAllButton.frame = CGRectMake(GH_WIDTH/2, 0, GH_WIDTH/2, 40);
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor colorWithRGB:0x02C2A0] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton setImage:[UIImage imageNamed:@"sync_notebook_send"] forState:UIControlStateNormal];
    _sendButton.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    [bottomView addSubview:_sendButton];
}

-(void)selectAllAction {
    if (_selectedIndexPaths.count == _notebookListData.count) {
        return;
    }
    for (int i=0; i<_notebookListData.count; i++) {
        [_selectedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [_mainTableView reloadData];
    if (_selectedIndexPaths.count > 0) {
        [_sendButton setTitle:[NSString stringWithFormat:@"%@(%zd)",@"发送",_selectedIndexPaths.count] forState:UIControlStateNormal];
    } else {
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    }
}

-(void)sendButtonAction {
    if (_selectedIndexPaths.count == 0) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(sendDataTable:selectedNotebooks:)]) {
        [_delegate sendDataTable:self selectedNotebooks:self.selectedNotebooks];
    }
}


//MARK: - ------ UITableViewDelegate & UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _notebookListData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellc"];
    UIImageView *accessView;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellc"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        accessView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sync_notebook_unselect"]];
        accessView.tag = 888;
        cell.accessoryView = accessView;
        
    } else {
        accessView = (UIImageView *)[cell accessoryView];
    }
    
    NotebookModel *model = _notebookListData[indexPath.row];
    cell.textLabel.text = model.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        accessView.image = [UIImage imageNamed: @"sync_notebook_selected"];
    } else {
        accessView.image = [UIImage imageNamed: @"sync_notebook_unselect"];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_selectedIndexPaths containsObject:indexPath]) {
        [_selectedIndexPaths removeObject:indexPath];
    } else {
        [_selectedIndexPaths addObject:indexPath];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if (_selectedIndexPaths.count > 0) {
        [_sendButton setTitle:[NSString stringWithFormat:@"%@(%zd)",@"发送",_selectedIndexPaths.count] forState:UIControlStateNormal];
    } else {
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

-(UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
    }
    return _mainTableView;
}

- (void)setNotebookListData:(NSArray<NotebookModel *> *)notebookListData {
    _notebookListData = notebookListData;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainTableView reloadData];
    });
}

-(NSArray *)selectedNotebooks {
    NSMutableArray *array = [NSMutableArray new];
    for (NSIndexPath *indexPath in _selectedIndexPaths) {
        [array addObject:_notebookListData[indexPath.row]];
    }
    return array;
}

-(void)dealloc {
    NSLog(@"dealloc %@",NSStringFromClass(self.class));
}

@end
