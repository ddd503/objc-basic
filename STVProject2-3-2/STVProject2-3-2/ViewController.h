//
//  ViewController.h
//  STVProject2-3-2
//
//  Created by kawaharadai on 2017/08/30.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
// DB用プロパティ
- (id)connectDataBase:(NSString *)dbName;
extern NSString *const AccessDatabaseName;
@end

