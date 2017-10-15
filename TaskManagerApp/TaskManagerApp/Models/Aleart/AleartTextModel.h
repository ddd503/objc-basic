//
//  AleartTextModel.h
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/15.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AleartTextModel : NSObject
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *messegeText;
@property (strong, nonatomic) NSString *textFieldText;
@property (strong, nonatomic) NSString *textFieldPlaceFolder;
- (instancetype)initWithAleartText:(NSString *)title
                           messege:(NSString *)messege
                     textFieldtext:(NSString *)textFieldtext
              textFieldPlaceFolder:(NSString *)textFieldPlaceFolder;
@end
