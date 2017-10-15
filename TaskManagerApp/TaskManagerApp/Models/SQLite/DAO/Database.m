//
//  Database.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/09.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "Database.h"
#import "SQLiteHelper.h"

@interface Database ()

@end

@implementation Database

+ (NSString *)dbPath {
    return [[self documentsDirectory] stringByAppendingPathComponent:@"database.db"];
}

+ (NSString *)documentsDirectory {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

#pragma mark - FolderList Method

- (BOOL)folderNameInsert:(NSString *)inputFolderName inputDate:(NSDate *)inputDate {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];
    NSString *sql = @"INSERT INTO FolderList(folderName, updateDate) VALUES(?, ?)";
    
    BOOL result = NO;
    
    [sqliteHelper open];
    [sqliteHelper.db executeUpdate:sql, inputFolderName, inputDate];
    [sqliteHelper close];
    
    if ([self.delegate respondsToSelector:@selector(updateView)]) {
        [self.delegate updateView];
    }
    
    return result;
}

- (NSArray<FolderListData *> *)selectFolderList {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];

    NSString *sql = @"SELECT * FROM FolderList ORDER BY updateDate DESC";
    NSMutableArray<FolderListData *>* resultArray = [@[] mutableCopy];
    
    [sqliteHelper open];
    FMResultSet *results = [sqliteHelper.db executeQuery:sql];
    while ([results next]) {
        FolderListData *folderListDataObject = [[FolderListData alloc] initWithFMResultSetFolderListCellData:results];
        [resultArray addObject:folderListDataObject];
    }
    [sqliteHelper close];
    return resultArray;
}

- (BOOL)updateFolderList:(NSString *)inputFolderName updateDate:(NSDate *)updateDate editFolderData:(FolderListData *)editFolderData {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];

    NSString* sql = @"UPDATE FolderList SET folderName = :FOLDERNAME, updateDate = :UPDATEDATE, tasks = :TASKS WHERE folderId = :FOLDERID";
    
    NSDictionary<NSString *, id> *params = @{@"FOLDERNAME": inputFolderName,
                                             @"UPDATEDATE": updateDate,
                                             @"TASKS": @(editFolderData.tasks),
                                             @"FOLDERID": @(editFolderData.folderId)};
    
    BOOL result = NO;
    
    [sqliteHelper open];
    result = [sqliteHelper.db executeUpdate:sql withParameterDictionary:params];
    [sqliteHelper close];
    
    if ([self.delegate respondsToSelector:@selector(updateView)]) {
        [self.delegate updateView];
    }
    return result;
}

- (BOOL)deleteFolderId:(NSInteger)folderId index:(NSIndexPath *)index {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];
    
    NSString *sql = @"DELETE FROM FolderList WHERE folderId = ?";
    NSString *sql2 = @"DELETE FROM TaskList WHERE folderId = ?";
    
    BOOL result = NO;
    
    [sqliteHelper open];
    /// 指定の配列を削除
    result = [sqliteHelper.db executeUpdate:sql withArgumentsInArray:@[@(folderId)]];
    result = [sqliteHelper.db executeUpdate:sql2 withArgumentsInArray:@[@(folderId)]];
    [sqliteHelper close];
    
    if ([self.delegate respondsToSelector:@selector(deleteTableViewCell:)]) {
        [self.delegate deleteTableViewCell:index];
    }
    return result;
}

- (BOOL)deleteAllFolderName {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];
    
    NSString *sql = @"DELETE FROM FolderList";
    NSString *sql2 = @"DELETE FROM TaskList";
    
    BOOL result = NO;
    
    [sqliteHelper open];
    result = [sqliteHelper.db executeUpdate:sql];
    result = [sqliteHelper.db executeUpdate:sql2];
    [sqliteHelper close];
    
    if ([self.delegate respondsToSelector:@selector(updateView)]) {
        [self.delegate updateView];
    }
    return result;
}

#pragma mark - TaskList Method

- (BOOL)taskNameInsert:(NSString *)inputTaskName inputDate:(NSDate *)inputDate folderData:(FolderListData *)folderData {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];

    NSString* sql = @"INSERT INTO TaskList(taskName, updateTaskDate, folderId) VALUES(?, ?, ?)";
    
    BOOL result = NO;
    
    [sqliteHelper open];
    [sqliteHelper.db executeUpdate:sql, inputTaskName, inputDate, @(folderData.folderId)];
    [sqliteHelper close];
    
    /// フォルダリストをアップデート
    [self countTasks:folderData.folderId];
    /// タスクリストをアップデート
    if ([self.delegate respondsToSelector:@selector(updateTaskList)]) {
        [self.delegate updateTaskList];
    }
    
    return result;
}

- (NSArray<TaskListData *> *)selectTaskList:(NSInteger)folderId {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];

    NSString *sql = @"SELECT * FROM TaskList WHERE folderId = ? ORDER BY updateTaskDate DESC";
    NSMutableArray<TaskListData *>* resultArray = [@[] mutableCopy];
    [sqliteHelper open];
    FMResultSet *results = [sqliteHelper.db executeQuery:sql withArgumentsInArray:@[@(folderId)]];
    while ([results next]) {
        TaskListData *taskListDataObject = [[TaskListData alloc] initWithFMResultSetTaskListCellData:results];
        [resultArray addObject:taskListDataObject];
    }
    [sqliteHelper close];
    
    return resultArray;
}

- (BOOL)deleteTaskId:(TaskListData *)taskData folderData:(FolderListData *)folderData index:(NSIndexPath *)index {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];

    NSString *sql = @"DELETE FROM TaskList WHERE taskId = ?";
    
    BOOL result = NO;
    
    [sqliteHelper open];
    result = [sqliteHelper.db executeUpdate:sql withArgumentsInArray:@[@(taskData.taskId)]];
    [sqliteHelper close];
    
    /// フォルダリストをアップデート
    [self countTasks:folderData.folderId];

    /// タスクリストをアップデート
    if ([self.delegate respondsToSelector:@selector(deleteTaskListCell:)]) {
        [self.delegate deleteTaskListCell:index];
    }
    return result;
}

- (BOOL)updateTaskList:(NSString *)inputTaskName updateDate:(NSDate *)updateDate taskId:(NSInteger)taskId {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];

    NSString* sql = @"UPDATE TaskList SET taskName = :TASKNAME, updateTaskDate = :UPDATETASKDATE WHERE taskId = :TASKID";
    
    NSDictionary<NSString *, id> *params = @{@"TASKNAME": inputTaskName,
                                             @"UPDATETASKDATE": updateDate,
                                             @"TASKID": @(taskId)};
    BOOL result = NO;
    
    [sqliteHelper open];
    result = [sqliteHelper.db executeUpdate:sql withParameterDictionary:params];
    [sqliteHelper close];
    
    // 更新をかける
    if ([self.delegate respondsToSelector:@selector(updateTaskList)]) {
        [self.delegate updateTaskList];
    }
    
    return result;
}

- (BOOL)deleteAllTaskName:(FolderListData *)folderData {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];

    NSString *sql = @"DELETE FROM TaskList WHERE folderId = ?";
    
    BOOL result = NO;
    
    [sqliteHelper open];
    result = [sqliteHelper.db executeUpdate:sql withArgumentsInArray:@[@(folderData.folderId)]];
    [sqliteHelper close];
    
    /// フォルダリストをアップデート
    [self countTasks:folderData.folderId];

    /// タスクリストをアップデート
    if ([self.delegate respondsToSelector:@selector(updateTaskList)]) {
        [self.delegate updateTaskList];
    }
    return result;
}

- (BOOL)countTasks:(NSInteger)folderId {
    
    SQLiteHelper *sqliteHelper = [SQLiteHelper new];

    NSString *sql = @"SELECT COUNT(*) AS COUNT FROM TaskList WHERE folderId = ?";
    int taskCount = 0;
    BOOL result = NO;
    
    [sqliteHelper open];
    // resultsはopen後に作る
    FMResultSet *results = [sqliteHelper.db executeQuery:sql withArgumentsInArray:@[@(folderId)]];
    while([results next]) {
        taskCount = [results intForColumn:@"COUNT"];
    }
    [sqliteHelper close];

    // 数えた数でfolderListを更新
    NSString* sql2 = [NSString stringWithFormat:@"UPDATE FolderList SET tasks = %d WHERE folderId = %ld", taskCount, (long)folderId];
    
    [sqliteHelper open];
    result = [sqliteHelper.db executeUpdate:sql2];
    [sqliteHelper close];

    return result;
}

@end
