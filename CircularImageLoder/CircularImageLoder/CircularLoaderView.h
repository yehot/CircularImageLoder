//
//  CircularLoaderView.h
//  CircularImageLoder
//
//  Created by yehot on 15/8/31.
//  Copyright (c) 2015年 Yehao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularLoaderView : UIView

@property (nonatomic, assign) CGFloat progress;     // 圆环的进度

/**
 *  执行动画
 */
- (void)reveal;

@end
