//
//  ViewController.m
//  STVProject2-1-9
//
//  Created by kawaharadai on 2017/08/24.
//  Copyright © 2017年 dai kawahara. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
// プロパティを宣言
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *pickerHiddenButton;
@property (strong, nonatomic) NSDate *todayDate;
@property (strong, nonatomic) NSDateFormatter *formatter;
// メソッドを定義
- (void)settingTodaydate;
- (IBAction)dateChangedAction:(id)sender;
- (IBAction)touchLabel:(id)sender;
- (IBAction)touchBackground:(id)sender;
- (IBAction)pickerHiddenAction:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingTodaydate];
}

// 当日の日付を取得し、ラベルに表示
- (void)settingTodaydate {
    // 当日の日付を取得
    self.todayDate = [[NSDate alloc]init];
    self.todayDate = [NSDate date];
    
    // 表示用データフォーマットをインスタンス化
    self.formatter = [[NSDateFormatter alloc] init];
    
    // フォーマットに型をセット(時間まで表示する時は、@"M月dd日(E) HH:mm"でModeを変更する)
    [self.formatter setDateFormat:@"yyyy年M月dd日"];
    
    // ラベルに当日の日付を反映
    self.dateLabel.text = [self.formatter stringFromDate:self.todayDate];
}

- (IBAction)dateChangedAction:(id)sender {
    // datapikerが変更されるたびにその日付を取得してpickerに入れる
    self.dateLabel.text = [self.formatter stringFromDate:self.datePicker.date];
}

// ラベルタッチアクション
- (IBAction)touchLabel:(id)sender {
    self.datePicker.hidden = NO;
    self.pickerHiddenButton.hidden = NO;
}

// 背景タッチアクション
- (IBAction)touchBackground:(id)sender {
    self.datePicker.hidden = YES;
    self.pickerHiddenButton.hidden = YES;
}

// Doneボタンアクション
- (IBAction)pickerHiddenAction:(id)sender {
    self.datePicker.hidden = YES;
    self.pickerHiddenButton.hidden = YES;
}

@end
