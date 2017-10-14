//
//  TaskListCell.h
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/08.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskListData.h"

@interface TaskListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateTaskDateLabel;
+ (NSString *)taskListCellNibName;
+ (NSString *)taskListCellIdentifier;
- (void)setTaskListData:(TaskListData *)taskListData;
@end
