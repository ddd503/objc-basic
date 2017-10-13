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
#import "Database.h"

@interface TaskListController () <UITableViewDelegate, UITextFieldDelegate, DatabaseDelegate, TaskListProviderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *taskListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *taskListRightToolbarButton;
@property (nonatomic) TaskListProvider *provider;
@property (nonatomic) Database *database;
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
    self.navigationItem.rightBarButtonItem.title = [NSBundle.mainBundle localizedStringForKey:@"edit" value:nil table:@"Localizable"];
    self.database = [[Database alloc] init];
    self.database.delegate = self;
}
- (void)setupTableView {
    UINib *nib = [UINib nibWithNibName:[TaskListCell taskListCellNibName] bundle:nil];
    [self.taskListTableView registerNib:nib forCellReuseIdentifier:[TaskListCell taskListCellIdentifier]];
    
    self.taskListTableView.rowHeight = UITableViewAutomaticDimension;
    self.taskListTableView.estimatedRowHeight = estimatedCellHeight;
    
    self.provider = [[TaskListProvider alloc] init];
    self.provider.delegate = self;
    self.provider.folderData = self.didTapFolderData;
    
    self.taskListTableView.delegate = self;
    self.taskListTableView.dataSource = self.provider;
}
- (void)reloadTaskListToolbar:(BOOL)editing {
    if (editing) {
        self.navigationItem.rightBarButtonItem.title = [NSBundle.mainBundle localizedStringForKey:@"done" value:nil table:@"Localizable"];
        [self.taskListRightToolbarButton setTitle:[NSBundle.mainBundle localizedStringForKey:@"allDelete" value:nil table:@"Localizable"]];
    } else {
        self.navigationItem.rightBarButtonItem.title = [NSBundle.mainBundle localizedStringForKey:@"edit" value:nil table:@"Localizable"];
        [self.taskListRightToolbarButton setTitle:[NSBundle.mainBundle localizedStringForKey:@"addTask" value:nil table:@"Localizable"]];
    }
}

#pragma mark - Aleart Methods
- (void)createNewTaskNameAleart {
    UIAlertController *newTaskNameAleartController = [UIAlertController
                                                      alertControllerWithTitle:@""
                                                      message:[NSBundle.mainBundle localizedStringForKey:@"setTaskName" value:nil table:@"Localizable"]
                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"cancel" value:nil table:@"Localizable"]
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       self.inputTaskName = @"";
                                   }];
    UIAlertAction *saveButton = [UIAlertAction
                                 actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"save" value:nil table:@"Localizable"]
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     if (self.inputTaskName.length == 0) {
                                         return;
                                     }
                                     NSDate *inputDate = [NSDate date];
                                     [self.database taskNameInsert:self.inputTaskName inputDate:inputDate folderData:self.didTapFolderData];
                                 }];
    [newTaskNameAleartController addAction:cancelButton];
    [newTaskNameAleartController addAction:saveButton];
    [newTaskNameAleartController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [NSBundle.mainBundle localizedStringForKey:@"setTaskName" value:nil table:@"Localizable"];
        textField.delegate = self;
    }
     ];
    [self presentViewController:newTaskNameAleartController animated:true completion:nil];
    
}

- (void)createEditTaskNameAleart:(NSIndexPath *)didTapCellIndex {
    TaskListData *didTapCellData = self.provider.taskListDataList[didTapCellIndex.row];
    
    UIAlertController *editTaskNameAleartController = [UIAlertController
                                                       alertControllerWithTitle:didTapCellData.taskName
                                                       message:[NSBundle.mainBundle localizedStringForKey:@"setNewTaskName" value:nil table:@"Localizable"]
                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"cancel" value:nil table:@"Localizable"]
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       self.inputTaskName = @"";
                                   }];
    
    UIAlertAction *saveButton = [UIAlertAction
                                 actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"save" value:nil table:@"Localizable"]
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     // ここからテキストを送って
                                     if (self.inputTaskName.length == 0) {
                                         [self.database deleteTaskId:didTapCellData folderData:self.didTapFolderData index:didTapCellIndex];
                                         NSLog(@"編集後のテキストが空だったためタスクを削除しました。");
                                     } else {
                                         // update用のメソッドに飛ばす（空なら消す）
                                         NSDate *updateDate = [NSDate date];
                                         [self.database updateTaskList:self.inputTaskName updateDate:updateDate taskId:didTapCellData.taskId];
                                     }
                                 }];
    [editTaskNameAleartController addAction:cancelButton];
    [editTaskNameAleartController addAction:saveButton];
    [editTaskNameAleartController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [NSBundle.mainBundle localizedStringForKey:@"setTaskName" value:nil table:@"Localizable"];
        textField.text = didTapCellData.taskName;
        textField.delegate = self;
    }
     ];
    [self presentViewController:editTaskNameAleartController animated:true completion:nil];
    
}

- (void)createTaskListAllDeleteActionSheet {
    UIAlertController *taskListAllDeleteActionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                                          message:nil
                                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"delete" value:nil table:@"Localizable"]
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action) {
                                                             [self.database deleteAllTaskName:self.didTapFolderData];
                                                         }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"cancel" value:nil table:@"Localizable"]
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [taskListAllDeleteActionSheet addAction:deleteAction];
    [taskListAllDeleteActionSheet addAction:cancelAction];
    
    [self presentViewController:taskListAllDeleteActionSheet animated:true completion:nil];
}

#pragma mark - TableViewDelegate Methods
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    /// fixMe ここの意味を知りたい（押すと編集モードが切り替わる理由がわからない）
    self.taskListTableView.editing = editing;
    [self reloadTaskListToolbar:editing];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.taskListTableView.editing) {
        [self createEditTaskNameAleart:indexPath];
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
    self.provider.taskListDataList = [self.database selectTaskList:self.didTapFolderData.folderName];
    self.taskListTableView.dataSource = self.provider;
    [self.taskListTableView reloadData];
}
- (void)deleteTaskListCell:(NSIndexPath *)index {
    self.provider.taskListDataList = [self.database selectTaskList:self.didTapFolderData.folderName];
    self.taskListTableView.dataSource = self.provider;
    [self.taskListTableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Action Methods
- (IBAction)editTaskList:(id)sender {
    if (self.taskListTableView.editing) {
        [self createTaskListAllDeleteActionSheet];
    } else {
        [self createNewTaskNameAleart];
    }
}

@end
