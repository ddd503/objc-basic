//
//  Database.h
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/09.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "FolderListData.h"
#import "TaskListData.h"

@protocol DatabaseDelegate <NSObject>

@optional
- (void)updateView;
- (void)updateTaskList;
- (void)deleteTableViewCell:(NSIndexPath *)index;
- (void)deleteTaskListCell:(NSIndexPath *)index;
@end

@interface Database : NSObject
@property (weak, nonatomic) id<DatabaseDelegate> delegate;
@property (nonatomic) FMDatabase *db;
+ (NSString *)dbPath;
+ (NSString *)documentsDirectory;

#pragma mark - FolderList Method
- (BOOL)folderNameInsert:(NSString *)inputFolderName inputDate:(NSDate *)inputDate;
- (BOOL)updateFolderList:(NSString *)inputFolderName updateDate:(NSDate *)updateDate editFolderData:(FolderListData *)editFolderData;
- (BOOL)deleteFolderId:(NSInteger)folderId index:(NSIndexPath *)index;
- (BOOL)deleteAllFolderName;
- (NSArray<FolderListData *> *)selectFolderList;

#pragma mark - TaskList Method
- (BOOL)taskNameInsert:(NSString *)inputTaskName inputDate:(NSDate *)inputDate folderData:(FolderListData *)folderData;
- (NSArray<TaskListData *> *)selectTaskList:(NSInteger)folderId;
- (BOOL)deleteTaskId:(TaskListData *)taskData folderData:(FolderListData *)folderData index:(NSIndexPath *)index;
- (BOOL)updateTaskList:(NSString *)inputTaskName updateDate:(NSDate *)updateDate taskId:(NSInteger)taskId;
- (BOOL)deleteAllTaskName:(FolderListData *)folderData;

@end
