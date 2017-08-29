//
//  PageViewController.h
//  STVProject2-1-16
//
//  Created by kawaharadai on 2017/08/29.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import <UIKit/UIKit.h>

// デリゲートを接続（UIPageViewController自体に関する設定はストーリーボードで）
@interface PageViewController : UIPageViewController <UIPageViewControllerDelegate,UIPageViewControllerDataSource>
// プロパティを定義
@property NSArray *viewControllerList;
@property UIViewController *viewcontroller;
@property int viewControllerIndex;

@end
