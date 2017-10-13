//
//  TaskListData.h
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/09.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface TaskListData : NSObject
@property (nonatomic) NSInteger taskId;
@property (strong, nonatomic) NSString *taskName;
@property (strong, nonatomic) NSDate *updateTaskDate;
- (instancetype)initWithFMResultSetTaskListCellData:(FMResultSet *)results;
@end
