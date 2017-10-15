//
//  DateHelper.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/15.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "DateHelper.h"

static NSString *const formatterText = @"yyyy/MM/dd";

@implementation DateHelper

+ (NSString *)returnDateText:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatterText];
    NSString *dateText = [formatter stringFromDate:date];
    return dateText;
}

@end
