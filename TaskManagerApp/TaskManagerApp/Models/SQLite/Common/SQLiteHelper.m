//
//  SQLiteHelper.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/15.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "SQLiteHelper.h"
#import "Database.h"

@implementation SQLiteHelper

- (instancetype)init {
    self = [super init];
    if (self) {
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

- (BOOL)open {
    return [self.db open];
}

- (BOOL)close {
    return [self.db close];
}

- (BOOL)createFolderListTable {
    NSString *sql =
    @"CREATE TABLE IF NOT EXISTS FolderList (folderId INTEGER PRIMARY KEY AUTOINCREMENT, folderName TEXT ,updateDate DATE ,tasks INTEGER )";
    
    BOOL result = NO;
    
    [self.db open];
    result = [self.db executeUpdate:sql];
    [self.db close];
    return result;
}

- (BOOL)createTaskListTable {
    NSString *sql =
    @"CREATE TABLE IF NOT EXISTS TaskList (taskId INTEGER PRIMARY KEY AUTOINCREMENT, taskName TEXT ,updateTaskDate DATE ,folderId INTEGER )";
    
    BOOL result = NO;
    
    [self.db open];
    result = [self.db executeUpdate:sql];
    [self.db close];
    return result;
}
@end
