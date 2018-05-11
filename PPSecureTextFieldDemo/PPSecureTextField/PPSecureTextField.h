//
//  PPSecureTextField.h
//  PPSecureTextFieldDemo
//
//  Created by istLZP on 2018/5/11.
//  Copyright © 2018年 Garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAXLENGTH 16

typedef void(^currentInputBlock)(NSString *currentInput);

@interface PPSecureTextField : UIView

//
@property (nonatomic, strong) UITextField *textField;

//
@property (nonatomic, strong) currentInputBlock currentInput;

@end
