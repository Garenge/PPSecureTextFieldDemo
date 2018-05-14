# PPSecureTextFieldDemo

## 全密文形式的输入框

### 提出需求

苹果UITextField自带的`secureTextEntry = YES`, 在输入密码的时候, 会先显示输入的字符, 然后转换成密文形式, 有时候不能完全掩盖输入的文字

所以我们需要一个完全的密文, 从你按键开始, 你就看不见你的密码

### 分析评估

我们在输入密码的时候, 直接更改textField的文字为"●", 这样, 肯定是看不见密文的

然后我们, 在内存中保存输入的字符串即可, 所以该需求可实现

### 代码实现

> 头文件

```
#import <UIKit/UIKit.h>

#define MAXLENGTH 16

typedef void(^currentInputBlock)(NSString *currentInput);

@interface PPSecureTextField : UIView

//
@property (nonatomic, strong) UITextField *textField;

//
@property (nonatomic, strong) currentInputBlock currentInput;

@end
```

> 实现文件

```
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
                    if(range.location < MAXLENGTH) {
                        // 保证数组不越界
                        secureArray[range.location] = *tempString;
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

```

> 调用

```
PPSecureTextField *secureField = [[PPSecureTextField alloc] initWithFrame:CGRectMake(50, 50, 200, 50)];
secureField.currentInput = ^(NSString *currentInput) {
    NSLog(@"block回传:%@", currentInput);
};
[self.view addSubview:secureField];
```
