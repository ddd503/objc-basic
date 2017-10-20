//
//  FolderListData.h
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/09.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface FolderListData : NSObject
@property (nonatomic) NSInteger folderId;
@property (strong, nonatomic) NSString *folderName;
@property (strong, nonatomic) NSDate *updateDate;
@property (nonatomic) NSInteger tasks;
- (instancetype)initWithFMResultSetFolderListCellData:(FMResultSet *)results;
@end
