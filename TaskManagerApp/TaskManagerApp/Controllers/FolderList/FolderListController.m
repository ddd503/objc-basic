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
#import "AleartHelper.h"

@interface FolderListController () <UITableViewDelegate, UITextFieldDelegate,
DatabaseDelegate, FolderListProviderDelegate, AlertHelperDelegate>
@property (weak, nonatomic) IBOutlet UITableView *folderListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *folderListRightToolbarButton;
@property (nonatomic) FolderListProvider *provider;
@property (nonatomic) Database *database;
@property (nonatomic) FolderListData *didTapCellData;
@property (nonatomic) AleartHelper *alearHelper;
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
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"edit", @"hoge");
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
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"done", @"hoge");
        [self.folderListRightToolbarButton setTitle:NSLocalizedString(@"allDelete", @"hoge")];
    } else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"edit", @"hoge");
        [self.folderListRightToolbarButton setTitle:NSLocalizedString(@"newFolder", @"hoge")];
    }
}

#pragma mark - AleartHelperDelegate Methods
- (void)createFolder:(NSString *) inputText {
    // insert
    [self.database folderNameInsert:inputText inputDate:[NSDate date]];
}
- (void)editFolder:(NSString *) inputText {
    // update
    [self.database updateFolderList:inputText
                         updateDate:[NSDate date]
                     editFolderData:self.didTapCellData];
}
- (void)deleteAllFolder {
    // allDelete
    [self.database deleteAllFolderName];
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
        // 編集モード時のタップ
        self.didTapCellData = self.provider.folderListDataList[indexPath.row];
        
        self.alearHelper = [AleartHelper new];
        self.alearHelper.delegate = self;
        
        UIAlertController *editFolderAleart = [self.alearHelper createEditFolderAleart:self.didTapCellData.folderName
                                                                           placeholder:NSLocalizedString(@"setFolderName", @"hoge")
                                                                            alertTitle:self.didTapCellData.folderName
                                                                          alertMessage:NSLocalizedString(@"setNewFolderName", @"hoge")];
        [self presentViewController:editFolderAleart animated:YES completion:nil];

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
    
    self.alearHelper = [AleartHelper new];
    self.alearHelper.delegate = self;
    
    if (self.folderListTableView.editing) {
        UIAlertController *allDeleteFolderActionSheet = [self.alearHelper createAllDeleteFolderActionSheet];
        [self presentViewController:allDeleteFolderActionSheet animated:YES completion:nil];
        
    } else {
        UIAlertController *newFolderAleart = [self.alearHelper createNewFolderAleart:@""
                                                                         placeholder:NSLocalizedString(@"setFolderName", @"hoge")
                                                                          alertTitle:@""
                                                                        alertMessage:NSLocalizedString(@"setFolderName", @"hoge")];
        
        [self presentViewController:newFolderAleart animated:YES completion:nil];
    }
}
@end
