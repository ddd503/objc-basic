//
//  FolderListProvider.h
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/08.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FolderListData.h"

@protocol FolderListProviderDelegate <NSObject>
- (void)deleteTableViewCell:(NSIndexPath *)index;
@end

@interface FolderListProvider : NSObject <UITableViewDataSource>
@property (weak, nonatomic) id<FolderListProviderDelegate> delegate;
@property (strong, nonatomic) NSArray<FolderListData *> *folderListDataList;
@end
