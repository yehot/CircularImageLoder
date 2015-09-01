//
//  CircularLoaderView.m
//  CircularImageLoder
//
//  Created by yehot on 15/8/31.
//  Copyright (c) 2015年 Yehao. All rights reserved.
//

#import "CircularLoaderView.h"

@interface CircularLoaderView ()

@property (nonatomic, strong) CAShapeLayer * circlePathLayer;   // 圆环 layer
@property (nonatomic, assign) CGFloat circleRadius;     // 进度圆环的半径

@end

@implementation CircularLoaderView

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}


- (void)configure {
    _circleRadius = 20;
    self.progress = 0;

    //  shapLayer 加到 self 上
    _circlePathLayer = [CAShapeLayer layer];
    _circlePathLayer.frame = self.bounds;
    _circlePathLayer.lineWidth = 2;
    _circlePathLayer.fillColor = [UIColor clearColor].CGColor;
    _circlePathLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:_circlePathLayer];
    
    //  先遮盖住 image
    self.backgroundColor = [UIColor whiteColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:[self circleFrame]];
    _circlePathLayer.frame = self.bounds;
    _circlePathLayer.path = path.CGPath;
}

#pragma mark - public method

- (CGFloat)progress {
    return _circlePathLayer.strokeEnd;
}

- (void)setProgress:(CGFloat)progress {
    
    //  直接设置 shapeLayer 的 strokeEnd 属性，改变形状
    if (progress > 1) {
        _circlePathLayer.strokeEnd = 1;
    } else if (progress < 0) {
        _circlePathLayer.strokeEnd = 0;
    } else {
        _circlePathLayer.strokeEnd = progress;
    }
}

- (void)reveal {
    
    //  self从白色 变透明，让盖着的 image 可以看到
    self.backgroundColor = [UIColor clearColor];
    self.progress = 1;
    
    //  移除已有的隐式动画
    [_circlePathLayer removeAnimationForKey:@"strokeEnd"];
    
    //从 superLayer 移除 circlePathLayer，
    [_circlePathLayer removeFromSuperlayer];
    
    
    //  1、以 _circlePathLayer 作为 superView的layer maks
    //      （只有 mask 遮盖着的部分 是可见的）
    self.superview.layer.mask = _circlePathLayer;
    
    
    
    //  2、扩展环
    //    你可以两个分离的、同轴心的UIBezierPath来做到
    //    也可以一个更加有效的方法，只是使用一个Bezier path来完成。
    //     只增加圆的半径(path属性)来向外扩展，同时增加line的宽度(lineWidth属性)来使环更加厚和向内扩展。最终，两个值都增长到足够时就在下面显示整个image。
    
    //      2.1 self 的 center
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));   //  圆的标准方程(x－a)²+(y－b)²= r²中   圆心O（a，b），半径r
    
    //      2.2 向内收缩的圆 最终半径
    float finalRadius = sqrt((center.x * center.x) + (center.y * center.y));    //  sqrt 求平方根
    
    //      2.3 外圆初始半径 - 内圆最终半径 （差值）
    float radiusInset =  _circleRadius - finalRadius;
    //          外圆 最终的内切 正方形 frame
    CGRect outerRect = CGRectInset([self circleFrame], radiusInset, radiusInset);   // Note 4
    //      2.4 toPath表示CAShapeLayer mask的最终形状
    CGPathRef toPath = [UIBezierPath bezierPathWithOvalInRect:outerRect].CGPath;
    
    //  3、 fromPath 、fromLineWidth 记录 初始状态 和 线宽
    CGPathRef fromPath = _circlePathLayer.path;
    CGFloat fromLineWidth = _circlePathLayer.lineWidth;
    
    //  4、设置lineWidth和path的最终值；防止动画完成时跳回原始值。
    [CATransaction begin];     // Note 1、3
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    _circlePathLayer.path = toPath;
    _circlePathLayer.lineWidth = 2 * finalRadius;
    [CATransaction commit];

    //  5、lineWidth动画 （mask 的 内圆扩大）
    //     lineWidth 增加到两倍，保证跟半径增长速度一样快，这样圆形向内扩展与向外扩展同步
    CABasicAnimation * lineWidthAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    lineWidthAnimation.fromValue = @(fromLineWidth);
    lineWidthAnimation.toValue = @(2 * finalRadius);
    
    //  6、路径动画 （mask 的 外圆缩小）
    CABasicAnimation * pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge id)(fromPath);
    pathAnimation.toValue = (__bridge id)(toPath);

    // 7、、添加到 Animation Group 执行
    CAAnimationGroup * groupAnimation = [CAAnimationGroup animation];
    groupAnimation.duration = 1;
    groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    groupAnimation.animations = @[pathAnimation,lineWidthAnimation];
    groupAnimation.delegate = self;
    //  key ，移除时会用到
    [_circlePathLayer addAnimation:groupAnimation forKey:@"strokeWidth"];

}


//  self 的 center， 40 * 40 的正方形。（内部绘制一个内切圆）
- (CGRect)circleFrame
{
    CGRect circleFrame = CGRectMake(0, 0, 2*_circleRadius, 2*_circleRadius);
    circleFrame.origin.x = CGRectGetMidX(_circlePathLayer.bounds) - CGRectGetMidX(circleFrame);
    circleFrame.origin.y = CGRectGetMidY(_circlePathLayer.bounds) - CGRectGetMidY(circleFrame);
    return circleFrame;
}

#pragma mark - CAAnimation delegate

//  动画执行完时，移除 mask （否则，根据以上计算的 外圆 rect ，四个角不能完全填充）
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.superview.layer.mask = nil;
}

#pragma mark - Note 注释
/*
    Note:
 
1、 CATransaction 用法，类似于 UIView

    [UIView beginAnimations:nil context:nil];
     // some property change
    [UIView commitAnimations];
 
     [CATransaction begin];
     _circlePathLayer.path = toPath;
     [CATransaction commit];

 
2、设置 动画执行时间

    [CATransaction setValue:[NSNumber numberWithFloat:5.0f] forKey:kCATransactionAnimationDuration];
 
3、显式事务默认开启动画效果,kCFBooleanTrue禁用layer的implicit animations。
 
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
 
 4、CGRectInset 方法
    
    该结构体的应用是以原rect为中心，再参考dx，dy，进行缩放或者放大。

     CGRect outerRect = CGRectInset([self circleFrame], radiusInset, radiusInset);
 
 */

@end
