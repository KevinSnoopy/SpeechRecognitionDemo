//
//  ViewController.m
//  SpeechRecognitionDemo
//
//  Created by kevin on 2019/3/18.
//  Copyright © 2019 kevin. All rights reserved.
//

#import "ViewController.h"
#import "SpeechRecognition.h"

@interface ViewController () <SpeechRecognitionProtocol>
{
    CGFloat _width;//屏幕宽度
    CGFloat _height;//屏幕高度
}

@property (nonatomic, retain) UITextView *textView;//
@property (nonatomic, retain) UIButton *button;//

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _width = [UIScreen mainScreen].bounds.size.width;
    _height = [UIScreen mainScreen].bounds.size.height;
    [SpeechRecognition setDelegate:self];
    [self setUpView];
}

/**
 添加控件
 */
- (void)setUpView{
    [self.view addSubview:self.textView];
    [self.view addSubview:self.button];
}

/**
 SpeechRecognitionProtocol
 */
- (void)speechRecognitionResult:(NSString *)result{
    if (result && result.length > 0) {
        self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@",result]];
    }
}

- (void)speechRecognition:(UIButton *)button{
    if (button.tag == 100) {
        button.tag = 101;
        [button setTitle:@"stop" forState:UIControlStateNormal];
        [SpeechRecognition startRecognition];
    }else{
        button.tag = 100;
        [button setTitle:@"start" forState:UIControlStateNormal];
        [SpeechRecognition stopRecognition];
    }
}

/**
 初始化控件
 */
- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc]initWithFrame:CGRectMake(20, 20, _width-40, _height-100)];
        _textView.backgroundColor = [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1];
        _textView.text = @"";
    }
    return _textView;
}

- (UIButton *)button{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button addTarget:self action:@selector(speechRecognition:) forControlEvents:UIControlEventTouchUpInside];
        [_button setTitle:@"start" forState:UIControlStateNormal];
        _button.bounds = CGRectMake(0, 0, 100, 40);
        _button.center = CGPointMake(_width/2, _height-60);
        _button.tag = 100;
    }
    return _button;
}

@end
