//
//  AleartTextModel.m
//  TaskManagerApp
//
//  Created by kawaharadai on 2017/10/15.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "AleartTextModel.h"

@implementation AleartTextModel

- (instancetype)initWithAleartText:(NSString *)title
                           messege:(NSString *)messege
                     textFieldtext:(NSString *)textFieldtext
              textFieldPlaceFolder:(NSString *)textFieldPlaceFolder{
    
    self = [super init];
    if (self) {
        self.titleText = title;
        self.messegeText = messege;
        self.textFieldText = textFieldtext;
        self.textFieldPlaceFolder = textFieldPlaceFolder;
    }
    return self;
}

@end
