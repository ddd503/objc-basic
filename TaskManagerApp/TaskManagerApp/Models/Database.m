//
//  Database.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/09.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "Database.h"

@interface Database ()

@end

@implementation Database

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"init");
        self.db = [[FMDatabase alloc] initWithPath:[Database dbPath]];
#if DEBUG
        /// デバッグ時のみSQLiteの実行をトレースする
        ///self.db.traceExecution = YES;
#endif
        /// テーブルがなければ作る
        [self createFolderListTable];
        [self createTaskListTable];
    }
    return self;
}

+ (NSString *)dbPath {
    return [[self documentsDirectory] stringByAppendingPathComponent:@"database.db"];
}

+ (NSString *)documentsDirectory {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

#pragma mark - FolderList Method
- (BOOL)createFolderListTable {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS FolderList (folderId INTEGER PRIMARY KEY AUTOINCREMENT, folderName TEXT ,updateDate DATE ,tasks INTEGER )";
    
    BOOL result = NO;
    
    [self.db open];
    result = [self.db executeUpdate:sql];
    [self.db close];
    return result;
}

- (BOOL)folderNameInsert:(NSString *)inputFolderName inputDate:(NSDate *)inputDate {
    NSString *sql = @"INSERT INTO FolderList(folderName, updateDate) VALUES(?, ?)";
    
    BOOL result = NO;
    
    [self.db open];
    [self.db executeUpdate:sql, inputFolderName, inputDate];
    [self.db close];
    
    if ([self.delegate respondsToSelector:@selector(updateView)]) {
        [self.delegate updateView];
    }
    
    return result;
}

- (NSArray<FolderListData *> *)selectFolderList {
    NSString *sql = @"SELECT * FROM FolderList ORDER BY updateDate DESC";
    NSMutableArray<FolderListData *>* resultArray = [@[] mutableCopy];
    
    [self.db open];
    FMResultSet *results = [self.db executeQuery:sql];
    while ([results next]) {
        FolderListData *folderListDataObject = [[FolderListData alloc] initWithFMResultSetFolderListCellData:results];
        [resultArray addObject:folderListDataObject];
    }
    [self.db close];
    return resultArray;
}

- (BOOL)updateFolderList:(NSString *)inputFolderName updateDate:(NSDate *)updateDate editFolderData:(FolderListData *)editFolderData {
    
    NSString* sql = @"UPDATE FolderList SET folderName = :FOLDERNAME, updateDate = :UPDATEDATE, tasks = :TASKS WHERE folderId = :FOLDERID";
    
    NSDictionary<NSString *, id> *params = @{@"FOLDERNAME": inputFolderName,
                                             @"UPDATEDATE": updateDate,
                                             @"TASKS": @(editFolderData.tasks),
                                             @"FOLDERID": @(editFolderData.folderId)};
    
    BOOL result = NO;
    
    [self.db open];
    result = [self.db executeUpdate:sql withParameterDictionary:params];
    [self.db close];
    
    if ([self.delegate respondsToSelector:@selector(updateView)]) {
        [self.delegate updateView];
    }
    return result;
}

- (BOOL)deleteFolderId:(NSInteger)folderId index:(NSIndexPath *)index {
    
    NSString *sql = @"DELETE FROM FolderList WHERE folderId = ?";
    NSString *sql2 = @"DELETE FROM TaskList WHERE folderId = ?";
    
    BOOL result = NO;
    
    [self.db open];
    /// 指定の配列を削除
    result = [self.db executeUpdate:sql withArgumentsInArray:@[@(folderId)]];
    result = [self.db executeUpdate:sql2 withArgumentsInArray:@[@(folderId)]];
    [self.db close];
    
    if ([self.delegate respondsToSelector:@selector(deleteTableViewCell:)]) {
        [self.delegate deleteTableViewCell:index];
    }
    return result;
}

- (BOOL)deleteAllFolderName {
    NSString *sql = @"DELETE FROM FolderList";
    NSString *sql2 = @"DELETE FROM TaskList";
    
    BOOL result = NO;
    
    [self.db open];
    result = [self.db executeUpdate:sql];
    result = [self.db executeUpdate:sql2];
    [self.db close];
    
    if ([self.delegate respondsToSelector:@selector(updateView)]) {
        [self.delegate updateView];
    }
    return result;
}

#pragma mark - TaskList Method
- (BOOL)createTaskListTable {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS TaskList (taskId INTEGER PRIMARY KEY AUTOINCREMENT, taskName TEXT ,updateTaskDate DATE ,folderId INTEGER )";
    
    BOOL result = NO;
    
    [self.db open];
    result = [self.db executeUpdate:sql];
    [self.db close];
    return result;
}

- (BOOL)taskNameInsert:(NSString *)inputTaskName inputDate:(NSDate *)inputDate folderData:(FolderListData *)folderData {
    NSString* sql = @"INSERT INTO TaskList(taskName, updateTaskDate, folderId) VALUES(?, ?, ?)";
    
    BOOL result = NO;
    
    [self.db open];
    [self.db executeUpdate:sql, inputTaskName, inputDate, @(folderData.folderId)];
    [self.db close];
    
    NSArray<TaskListData *>* selectArray = [self selectTaskList:folderData.folderId];
    folderData.tasks = selectArray.count;
    /// フォルダリストをアップデート
    [self updateFolderList:folderData.folderName updateDate:folderData.updateDate editFolderData:folderData];
    /// タスクリストをアップデート
    if ([self.delegate respondsToSelector:@selector(updateTaskList)]) {
        [self.delegate updateTaskList];
    }
    
    return result;
}

- (NSArray<TaskListData *> *)selectTaskList:(NSInteger)folderId {
    
    NSString *sql = @"SELECT * FROM TaskList WHERE folderId = ? ORDER BY updateTaskDate DESC";
    NSMutableArray<TaskListData *>* resultArray = [@[] mutableCopy];
    [self.db open];
    FMResultSet *results = [self.db executeQuery:sql withArgumentsInArray:@[@(folderId)]];
    while ([results next]) {
        TaskListData *taskListDataObject = [[TaskListData alloc] initWithFMResultSetTaskListCellData:results];
        [resultArray addObject:taskListDataObject];
    }
    [self.db close];
    
    return resultArray;
}

- (BOOL)deleteTaskId:(TaskListData *)taskData folderData:(FolderListData *)folderData index:(NSIndexPath *)index {
    
    NSString *sql = @"DELETE FROM TaskList WHERE taskId = ?";
    
    BOOL result = NO;
    
    [self.db open];
    result = [self.db executeUpdate:sql withArgumentsInArray:@[@(taskData.taskId)]];
    [self.db close];
    
    /// フォルダリストをアップデート
    NSArray<TaskListData *>* selectArray = [self selectTaskList:folderData.folderId];
    folderData.tasks = selectArray.count;
    [self updateFolderList:folderData.folderName updateDate:folderData.updateDate editFolderData:folderData];
    /// タスクリストをアップデート
    if ([self.delegate respondsToSelector:@selector(deleteTaskListCell:)]) {
        [self.delegate deleteTaskListCell:index];
    }
    return result;
}

- (BOOL)updateTaskList:(NSString *)inputTaskName updateDate:(NSDate *)updateDate taskId:(NSInteger)taskId {
    
    NSString* sql = @"UPDATE TaskList SET taskName = :TASKNAME, updateTaskDate = :UPDATETASKDATE WHERE taskId = :TASKID";
    
    NSDictionary<NSString *, id> *params = @{@"TASKNAME": inputTaskName,
                                             @"UPDATETASKDATE": updateDate,
                                             @"TASKID": @(taskId)};
    BOOL result = NO;
    
    [self.db open];
    result = [self.db executeUpdate:sql withParameterDictionary:params];
    [self.db close];
    
    // 更新をかける
    if ([self.delegate respondsToSelector:@selector(updateTaskList)]) {
        [self.delegate updateTaskList];
    }
    
    return result;
}

- (BOOL)deleteAllTaskName:(FolderListData *)folderData {
    
    NSString *sql = @"DELETE FROM TaskList WHERE folderId = ?";
    
    BOOL result = NO;
    
    [self.db open];
    result = [self.db executeUpdate:sql withArgumentsInArray:@[@(folderData.folderId)]];
    [self.db close];
    
    /// フォルダリストをアップデート
    NSArray<TaskListData *>* selectArray = [self selectTaskList:folderData.folderId];
    folderData.tasks = selectArray.count;
    [self updateFolderList:folderData.folderName updateDate:folderData.updateDate editFolderData:folderData];
    /// タスクリストをアップデート
    if ([self.delegate respondsToSelector:@selector(updateTaskList)]) {
        [self.delegate updateTaskList];
    }
    return result;
}
@end
