//
//  AlpVideoCameraOptionsView.m
//  Alpface
//
//  Created by swae on 2018/9/23.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpVideoCameraOptionsView.h"
#import "AlpVideoCameraDefine.h"
#import "UIView+Tools.h"

@implementation AlpVideoCameraOptionsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setRecordState:(AlpVideoCameraRecordState)recordState {
    _recordState = recordState;
    if (_recordState == AlpVideoCameraRecordStateNotStart) {
        _inputLocalVieoBtn.hidden = NO;
        [self.progressPreView cancelProgress];
    }
    else if (_recordState == AlpVideoCameraRecordStateStart) {
        _inputLocalVieoBtn.hidden = YES;
        _camerafilterChangeButton.hidden = YES;
        _cameraPositionChangeButton.hidden = YES;
        self.timeButton.hidden = NO;
        _dleButton.hidden = YES;
        
//        _photoCaptureButton.backgroundColor = [UIColor colorWithRed:(float)0xfd/256.0 green:(float)0xd8/256.0 blue:(float)0x54/256.0 alpha:1];
//        _btView.backgroundColor = [UIColor colorWithRed:(float)0xfd/256.0 green:(float)0xd8/256.0 blue:(float)0x54/256.0 alpha:1];
    }
    else if (_recordState == AlpVideoCameraRecordStatePause) {
        _inputLocalVieoBtn.hidden = YES;
        _camerafilterChangeButton.hidden = NO;
        _cameraPositionChangeButton.hidden = NO;
//        _btView.backgroundColor = [UIColor colorWithRed:(float)0xfe/256.0 green:(float)0x65/256.0 blue:(float)0x53/256.0 alpha:1];
//        _photoCaptureButton.backgroundColor = [UIColor colorWithRed:(float)0xfe/256.0 green:(float)0x65/256.0 blue:(float)0x53/256.0 alpha:1];
        //        UISaveVideoAtPathToSavedPhotosAlbum(_pathToMovie, nil, nil, nil);
    }
    else if (_recordState == AlpVideoCameraRecordStateDone) {
        _inputLocalVieoBtn.hidden = YES;
        self.dleButton.hidden = YES;
        [self.progressPreView cancelProgress];
//        self.btView.backgroundColor = [UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1];
//        self.photoCaptureButton.backgroundColor = [UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1];
        self.cameraChangeButton.hidden = YES;
    }
}

- (void)setupUI {
    self.backgroundColor = UIColor.clearColor;
    [self addSubview:self.timeButton];
//    [self addSubview:self.btView];
    [self addSubview:self.photoCaptureButton];
    [self addSubview:self.backBtn];
    [self addSubview:self.cameraPositionChangeButton];
    [self addSubview:self.camerafilterChangeButton];
    [self addSubview:self.cameraChangeButton];
    [self addSubview:self.dleButton];
    [self addSubview:self.inputLocalVieoBtn];
    [self addSubview:self.progressPreView];
    
    self.timeButton.hidden = YES;
    self.timeButton.translatesAutoresizingMaskIntoConstraints = NO;
//    self.btView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoCaptureButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraPositionChangeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.camerafilterChangeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraChangeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.dleButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputLocalVieoBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressPreView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint constraintWithItem:self.timeButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.timeButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.photoCaptureButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.photoCaptureButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-50.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.photoCaptureButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:65.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.photoCaptureButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:65.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.backBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:25.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.backBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.backBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.backBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.backBtn attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;
    
    // 切换前后摄像头
    [NSLayoutConstraint constraintWithItem:self.cameraPositionChangeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backBtn attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.cameraPositionChangeButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.cameraPositionChangeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.cameraPositionChangeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.cameraPositionChangeButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;
    
    // 打开和关闭美颜按钮
    [NSLayoutConstraint constraintWithItem:self.camerafilterChangeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cameraPositionChangeButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.camerafilterChangeButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.cameraPositionChangeButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.camerafilterChangeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.cameraPositionChangeButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.camerafilterChangeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.cameraPositionChangeButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0].active = YES;
    
    
    // 完成录制按钮
    [NSLayoutConstraint constraintWithItem:self.cameraChangeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.photoCaptureButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.cameraChangeButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.photoCaptureButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:50].active = YES;
    [NSLayoutConstraint constraintWithItem:self.cameraChangeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:52.6].active = YES;
    [NSLayoutConstraint constraintWithItem:self.cameraChangeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0].active = YES;
    
    // 删除录制按钮
    [NSLayoutConstraint constraintWithItem:self.dleButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.photoCaptureButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.dleButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.photoCaptureButton attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-50.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.dleButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.dleButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0].active = YES;
    
    // 从相册中导入视频按钮
//    CGRectMake( 50 , SCREEN_HEIGHT - 105.0, 50, 50.0);
    [NSLayoutConstraint constraintWithItem:self.inputLocalVieoBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.cameraChangeButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.inputLocalVieoBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.dleButton attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.inputLocalVieoBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.dleButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.inputLocalVieoBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.dleButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0].active = YES;
    
    // 录制的进度条
    [self.progressPreView makeCornerRadius:2 borderColor:nil borderWidth:0];
    [NSLayoutConstraint constraintWithItem:self.progressPreView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:5.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.progressPreView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:5.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.progressPreView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.progressPreView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:5.0].active = YES;
    
    [self addSubview:self.permissionView];
    self.permissionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.permissionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.permissionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.permissionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.permissionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    
    [self bringSubviewToFront:self.backBtn];
    
    [self.permissionView updateHidden];
    
}

- (OSProgressView *)progressPreView {
    if (!_progressPreView) {
        CGFloat defaultHeight = 6.0;
        CGRect frame = CGRectMake(5.0,
                                  5.0,
                                  self.frame.size.width-10.0,
                                  defaultHeight);
        OSProgressView *progressView = [[OSProgressView alloc] initWithFrame:frame];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        progressView.progressTintColor = UIColorFromRGB(0xffc738);
        progressView.trackTintColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
        _progressPreView = progressView;
    }
    return _progressPreView;
}

- (AlpVideoCameraPermissionView *)permissionView {
    if (!_permissionView) {
        _permissionView = [AlpVideoCameraPermissionView new];
        _permissionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }
    return _permissionView;
}

- (UIButton *)timeButton {
    if (!_timeButton) {
        _timeButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 27.0, 80, 26.0)];
        _timeButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_timeButton setTitle:@"录制 00:00" forState:UIControlStateNormal];
        _timeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _timeButton.backgroundColor = [[UIColor redColor]  colorWithAlphaComponent:0.3];
        [_timeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _timeButton.layer.cornerRadius = 2.0;
        _timeButton.layer.masksToBounds = YES;
        _timeButton.contentEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
    }
    return _timeButton;
}

//- (UIView *)btView {
//    if (!_btView) {
//        _btView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 36.5, SCREEN_HEIGHT - 125, 73, 73)];
//        [_btView makeCornerRadius:36.5 borderColor:nil borderWidth:0];
//        _btView.backgroundColor = [UIColor colorWithRed:(float)0xfe/256.0 green:(float)0x65/256.0 blue:(float)0x53/256.0 alpha:1];
//    }
//    return _btView;
//}

- (UIButton *)photoCaptureButton {
    if (!_photoCaptureButton) {
        _photoCaptureButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 31.5, SCREEN_HEIGHT- 120, 63, 63)];
        _photoCaptureButton.backgroundColor = [UIColor clearColor];
//        _photoCaptureButton.backgroundColor = [UIColor colorWithRed:(float)0xfe/256.0 green:(float)0x65/256.0 blue:(float)0x53/256.0 alpha:1];
        [_photoCaptureButton setImage:[UIImage imageNamed:@"record_button_open_65x65_"] forState:UIControlStateNormal];
//        [_photoCaptureButton makeCornerRadius:31.5 borderColor:[UIColor blackColor] borderWidth:1.5];
    }
    return _photoCaptureButton;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        // 返回按钮
        UIButton* backBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 25, 30, 30)];
        backBtn.showsTouchWhenHighlighted = YES;
        [backBtn setImage:[UIImage imageNamed:@"BackToHome"] forState:UIControlStateNormal];
        _backBtn = backBtn;
    }
    return _backBtn;
}

- (UIButton *)cameraPositionChangeButton {
    if (!_cameraPositionChangeButton) {
        // 前后摄像头切换按钮
        _cameraPositionChangeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        UIImage* img2 = [UIImage imageNamed:@"icShootingFlip_31x31_"];
        [_cameraPositionChangeButton setImage:img2 forState:UIControlStateNormal];
    }
    return _cameraPositionChangeButton;
}

- (UIButton *)camerafilterChangeButton {
    if (!_camerafilterChangeButton) {
        _camerafilterChangeButton = [[UIButton alloc] init];
        _camerafilterChangeButton.frame = CGRectMake(_cameraPositionChangeButton.frame.origin.x, _cameraPositionChangeButton.frame.origin.y + 80, 30, 30);
        UIImage* img = [UIImage imageNamed:@"iconBeautyOff2_40x40_"];
        [_camerafilterChangeButton setImage:img forState:UIControlStateNormal];
        [_camerafilterChangeButton setImage:[UIImage imageNamed:@"iconBeautyOn2_40x40_"] forState:UIControlStateSelected];
    }
    return _camerafilterChangeButton;
}

- (UIButton *)cameraChangeButton {
    if (!_cameraChangeButton) {
        _cameraChangeButton  = [[UIButton alloc] init];
        _cameraChangeButton.hidden = YES;
        _cameraChangeButton.frame = CGRectMake(SCREEN_WIDTH - 100 , SCREEN_HEIGHT - 105.0, 52.6, 50.0);
        UIImage* img3 = [UIImage imageNamed:@"complete"];
        [_cameraChangeButton setImage:img3 forState:UIControlStateNormal];
    }
    return _cameraChangeButton;
}

- (UIButton *)dleButton {
    if (!_dleButton) {
        _dleButton = [[UIButton alloc] init];
        _dleButton.hidden = YES;
        _dleButton.frame = CGRectMake( 50 , SCREEN_HEIGHT - 105.0, 50, 50.0);
        UIImage* img4 = [UIImage imageNamed:@"del"];
        [_dleButton setImage:img4 forState:UIControlStateNormal];
    }
    return _dleButton;
}

- (UIButton *)inputLocalVieoBtn {
    if (!_inputLocalVieoBtn) {
        _inputLocalVieoBtn = [[UIButton alloc] init];
        //    _inputLocalVieoBtn.hidden = YES;
        _inputLocalVieoBtn.frame = CGRectMake( 50 , SCREEN_HEIGHT - 105.0, 50, 50.0);
        UIImage* img5 = [UIImage imageNamed:@"record_ico_input_1"];
        [_inputLocalVieoBtn setImage:img5 forState:UIControlStateNormal];
    }
    return _inputLocalVieoBtn;
}

@end
