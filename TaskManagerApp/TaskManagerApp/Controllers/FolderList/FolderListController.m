//
//  FolderListController.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/08.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "FolderListController.h"
#import "FolderListCell.h"
#import "FolderListProvider.h"
#import "FolderListData.h"
#import "Database.h"
#import "TaskListController.h"

@interface FolderListController () <UITableViewDelegate, UITextFieldDelegate, DatabaseDelegate, FolderListProviderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *folderListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *folderListRightToolbarButton;
@property (nonatomic) FolderListProvider *provider;
@property (nonatomic) Database *database;
@property (strong, nonatomic) NSString *inputFolderName;
@end

static NSString *const moveStoryboardName = @"TaskList";

@implementation FolderListController

#pragma mark - Lifecycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateView];
}

#pragma mark - Private Methods
- (void)setup {
    [self setupTableView];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.title = [NSBundle.mainBundle localizedStringForKey:@"edit" value:nil table:@"Localizable"];
    // テーブル作成とデリゲートオン
    self.database = [[Database alloc] init];
    self.database.delegate = self;
}
- (void)setupTableView {
    UINib *nib = [UINib nibWithNibName:[FolderListCell folderListCellNibName] bundle:nil];
    [self.folderListTableView registerNib:nib forCellReuseIdentifier:[FolderListCell folderListCellIdentifier]];
    // 高さ自動化と基準の高さ
    self.folderListTableView.rowHeight = UITableViewAutomaticDimension;
    self.folderListTableView.estimatedRowHeight = 80;
    
    self.provider = [[FolderListProvider alloc] init];
    self.provider.delegate = self;
    
    self.folderListTableView.delegate = self;
    
    
}
- (void)reloadFolderListToolbar:(BOOL)editing {
    if (editing) {
        self.navigationItem.rightBarButtonItem.title = [NSBundle.mainBundle localizedStringForKey:@"done" value:nil table:@"Localizable"];
        [self.folderListRightToolbarButton setTitle:[NSBundle.mainBundle localizedStringForKey:@"allDelete" value:nil table:@"Localizable"]];
    } else {
        self.navigationItem.rightBarButtonItem.title = [NSBundle.mainBundle localizedStringForKey:@"edit" value:nil table:@"Localizable"];
        [self.folderListRightToolbarButton setTitle:[NSBundle.mainBundle localizedStringForKey:@"newFolder" value:nil table:@"Localizable"]];
    }
}

#pragma mark - Aleart Methods
- (void)createNewFolderNameAleart {
    UIAlertController *newFolderNameAleartController = [UIAlertController
                                                        alertControllerWithTitle:@""
                                                        message:[NSBundle.mainBundle localizedStringForKey:@"setFolderName" value:nil table:@"Localizable"]
                                                        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"cancel" value:nil table:@"Localizable"]
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       self.inputFolderName = @"";
                                   }];
    UIAlertAction *saveButton = [UIAlertAction
                                 actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"save" value:nil table:@"Localizable"]
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     if (self.inputFolderName.length == 0) {
                                         return;
                                     }
                                     NSDate *inputDate = [NSDate date];
                                     [self.database folderNameInsert:self.inputFolderName inputDate:inputDate];
                                 }];
    
    // 用意したボタンアクション２つをアラートコントローラーにセット
    [newFolderNameAleartController addAction:cancelButton];
    [newFolderNameAleartController addAction:saveButton];
    [newFolderNameAleartController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [NSBundle.mainBundle localizedStringForKey:@"setFolderName" value:nil table:@"Localizable"];
        textField.delegate = self;
    }
     ];
    [self presentViewController:newFolderNameAleartController animated:true completion:nil];
    
}

- (void)createEditFolderNameAleart:(NSIndexPath *)didTapCellIndex {
    FolderListData *didTapCellData = self.provider.folderListDataList[didTapCellIndex.row];
    
    UIAlertController *editFolderNameAleartController = [UIAlertController
                                                         alertControllerWithTitle:didTapCellData.folderName
                                                         message:[NSBundle.mainBundle localizedStringForKey:@"setNewFolderName" value:nil table:@"Localizable"]
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"cancel" value:nil table:@"Localizable"]
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       self.inputFolderName = @"";
                                   }];
    UIAlertAction *saveButton = [UIAlertAction
                                 actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"save" value:nil table:@"Localizable"]
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     if (self.inputFolderName.length == 0) {
                                         [self.database deleteFolderId:didTapCellData.folderId index:didTapCellIndex folderName:didTapCellData.folderName];
                                         NSLog(@"編集後のテキストが空だったためフォルダを削除しました。");
                                     } else {
                                         NSDate *updateDate = [NSDate date];
                                         [self.database updateFolderList:self.inputFolderName updateDate:updateDate editFolderData:didTapCellData];
                                     }
                                 }];
    
    saveButton.enabled = NO;
    
    [editFolderNameAleartController addAction:cancelButton];
    [editFolderNameAleartController addAction:saveButton];
    
    [editFolderNameAleartController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [NSBundle.mainBundle localizedStringForKey:@"setFolderName" value:nil table:@"Localizable"];
        textField.text = didTapCellData.folderName;
        textField.delegate = self;
    }
     ];
    [self presentViewController:editFolderNameAleartController animated:true completion:nil];
}

- (void)createFolderListAllDeleteActionSheet {
    UIAlertController *folderListAllDeleteActionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                                            message:nil
                                                                                     preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"delete" value:nil table:@"Localizable"]
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action) {
                                                             [self.database deleteAllFolderName];
                                                         }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle.mainBundle localizedStringForKey:@"cancel" value:nil table:@"Localizable"]
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [folderListAllDeleteActionSheet addAction:deleteAction];
    [folderListAllDeleteActionSheet addAction:cancelAction];
    
    [self presentViewController:folderListAllDeleteActionSheet animated:true completion:nil];
}

#pragma mark - TableViewDelegate Methods
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    // ここの意味を知りたい（押すと編集モードが切り替わる理由がわからない）
    self.folderListTableView.editing = editing;
    [self reloadFolderListToolbar:editing];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.folderListTableView.editing) {
        [self createEditFolderNameAleart:indexPath];
    } else {
        UIStoryboard *taskListStoryboard = [UIStoryboard storyboardWithName:moveStoryboardName bundle:nil];
        TaskListController *taskListController = [taskListStoryboard instantiateInitialViewController];
        
        taskListController.didTapFolderData = self.provider.folderListDataList[indexPath.row];
        
        [self.navigationController pushViewController:taskListController animated:YES];
    }
}

#pragma mark - TextFieldDelegate Methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.inputFolderName = textField.text;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // テキストフィールドが空欄かどうかチェック
    if (textField.text.length == 0) {
        // ここでアラートアクションボタンを押せるようにしたい
    }
    return YES;
}

#pragma mark - DatabaseDelegate Methods
- (void)updateView {
    self.provider.folderListDataList = [self.database selectFolderList];
    self.folderListTableView.dataSource = self.provider;
    [self.folderListTableView reloadData];
}

#pragma mark - FolderListProviderDelegate Methods
- (void)deleteTableViewCell:(NSIndexPath *)index {
    self.provider.folderListDataList = [self.database selectFolderList];
    self.folderListTableView.dataSource = self.provider;
    [self.folderListTableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Action Methods
- (IBAction)editFolderList:(id)sender {
    if (self.folderListTableView.editing) {
        [self createFolderListAllDeleteActionSheet];
    } else {
        [self createNewFolderNameAleart];
    }
}
@end
