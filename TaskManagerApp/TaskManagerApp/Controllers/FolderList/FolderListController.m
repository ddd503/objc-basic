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
#import "AleartTextModel.h"

@interface FolderListController () <UITableViewDelegate, UITextFieldDelegate,
DatabaseDelegate, FolderListProviderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *folderListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *folderListRightToolbarButton;
@property (nonatomic) FolderListProvider *provider;
@property (nonatomic) Database *database;
@property (nonatomic) FolderListData *didTapCellData;
@property (nonatomic) AleartTextModel *aleartTextModel;
@property (strong, nonatomic) NSString *inputFolderName;
@end

static NSString *const moveStoryboardName = @"TaskList";
static CGFloat const estimatedCellHeight = 80;

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
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"edit", @"編集");
    // テーブル作成とデリゲートオン
    self.database = [Database new];
    self.database.delegate = self;
}

- (void)setupTableView {
    UINib *nib = [UINib nibWithNibName:[FolderListCell folderListCellNibName] bundle:nil];
    [self.folderListTableView registerNib:nib
                   forCellReuseIdentifier:[FolderListCell folderListCellIdentifier]];

    self.folderListTableView.rowHeight = UITableViewAutomaticDimension;
    self.folderListTableView.estimatedRowHeight = estimatedCellHeight;
    
    self.provider = [FolderListProvider new];
    self.provider.delegate = self;
    
    self.folderListTableView.delegate = self;
}

- (void)reloadFolderListToolbar:(BOOL)editing {
    if (editing) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"done", @"完了");
        [self.folderListRightToolbarButton setTitle:NSLocalizedString(@"allDelete", @"すべて削除")];
    } else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"edit", @"編集");
        [self.folderListRightToolbarButton setTitle:NSLocalizedString(@"newFolder", @"新規フォルダ")];
    }
}

- (void)folderListsAlertTextFieldDidChange:(UITextField *)sender {
    // 表示されているアラートコントローラーをインスタンス化
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        NSLog(@"走った");
        UITextField *alertTextField = alertController.textFields.firstObject;
        UIAlertAction *saveAction = alertController.actions.lastObject;
        saveAction.enabled = (alertTextField.text.length == 0) ? NO : YES;
    }
}

#pragma mark - Aleart Methods
- (void)createFolderListAleart:(NSIndexPath *)didTapCellIndex {
    
    if (!didTapCellIndex) {
        self.didTapCellData = nil;
        self.aleartTextModel =
        [[AleartTextModel alloc]
         initWithAleartText:@""
         messege:NSLocalizedString(@"setFolderName", @"このフォルダの名前を入力してください。")
         textFieldtext:@""
         textFieldPlaceFolder:NSLocalizedString(@"setFolderName", @"このフォルダの名前を入力してください。")];
    } else {
        self.didTapCellData = self.provider.folderListDataList[didTapCellIndex.row];
        self.aleartTextModel =
        [[AleartTextModel alloc]
         initWithAleartText:self.didTapCellData.folderName
         messege:NSLocalizedString(@"setNewFolderName", @"このフォルダの新しい名前を入力してください。")
         textFieldtext:self.didTapCellData.folderName
         textFieldPlaceFolder:NSLocalizedString(@"setFolderName", @"このフォルダの名前を入力してください。")];
    }
    
    UIAlertController *folderNameAleartController =
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
        self.inputFolderName = @"";
    }];
    
    UIAlertAction *saveButton =
    [UIAlertAction
     actionWithTitle:NSLocalizedString(@"save", @"保存")
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction *action)
    {
        if (self.inputFolderName.length == 0) {
            return;
        } else {
            NSDate *updateDate = [NSDate date];
            if (!didTapCellIndex) {
                [self.database folderNameInsert:self.inputFolderName
                                      inputDate:updateDate];
            } else {
                [self.database updateFolderList:self.inputFolderName
                                     updateDate:updateDate
                                 editFolderData:self.didTapCellData];
            }
        }
    }];
    
    [folderNameAleartController addAction:cancelButton];
    [folderNameAleartController addAction:saveButton];
    
    [folderNameAleartController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = self.aleartTextModel.textFieldPlaceFolder;
        textField.text = self.aleartTextModel.textFieldText;
        textField.delegate = self;
        // プロパティとしてUIAleartControllerを用意していないため、NSNotificationCenterは使用しない。
        [textField addTarget:self
                      action:@selector(folderListsAlertTextFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        
        BOOL checkTextLength = textField.text.length > 0;
        saveButton.enabled = checkTextLength;
    }
     ];
    
    [self presentViewController:folderNameAleartController animated:true completion:nil];
}

- (void)createFolderListAllDeleteActionSheet {
    UIAlertController *folderListAllDeleteActionSheet =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"削除")
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action) {
                               [self.database deleteAllFolderName];
                           }];
    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"キャンセル")
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    [folderListAllDeleteActionSheet addAction:deleteAction];
    [folderListAllDeleteActionSheet addAction:cancelAction];
    
    [self presentViewController:folderListAllDeleteActionSheet animated:true completion:nil];
}

#pragma mark - TableViewDelegate Methods
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    self.folderListTableView.editing = editing;
    [self reloadFolderListToolbar:editing];
    
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.folderListTableView.editing) {
        
        [self createFolderListAleart:indexPath];
        
    } else {
        
        UIStoryboard *taskListStoryboard =
        [UIStoryboard storyboardWithName:moveStoryboardName bundle:nil];
        
        TaskListController *taskListController =
        [taskListStoryboard instantiateInitialViewController];
        
        taskListController.didTapFolderData = self.provider.folderListDataList[indexPath.row];
        
        [self.navigationController pushViewController:taskListController animated:YES];
    }
}

#pragma mark - TextFieldDelegate Methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.inputFolderName = textField.text;
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
        [self createFolderListAleart:nil];
    }
}
@end
