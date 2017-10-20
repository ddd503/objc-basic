//
//  TaskListProvider.h
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/08.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TaskListData.h"
#import "FolderListData.h"

@protocol TaskListProviderDelegate <NSObject>
- (void)deleteTaskListCell:(NSIndexPath *)index;
@end

@interface TaskListProvider : NSObject <UITableViewDataSource>
@property (weak, nonatomic) id<TaskListProviderDelegate> delegate;
@property (strong, nonatomic) NSArray<TaskListData *> *taskListDataList;
@property (strong, nonatomic) FolderListData *folderData;
@end
