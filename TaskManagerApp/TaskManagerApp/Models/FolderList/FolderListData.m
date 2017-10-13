//
//  FolderListData.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/09.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "FolderListData.h"

@interface FolderListData ()
@end

@implementation FolderListData
- (instancetype)initWithFMResultSetFolderListCellData:(FMResultSet *)results {
    self = [super init];
    if (self) {
        self.folderId = [results intForColumn:@"folderId"];
        self.folderName = [results stringForColumn:@"folderName"];
        self.updateDate = [results dateForColumn:@"updateDate"];
        self.tasks = [results intForColumn:@"tasks"];
    }
    return self;
}

@end
