//
//  CustomImageView.m
//  CircularImageLoder
//
//  Created by yehot on 15/8/31.
//  Copyright (c) 2015年 Yehao. All rights reserved.
//

#import "CustomImageView.h"
#import "CircularLoaderView.h"

@interface CustomImageView ()

@property (nonatomic, strong) CircularLoaderView * progressIndicatorView;

@end

@implementation CustomImageView {
    NSTimer * _timer;
    CGFloat _timerLast; // 定时器时间
}

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    _progressIndicatorView = [[CircularLoaderView alloc] initWithFrame:self.bounds];
    [self addSubview:_progressIndicatorView];

    _progressIndicatorView.progress = 0;
    
    // 模拟网络请求
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

#pragma mark - 模拟请求进度

- (void)updateTimer {
    
    //  请求图片资源
    if (_timerLast <= 1) {
        _progressIndicatorView.progress += 0.1;
        _timerLast += 0.1;
    }else {
        [_timer invalidate];
    
        //  请求完成，设置图片
        self.image = [UIImage imageNamed:@"001"];
        
        //  执行 mask 动画
        [self.progressIndicatorView reveal];
    }

}


@end
