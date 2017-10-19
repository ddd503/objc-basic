//
//  FolderListProvider.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/08.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "FolderListProvider.h"
#import "FolderListCell.h"
#import "Database.h"

@interface FolderListProvider ()

@end

@implementation FolderListProvider

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.folderListDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FolderListCell *cell =
    [tableView dequeueReusableCellWithIdentifier:[FolderListCell folderListCellIdentifier] forIndexPath:indexPath];
    
    [cell setFolderListCellData:self.folderListDataList[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /// 該当のセルを消す
        Database *database = [Database new];
        [database deleteFolderId:self.folderListDataList[indexPath.row].folderId index:indexPath
         ];
        
        /// 更新をかける
        if ([self.delegate respondsToSelector:@selector(deleteTableViewCell:)]) {
            [self.delegate deleteTableViewCell:indexPath];
        }
    }
    
}
@end
