//
//  ViewController.m
//  AlpVideoCamera
//
//  Created by xiaoyuan on 2018/9/12.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "ViewController.h"
#import <RTRootNavigationController.h>
#import "AlpVideoCameraViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.button];
    [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0].active = YES;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        [_button setTitle:@"Video camera" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setBackgroundColor:[UIColor blueColor]];
        [_button addTarget:self action:@selector(gotoVideoCamera) forControlEvents:UIControlEventTouchUpInside];
        _button.layer.cornerRadius = 5.0;
        _button.layer.masksToBounds = YES;
    }
    return _button;
}

- (void)gotoVideoCamera {
    RTRootNavigationController *cameraNac =[[RTRootNavigationController alloc]initWithRootViewControllerNoWrapping:AlpVideoCameraViewController.new];
    [self showDetailViewController:cameraNac sender:self];
}

@end
