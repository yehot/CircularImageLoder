//
//  ViewController.m
//  CircularImageLoder
//
//  Created by yehot on 15/8/31.
//  Copyright (c) 2015年 Yehao. All rights reserved.
//

#import "ViewController.h"
#import "CustomImageView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CustomImageView * imageView = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
    [self.view addSubview:imageView];

}


@end
