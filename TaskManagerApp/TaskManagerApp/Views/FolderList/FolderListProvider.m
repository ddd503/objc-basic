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
    
    FolderListCell *cell = [tableView dequeueReusableCellWithIdentifier:[FolderListCell folderListCellIdentifier] forIndexPath:indexPath];
    
    [cell setFolderListCellData:self.folderListDataList[indexPath.row]];
    
    /// 降順で日付を取り出しているか確認
    [self checkdate:indexPath folderName:self.folderListDataList[indexPath.row].folderName date:self.folderListDataList[indexPath.row].updateDate];
    
    return cell;
}

- (void)checkdate:(NSIndexPath *)index folderName:(NSString *)folderName date:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateText = [formatter stringFromDate:date];
    NSLog(@"indexPath.row:%ld,フォルダ名:%@,更新時間:%@", (long)index.row, folderName, dateText);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /// 該当のセルを消す
        Database *database = [[Database alloc] init];
        [database deleteFolderId:self.folderListDataList[indexPath.row].folderId index:indexPath folderName:self.folderListDataList[indexPath.row].folderName];
        
        /// 更新をかける
        if ([self.delegate respondsToSelector:@selector(deleteTableViewCell:)]) {
            [self.delegate deleteTableViewCell:indexPath];
        }
    }
    
}
@end
