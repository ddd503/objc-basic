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
#import "AleartTextModel.h"

@interface TaskListController () <UITableViewDelegate, UITextFieldDelegate, DatabaseDelegate, TaskListProviderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *taskListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *taskListRightToolbarButton;
@property (nonatomic) TaskListProvider *provider;
@property (nonatomic) Database *database;
@property (nonatomic) TaskListData *didTapCellData;
@property (strong, nonatomic) NSString *inputTaskName;
@property (nonatomic) AleartTextModel *aleartTextModel;
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
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"edit", @"編集");
    
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
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"done", @"完了");
        [self.taskListRightToolbarButton setTitle:NSLocalizedString(@"allDelete", @"すべて削除")];
    } else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"edit", @"編集");
        [self.taskListRightToolbarButton setTitle:NSLocalizedString(@"addTask", @"タスク追加")];
    }
}
- (void)taskListsAlertTextFieldDidChange:(UITextField *)sender {
    // 表示されているアラートコントローラーをインスタンス化
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *alertTextField = alertController.textFields.firstObject;
        UIAlertAction *saveAction = alertController.actions.lastObject;
        saveAction.enabled = (alertTextField.text.length == 0) ? NO : YES;
    }
}

#pragma mark - Aleart Methods
- (void)createTaskListAleart:(NSIndexPath *)didTapCellIndex {
    
    if (!didTapCellIndex) {
        self.didTapCellData = nil;
        self.aleartTextModel =
        [[AleartTextModel alloc]
         initWithAleartText:@""
         messege:NSLocalizedString(@"setTaskName", @"このタスクの名前を入力してください。")
         textFieldtext:@""
         textFieldPlaceFolder:NSLocalizedString(@"setTaskName", @"このタスクの名前を入力してください。")];
    } else {
        self.didTapCellData = self.provider.taskListDataList[didTapCellIndex.row];
        self.aleartTextModel =
        [[AleartTextModel alloc]
         initWithAleartText:self.didTapCellData.taskName
         messege:NSLocalizedString(@"setNewTaskName", @"このタスクの新しい名前を入力してください。")
         textFieldtext:self.didTapCellData.taskName
         textFieldPlaceFolder:NSLocalizedString(@"setTaskName", @"このタスクの名前を入力してください。")];
    }
    
    UIAlertController *taskNameAleartController =
    [UIAlertController
     alertControllerWithTitle:self.aleartTextModel.titleText
     message:self.aleartTextModel.messegeText
     preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelButton =
    [UIAlertAction
     actionWithTitle:NSLocalizedString(@"cancel", @"キャンセル")
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction *action)
    {
        self.inputTaskName = @"";
    }];
    
    UIAlertAction *saveButton =
    [UIAlertAction
     actionWithTitle:NSLocalizedString(@"save", @"保存")
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction *action)
    {
        if (self.inputTaskName.length == 0)
        {
            return;
        } else {
            // update用のメソッドに飛ばす（空なら消す）
            NSDate *updateDate = [NSDate date];
            if (!didTapCellIndex) {
                [self.database taskNameInsert:self.inputTaskName
                                    inputDate:updateDate
                                   folderData:self.didTapFolderData];
            } else {
                [self.database updateTaskList:self.inputTaskName
                                   updateDate:updateDate
                                       taskId:self.didTapCellData.taskId];
            }
        }
    }];
    
    [taskNameAleartController addAction:cancelButton];
    [taskNameAleartController addAction:saveButton];
    [taskNameAleartController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = self.aleartTextModel.textFieldPlaceFolder;
        textField.text = self.aleartTextModel.textFieldText;
        textField.delegate = self;
        [textField addTarget:self
                      action:@selector(taskListsAlertTextFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        
        BOOL checkTextLength = textField.text.length > 0;
        saveButton.enabled = checkTextLength;
    }
     ];
    
    [self presentViewController:taskNameAleartController animated:true completion:nil];
}

- (void)createTaskListAllDeleteActionSheet {
    UIAlertController *taskListAllDeleteActionSheet =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"削除")
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action) {
                               [self.database deleteAllTaskName:self.didTapFolderData];
                           }];
    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"キャンセル")
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    [taskListAllDeleteActionSheet addAction:deleteAction];
    [taskListAllDeleteActionSheet addAction:cancelAction];
    
    [self presentViewController:taskListAllDeleteActionSheet animated:true completion:nil];
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
        [self createTaskListAleart:indexPath];
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
    self.provider.taskListDataList =
    [self.database selectTaskList:self.didTapFolderData.folderId];
    
    self.taskListTableView.dataSource = self.provider;
    
    [self.taskListTableView reloadData];
}
- (void)deleteTaskListCell:(NSIndexPath *)index {
    self.provider.taskListDataList =
    [self.database selectTaskList:self.didTapFolderData.folderId];
    
    self.taskListTableView.dataSource = self.provider;
    
    [self.taskListTableView deleteRowsAtIndexPaths:@[index]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Action Methods
- (IBAction)editTaskList:(id)sender {
    if (self.taskListTableView.editing) {
        [self createTaskListAllDeleteActionSheet];
    } else {
        [self createTaskListAleart:nil];
    }
}

@end
