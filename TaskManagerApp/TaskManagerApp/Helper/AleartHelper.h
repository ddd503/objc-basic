//
//  AleartHelper.h
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/18.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AlertHelperDelegate <NSObject>

@optional
- (void)createFolder:(NSString *) inputText;
- (void)editFolder:(NSString *) inputText;
- (void)deleteAllFolder;
- (void)createTask:(NSString *) inputText;
- (void)editTask:(NSString *) inputText;
- (void)deleteAllTask;
@end

@interface AleartHelper : NSObject
@property (weak, nonatomic) id<AlertHelperDelegate> delegate;
- (UIAlertController *)createNewFolderAleart:(NSString *)defaultText
                                 placeholder:(NSString *)placeholder
                                  alertTitle:(NSString *)alertTitle
                                alertMessage:(NSString *)alertMessage;
- (UIAlertController *)createEditFolderAleart:(NSString *)defaultText
                                  placeholder:(NSString *)placeholder
                                   alertTitle:(NSString *)alertTitle
                                 alertMessage:(NSString *)alertMessage;
- (UIAlertController *)createAllDeleteFolderActionSheet;
- (UIAlertController *)createNewTaskAleart:(NSString *)defaultText
                               placeholder:(NSString *)placeholder
                                alertTitle:(NSString *)alertTitle
                              alertMessage:(NSString *)alertMessage;
- (UIAlertController *)createEditTaskAleart:(NSString *)defaultText
                                placeholder:(NSString *)placeholder
                                 alertTitle:(NSString *)alertTitle
                               alertMessage:(NSString *)alertMessage;
- (UIAlertController *)createAllDeleteTaskActionSheet;
@end
