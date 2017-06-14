//
//  GSBadVCViewController.m
//  GSPickerDemo
//
//  Created by Brook on 2017/3/24.
//  Copyright © 2017年 Brook. All rights reserved.
//

#import "GSBadVCViewController.h"

@interface GSBadVCViewController ()

@end

@implementation GSBadVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我会崩溃";
    
    id obj = nil;
    NSArray *arr = @[@1, @2, obj];
    NSLog(@"arr %@", arr);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
