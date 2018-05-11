//
//  ViewController.m
//  PPSecureTextFieldDemo
//
//  Created by istLZP on 2018/5/11.
//  Copyright © 2018年 Garenge. All rights reserved.
//

#import "ViewController.h"
#import "PPSecureTextField/PPSecureTextField.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PPSecureTextField *secureField = [[PPSecureTextField alloc] initWithFrame:CGRectMake(50, 50, 200, 50)];
    secureField.currentInput = ^(NSString *currentInput) {
        NSLog(@"block回传:%@", currentInput);
    };
    [self.view addSubview:secureField];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
