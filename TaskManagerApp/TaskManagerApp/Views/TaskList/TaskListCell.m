//
//  TaskListCell.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/08.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "TaskListCell.h"

@interface TaskListCell ()
@end

NSString *const taskListCellNibName = @"TaskListCell";
NSString *const taskListCellIdentifier = @"TaskListCell";

@implementation TaskListCell

+ (NSString *)taskListCellNibName {
    return taskListCellNibName;
}
+ (NSString *)taskListCellIdentifier {
    return taskListCellIdentifier;
}

- (void)setTaskListData:(TaskListData *)taskListData {
    self.taskNameLabel.text = taskListData.taskName;
    self.updateTaskDateLabel.text = [self chengeDateData:taskListData.updateTaskDate];
}

- (NSString *)chengeDateData:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateText = [formatter stringFromDate:date];
    return dateText;
}

@end
