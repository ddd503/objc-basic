//
//  SQLiteHelper.h
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/15.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface SQLiteHelper : NSObject
@property (nonatomic) FMDatabase *db;
- (BOOL)open;
- (BOOL)close;
- (BOOL)createFolderListTable;
- (BOOL)createTaskListTable;
@end
