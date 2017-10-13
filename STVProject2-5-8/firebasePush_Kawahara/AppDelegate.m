//
//  AppDelegate.m
//  firebasePush_Kawahara
//
//  Created by kawaharadai on 2017/09/23.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () 

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    // デバイスのOSを判定（iOS10を基準に判定（切り捨てて判定））
    if ( floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max )
    {
        // iOS10以降の場合
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:
         (UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert ) completionHandler:^(BOOL granted, NSError *_Nullable error) {
             if (granted) {
                 // サーバーを自作する場合はここでサーバーにトークンを渡す
             }
         }];
        // firebaseの機能を使う
        [FIRApp configure];
        // デリゲートを接続
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [FIRMessaging messaging].delegate = self;
        // 通知設定を登録
        [application registerForRemoteNotifications];
        // 送られたトークンIDを確認
        NSString *fcmToken = [FIRMessaging messaging].FCMToken;
        NSLog(@"FCM registration token: %@", fcmToken);
        
    } else {
        // iOS9以前の場合
    }
    return YES;
}

// トークンの登録後、渡す
-(void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [FIRMessaging messaging].APNSToken = deviceToken;
}

// フォアグラウンドで通知を受ける処理
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
}

#pragma mark Firebase
// リモートメッセージを受けた時の処理
-(void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage{
}

// 登録済みのトークンを確認
- (void)messaging:(FIRMessaging *)messaging didRefreshRegistrationToken:(NSString *)fcmToken {
    NSLog(@"登録したトークン: %@", fcmToken);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"firebasePush_Kawahara"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end