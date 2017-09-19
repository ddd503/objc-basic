//
//  AppDelegate.h
//  STVProject2-1-8
//
//  Created by kawaharadai on 2017/08/23.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

