//
//  ALPVideoCameraView.h
//  AlpVideoCamera
//
//  Created by swae on 2018/9/12.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^clickBackToHomeBtnBlock)();

@class ALPVideoCameraView;

@protocol ALPVideoCameraViewDelegate <NSObject>

- (void)videoCamerView:(ALPVideoCameraView *)view presentViewCotroller:(UIViewController *)viewController;
- (void)videoCamerView:(ALPVideoCameraView *)view pushViewCotroller:(UIViewController *)viewController;

@end

@interface ALPVideoCameraView : UIView {
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    NSString *pathToMovie;
    GPUImageView *filteredVideoView;
    CALayer *_focusLayer;
    NSTimer *myTimer;
    UILabel *timeLabel;
    NSDate *fromdate;
    CGRect mainScreenFrame;
}

@property (nonatomic , copy) clickBackToHomeBtnBlock backToHomeBlock;

@property (nonatomic , strong) NSNumber* width;
@property (nonatomic , strong) NSNumber* hight;
@property (nonatomic , strong) NSNumber* bit;
@property (nonatomic , strong) NSNumber* frameRate;
@property (nonatomic, weak) id<ALPVideoCameraViewDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
