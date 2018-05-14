//
//  PPSecureTextField.m
//  PPSecureTextFieldDemo
//
//  Created by istLZP on 2018/5/11.
//  Copyright © 2018年 Garenge. All rights reserved.
//

#import "PPSecureTextField.h"

@interface PPSecureTextField()  <UITextFieldDelegate>

//观察者
@property (nonatomic, strong) id observer;

@end

@implementation PPSecureTextField

static char secureArray[MAXLENGTH]; // 准备一个数组

NSString *printNumSecureString(NSInteger length) {
    NSMutableString *string = [NSMutableString string];
    for(NSInteger index = 0; index < length; index ++) {
        [string appendString:@"*"];
    }
    return string;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        [self setUpTextField];
    }
    return self;
    
}

- (void)setUpTextField {
    
    UITextField *textField = [[UITextField alloc] initWithFrame:self.bounds];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [self addSubview:textField];
    textField.delegate = self;
    self.textField = textField;
    
    if (_observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:_observer];
    }
    
    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSInteger length = textField.text.length;
        if(length > MAXLENGTH) {
            length = MAXLENGTH;
        }
        NSString *secureString = printNumSecureString(length);
        textField.text = secureString; // 这边是显示
    }];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSLog(@"%@, %@, %@", textField.text, NSStringFromRange(range), string);
    
    // 区分是增还是减
    if(string.length < range.length) {
        // 减
        for(NSInteger i = range.location + string.length; i < MAXLENGTH; i ++) {
            secureArray[i] = '\0';
        }
        [self printSecureString];
        return YES;
    } else {
        if(textField.text.length < MAXLENGTH && range.location + range.length <= MAXLENGTH && string.length <= MAXLENGTH) {
            // 集中处理这个字符串拼接的问题
            // 每次来的这个字符串, 就是我们的目标字符串
            if(string.length > 0) {
                const char *tempString = [string UTF8String];
                
                if(range.length == 0) {
                    // 一个字符
                    // 或者是粘贴的字符串
                    if(range.location < MAXLENGTH) {
                        // 保证数组不越界
                        for(NSInteger index = 0; index < string.length; index ++) {
                            secureArray[index] = *(tempString + index);
                        }
                    }
                } else {
                    // 多个字符, 从第一个开始逐个替换
                    // 这种情况是输入太快了, 根据log, 简易作一个判断
                    for(int i = 0; i < string.length; i ++) {
                        secureArray[range.location + i] = tempString[i];
                    }
                    for(NSInteger i = range.location + string.length; i < MAXLENGTH; i ++) {
                        secureArray[i] = '\0';
                    }
                }
            }
            [self printSecureString];
            return YES;
        } else {
            [self printSecureString];
            return NO;
        }
    }
}

- (void)printSecureString {
    // 处理完输入的字符串, 输出
    NSString *secureString = [NSString stringWithCString:secureArray  encoding:NSUTF8StringEncoding];
    NSString *result = secureString.length > MAXLENGTH ? [secureString substringToIndex:MAXLENGTH] : secureString;
    NSLog(@"我们输入的密码是:%@", result);
    if(self.currentInput) {
        self.currentInput(result);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}


@end
