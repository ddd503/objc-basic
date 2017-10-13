//
//  TaskListData.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/09.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "TaskListData.h"

@interface TaskListData ()
@end

@implementation TaskListData
- (instancetype)initWithFMResultSetTaskListCellData:(FMResultSet *)results {
    self = [super init];
    if (self) {
        self.taskId = [results intForColumn:@"taskId"];
        self.taskName = [results stringForColumn:@"taskName"];
        self.updateTaskDate = [results dateForColumn:@"updateTaskDate"];
    }
    return self;
}
@end
