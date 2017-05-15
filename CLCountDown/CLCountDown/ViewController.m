//
//  ViewController.m
//  CLCountDown
//
//  Created by ChenLu on 2017/5/12.
//  Copyright © 2017年 Chenlu. All rights reserved.
//

#import "ViewController.h"
#import "CLCountDownView.h"

@interface ViewController ()<CLCountDownViewDelegate>
@property (nonatomic)CLCountDownView *countDownView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.countDownView =  [[CLCountDownView alloc] init];
    
     self.countDownView.frame = CGRectMake(0, 0, 200, 30);
     self.countDownView.center = self.view.center;
     self.countDownView.delegate = self;
     self.countDownView.themeColor = [UIColor orangeColor];
     self.countDownView.countDownTimeInterval = 100;
    self.countDownView.countDownType = CountDownUseColon;
    [self.view addSubview: self.countDownView];
    
    
}
- (void)countDownDidFinished {
    UIAlertController  *aler = [UIAlertController alertControllerWithTitle:@"tip" message:@"CountDownOver!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.countDownView.countDownTimeInterval = 100;
    }];
    [aler addAction:cancelAction];
    [aler addAction:resetAction];
    [self presentViewController:aler animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
