//
//  AleartHelper.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/18.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "AleartHelper.h"

@interface AleartHelper () <UITextFieldDelegate>
@property (strong, nonatomic) UIAlertController *aleartController;
@property (strong, nonatomic) NSString *inputText;

@end

@implementation AleartHelper

#pragma mark - FolderListAlert Methods

- (UIAlertController *)createNewFolderAleart:(NSString *)defaultText
                                 placeholder:(NSString *)placeholder
                                  alertTitle:(NSString *)alertTitle
                                alertMessage:(NSString *)alertMessage {
    
    self.aleartController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                message:alertMessage
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    // handlar内で使うため
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"save", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         // ハンドラー内でのnilを防ぐ
                                                         __strong typeof(self) strongSelf = weakSelf;
                                                         if (!strongSelf) {
                                                             return;
                                                         }
                                                         [strongSelf.delegate createFolder:strongSelf.inputText];
                                                     }];
    
    // 引数のtextの長さによって、OKボタンの初期状態を設定
    BOOL enabledSaveButton = defaultText && defaultText.length > 0;
    saveAction.enabled = enabledSaveButton;
    
    [self.aleartController addAction:cancelAction];
    [self.aleartController addAction:saveAction];
    [self.aleartController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        textField.placeholder = placeholder;
        textField.text = defaultText;
        textField.delegate = strongSelf;
    }];
    
    return self.aleartController;
}

- (UIAlertController *)createEditFolderAleart:(NSString *)defaultText
                                  placeholder:(NSString *)placeholder
                                   alertTitle:(NSString *)alertTitle
                                 alertMessage:(NSString *)alertMessage {
    
    self.aleartController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                message:alertMessage
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    // handlar内で使うため
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"save", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           // ハンドラー内でのnilを防ぐ
                                                           __strong typeof(self) strongSelf = weakSelf;
                                                           if (!strongSelf) {
                                                               return;
                                                           }
                                                           [strongSelf.delegate editFolder:strongSelf.inputText];
                                                       }];
    
    // 引数のtextの長さによって、OKボタンの初期状態を設定
    BOOL enabledSaveButton = defaultText && defaultText.length > 0;
    saveAction.enabled = enabledSaveButton;
    
    [self.aleartController addAction:cancelAction];
    [self.aleartController addAction:saveAction];
    [self.aleartController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        textField.placeholder = placeholder;
        textField.text = defaultText;
        textField.delegate = strongSelf;
    }];
    
    return self.aleartController;
}

- (UIAlertController *)createAllDeleteFolderActionSheet {
    UIAlertController *allDeletefolderActionSheet =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    // handlar内で使うため
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *deleteAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", nil)
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action) {
                               __strong typeof(self) strongSelf = weakSelf;
                               if (!strongSelf) {
                                   return;
                               }
                               [strongSelf.delegate deleteAllFolder];
                           }];
    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    [allDeletefolderActionSheet addAction:deleteAction];
    [allDeletefolderActionSheet addAction:cancelAction];
    
    return allDeletefolderActionSheet;
}

#pragma mark - TaskListAlert Methods
- (UIAlertController *)createNewTaskAleart:(NSString *)defaultText
                                 placeholder:(NSString *)placeholder
                                  alertTitle:(NSString *)alertTitle
                                alertMessage:(NSString *)alertMessage {
    
    self.aleartController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                message:alertMessage
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    // handlar内で使うため
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"save", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           // ハンドラー内でのnilを防ぐ
                                                           __strong typeof(self) strongSelf = weakSelf;
                                                           if (!strongSelf) {
                                                               return;
                                                           }
                                                           [strongSelf.delegate createTask:strongSelf.inputText];
                                                       }];
    
    // 引数のtextの長さによって、OKボタンの初期状態を設定
    BOOL enabledSaveButton = defaultText && defaultText.length > 0;
    saveAction.enabled = enabledSaveButton;
    
    [self.aleartController addAction:cancelAction];
    [self.aleartController addAction:saveAction];
    [self.aleartController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        textField.placeholder = placeholder;
        textField.text = defaultText;
        textField.delegate = strongSelf;
    }];
    
    return self.aleartController;
}

- (UIAlertController *)createEditTaskAleart:(NSString *)defaultText
                                  placeholder:(NSString *)placeholder
                                   alertTitle:(NSString *)alertTitle
                                 alertMessage:(NSString *)alertMessage {
    
    self.aleartController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                message:alertMessage
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    // handlar内で使うため
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"save", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           // ハンドラー内でのnilを防ぐ
                                                           __strong typeof(self) strongSelf = weakSelf;
                                                           if (!strongSelf) {
                                                               return;
                                                           }
                                                           [strongSelf.delegate editTask:strongSelf.inputText];
                                                       }];
    
    // 引数のtextの長さによって、OKボタンの初期状態を設定
    BOOL enabledSaveButton = defaultText && defaultText.length > 0;
    saveAction.enabled = enabledSaveButton;
    
    [self.aleartController addAction:cancelAction];
    [self.aleartController addAction:saveAction];
    [self.aleartController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        textField.placeholder = placeholder;
        textField.text = defaultText;
        textField.delegate = strongSelf;
    }];
    
    return self.aleartController;
}

- (UIAlertController *)createAllDeleteTaskActionSheet {
    UIAlertController *allDeletefolderActionSheet =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    // handlar内で使うため
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *deleteAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", nil)
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action) {
                               __strong typeof(self) strongSelf = weakSelf;
                               if (!strongSelf) {
                                   return;
                               }
                               [strongSelf.delegate deleteAllTask];
                           }];
    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    [allDeletefolderActionSheet addAction:deleteAction];
    [allDeletefolderActionSheet addAction:cancelAction];
    
    return allDeletefolderActionSheet;
}

#pragma mark - textField DelegateMethods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    UIAlertAction *saveButton = self.aleartController.actions.lastObject;
    
    self.inputText = [textField.text stringByReplacingCharactersInRange:range
                                                             withString:string];
    
    BOOL enabledSaveButton = self.inputText.length >= 1;
    saveButton.enabled = enabledSaveButton;
    
    return true;
}

@end
