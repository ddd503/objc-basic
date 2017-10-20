//
//  TaskListController.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/08.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "TaskListController.h"
#import "TaskListCell.h"
#import "TaskListProvider.h"
#import "TaskListData.h"
#import "Database.h"
#import "AleartHelper.h"

@interface TaskListController () <UITableViewDelegate, UITextFieldDelegate,
DatabaseDelegate, TaskListProviderDelegate, AlertHelperDelegate>
@property (weak, nonatomic) IBOutlet UITableView *taskListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *taskListRightToolbarButton;
@property (nonatomic) TaskListProvider *provider;
@property (nonatomic) Database *database;
@property (nonatomic) TaskListData *didTapCellData;
@property (nonatomic) AleartHelper *alearHelper;
@property (strong, nonatomic) NSString *inputTaskName;
@end

static CGFloat const estimatedCellHeight = 80;

@implementation TaskListController

#pragma mark - Lifecycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateTaskList];
}

#pragma mark - Private Methods
- (void)setup {
    [self setupTableView];
    /// ナビゲーションバーのタイトルを変更（フォルダ名に合わせて）
    self.navigationItem.title = self.didTapFolderData.folderName;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"edit", nil);
    
    self.database = [Database new];
    self.database.delegate = self;
}
- (void)setupTableView {
    
    UINib *nib = [UINib nibWithNibName:[TaskListCell taskListCellNibName] bundle:nil];
    [self.taskListTableView registerNib:nib
                 forCellReuseIdentifier:[TaskListCell taskListCellIdentifier]];
    
    self.taskListTableView.rowHeight = UITableViewAutomaticDimension;
    self.taskListTableView.estimatedRowHeight = estimatedCellHeight;
    
    self.provider = [TaskListProvider new];
    self.provider.delegate = self;
    self.provider.folderData = self.didTapFolderData;
    
    self.taskListTableView.delegate = self;
    self.taskListTableView.dataSource = self.provider;
}
- (void)reloadTaskListToolbar:(BOOL)editing {
    if (editing) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"done", nil);
        [self.taskListRightToolbarButton setTitle:NSLocalizedString(@"allDelete", nil)];
    } else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"edit", nil);
        [self.taskListRightToolbarButton setTitle:NSLocalizedString(@"addTask", nil)];
    }
}

#pragma mark - AleartHelperDelegate Methods
- (void)createTask:(NSString *) inputText {
    // insert
    [self.database taskNameInsert:inputText inputDate:[NSDate date] folderData:self.didTapFolderData];
}
- (void)editTask:(NSString *) inputText {
    // update
    [self.database updateTaskList:inputText updateDate:[NSDate date] taskId:self.didTapCellData.taskId];
}
- (void)deleteAllTask {
    // allDelete
    [self.database deleteAllTaskName:self.didTapFolderData];
}

#pragma mark - TableViewDelegate Methods
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    self.taskListTableView.editing = editing;
    [self reloadTaskListToolbar:editing];
    
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.taskListTableView.editing) {
        // 編集モード時のタップ
        self.didTapCellData = self.provider.taskListDataList[indexPath.row];
        
        self.alearHelper = [AleartHelper new];
        self.alearHelper.delegate = self;
        
        UIAlertController *editTaskAleart = [self.alearHelper createEditTaskAleart:self.didTapCellData.taskName
                                                                       placeholder:NSLocalizedString(@"setTaskName", nil)
                                                                        alertTitle:self.didTapCellData.taskName
                                                                      alertMessage:NSLocalizedString(@"setNewTaskName", nil)];
        
        [self presentViewController:editTaskAleart animated:YES completion:nil];

    } else {
        /// 編集中ではない時は選択を解除
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - TextFieldDelegate Methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.inputTaskName = textField.text;
}

#pragma mark - DatabaseDelegate Methods
- (void)updateTaskList {
    self.provider.taskListDataList = [self.database selectTaskList:self.didTapFolderData.folderId];
    
    self.taskListTableView.dataSource = self.provider;
    
    [self.taskListTableView reloadData];
}
- (void)deleteTaskListCell:(NSIndexPath *)index {
    self.provider.taskListDataList = [self.database selectTaskList:self.didTapFolderData.folderId];
    
    self.taskListTableView.dataSource = self.provider;
    
    [self.taskListTableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Action Methods
- (IBAction)editTaskList:(id)sender {
    
    self.alearHelper = [AleartHelper new];
    self.alearHelper.delegate = self;
    
    if (self.taskListTableView.editing) {
        UIAlertController *allTaskDeleteActionSheet = [self.alearHelper createAllDeleteTaskActionSheet];
        
        [self presentViewController:allTaskDeleteActionSheet animated:YES completion:nil];
    } else {
        UIAlertController *newTaskAleart = [self.alearHelper createNewTaskAleart:@""
                                                                     placeholder:NSLocalizedString(@"setTaskName", nil)
                                                                      alertTitle:@""
                                                                    alertMessage:NSLocalizedString(@"setTaskName", nil)];
        
        [self presentViewController:newTaskAleart animated:YES completion:nil];
    }
}

@end
