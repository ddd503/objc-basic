//
//  FolderListCell.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/08.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "FolderListCell.h"

@interface FolderListCell ()
@end

NSString *const folderListCellNibName = @"FolderListCell";
NSString *const folderListCellIdentifier = @"FolderListCell";

@implementation FolderListCell

+ (NSString *)folderListCellNibName {
    return folderListCellNibName;
}

+ (NSString *)folderListCellIdentifier {
    return folderListCellIdentifier;
}

- (void)setFolderListCellData:(FolderListData *)folderListData {
    self.folderNameLabel.text = folderListData.folderName;
    self.haveTaskCountLabel.text = [NSString stringWithFormat:@"%ld", folderListData.tasks];
}


@end
