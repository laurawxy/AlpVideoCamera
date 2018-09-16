//
//  ALPVideoCameraView.m
//  AlpVideoCamera
//
//  Created by swae on 2018/9/12.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "ALPVideoCameraView.h"
#import "GPUImageBeautifyFilter.h"
#import "LFGPUImageEmptyFilter.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlpEditVideoViewController.h"
#import "MBProgressHUD.h"
#import "UIView+Tools.h"
#import "SDAVAssetExportSession.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "AlpEditingPublishingViewController.h"
#import <Photos/Photos.h>
#import <Photos/PHImageManager.h>
#import "GPUImage.h"
#import "AlpVideoCameraDefine.h"


typedef NS_ENUM(NSInteger, CameraManagerDevicePosition) {
    CameraManagerDevicePositionBack,
    CameraManagerDevicePositionFront,
};


@interface ALPVideoCameraView ()<TZImagePickerControllerDelegate>
{
    GPUImageVideoCamera *_videoCamera;
    GPUImageOutput<GPUImageInput> *_filter;
    GPUImageMovieWriter *_movieWriter;
    NSString *_pathToMovie;
    GPUImageView *_filteredVideoView;
    CALayer *_focusLayer;
    NSTimer *_myTimer;
    UILabel *_timeLabel;
    NSDate *_fromdate;
    CGRect _mainScreenFrame;
    
    float _preLayerWidth;//镜头宽
    float _preLayerHeight;//镜头高
    float _preLayerHWRate; //高，宽比
    NSMutableArray* _urlArray;
    float _totalTime; //视频总长度 默认10秒
    float _currentTime; //当前视频长度
    float _lastTime; //记录上次时间
    UIView* _progressPreView; //进度条
    float _progressStep; //进度条每次变长的最小单位
    MBProgressHUD* _HUD;
}
@property (nonatomic ,strong) UIButton *camerafilterChangeButton;
@property (nonatomic ,strong) UIButton *cameraPositionChangeButton;
@property (nonatomic, assign) CameraManagerDevicePosition position;
@property (nonatomic, strong) UIButton *photoCaptureButton;
@property (nonatomic, strong) UIButton *cameraChangeButton;
@property (nonatomic, strong) UIButton *dleButton;

@property (nonatomic, strong) UIButton *inputLocalVieoBtn;
@property (nonatomic, strong) NSMutableArray *lastAry;

@property (nonatomic, strong) UIView* btView;

@property (nonatomic, assign) BOOL isRecoding;
@end

@implementation ALPVideoCameraView

- (instancetype) initWithFrame:(CGRect)frame{
    if (!(self = [super initWithFrame:frame]))
    {
        return nil;
    }
    [self setup];
    
    //    [videoCamera removeAllTargets];
    //    filter = [[GPUImageBeautifyFilter alloc] init];
    //    [videoCamera addTarget:beautifyFilter];
    //    [beautifyFilter addTarget:_filteredVideoView];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if (_totalTime==0) {
        _totalTime =10;
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notCloseCor) name:@"closeVideoCamerOne" object:nil];
    
    _lastTime = 0;
    _progressStep = SCREEN_WIDTH*TIMER_INTERVAL/_totalTime;
    _preLayerWidth = SCREEN_WIDTH;
    _preLayerHeight = SCREEN_HEIGHT;
    _preLayerHWRate =_preLayerHeight/_preLayerWidth;
    _lastAry = [[NSMutableArray alloc] init];
    _urlArray = [[NSMutableArray alloc]init];
    [self createVideoFolderIfNotExist];
    _mainScreenFrame = self.frame;
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    if ([_videoCamera.inputCamera lockForConfiguration:nil]) {
        //自动对焦
        if ([_videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [_videoCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([_videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [_videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        //自动白平衡
        if ([_videoCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [_videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [_videoCamera.inputCamera unlockForConfiguration];
    }
    
    _position = CameraManagerDevicePositionBack;
    //    videoCamera.frameRate = 10;
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [_videoCamera addAudioInputsAndOutputs];
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    
    _filter = [[LFGPUImageEmptyFilter alloc] init];
    _filteredVideoView = [[GPUImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_videoCamera addTarget:_filter];
    [_filter addTarget:_filteredVideoView];
    [_videoCamera startCameraCapture];
    [self addSomeView];
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraViewTapAction:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    [_filteredVideoView addGestureRecognizer:singleFingerOne];
    [self addSubview:_filteredVideoView];
}
- (void) addSomeView{
    //    253 91 73
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 27.0, 80, 26.0)];
    _timeLabel.font = [UIFont systemFontOfSize:13.0f];
    _timeLabel.text = @"录制 00:00";
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.backgroundColor = [UIColor colorWithRed:253/256.0 green:91/256.0 blue:73/256.0 alpha:1];
    _timeLabel.textColor = [UIColor whiteColor];
    [_filteredVideoView addSubview:_timeLabel];
    //    [[AppDelegate appDelegate].cmImageSize setLabelsRounded:_timeLabel cornerRadiusValue:2 borderWidthValue:0 borderColorWidthValue:[UIColor clearColor]];
    _timeLabel.hidden = YES;
    
    
    _btView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 36.5, SCREEN_HEIGHT - 125, 73, 73)];
    [_btView makeCornerRadius:36.5 borderColor:nil borderWidth:0];
    _btView.backgroundColor = [UIColor colorWithRed:(float)0xfe/256.0 green:(float)0x65/256.0 blue:(float)0x53/256.0 alpha:1];
    [_filteredVideoView addSubview:_btView];
    
    _photoCaptureButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 31.5, SCREEN_HEIGHT- 120, 63, 63)];
    _photoCaptureButton.backgroundColor = [UIColor colorWithRed:(float)0xfe/256.0 green:(float)0x65/256.0 blue:(float)0x53/256.0 alpha:1];
    
    [_photoCaptureButton addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchUpInside];
    [_photoCaptureButton makeCornerRadius:31.5 borderColor:[UIColor blackColor] borderWidth:1.5];
    
    [_filteredVideoView addSubview:_photoCaptureButton];
    
    
    _camerafilterChangeButton = [[UIButton alloc] init];
    _camerafilterChangeButton.frame = CGRectMake(SCREEN_WIDTH - 160,  25, 30.0, 30.0);
    UIImage* img = [UIImage imageNamed:@"beautyOFF"];
    [_camerafilterChangeButton setImage:img forState:UIControlStateNormal];
    [_camerafilterChangeButton setImage:[UIImage imageNamed:@"beautyON"] forState:UIControlStateSelected];
    [_camerafilterChangeButton addTarget:self action:@selector(changebeautifyFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_filteredVideoView addSubview:_camerafilterChangeButton];
    
    UIButton* backBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 25, 30, 30)];
    [backBtn setImage:[UIImage imageNamed:@"BackToHome"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickBackToHome) forControlEvents:UIControlEventTouchUpInside];
    [_filteredVideoView addSubview:backBtn];
    
    _cameraPositionChangeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 110, 25, 30, 30)];
    UIImage* img2 = [UIImage imageNamed:@"cammera"];
    [_cameraPositionChangeButton setImage:img2 forState:UIControlStateNormal];
    [_cameraPositionChangeButton addTarget:self action:@selector(changeCameraPositionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_filteredVideoView addSubview:_cameraPositionChangeButton];
    
    _cameraChangeButton  = [[UIButton alloc] init];
    _cameraChangeButton.hidden = YES;
    _cameraChangeButton.frame = CGRectMake(SCREEN_WIDTH - 100 , SCREEN_HEIGHT - 105.0, 52.6, 50.0);
    UIImage* img3 = [UIImage imageNamed:@"complete"];
    [_cameraChangeButton setImage:img3 forState:UIControlStateNormal];
    [_cameraChangeButton addTarget:self action:@selector(stopRecording:) forControlEvents:UIControlEventTouchUpInside];
    [_filteredVideoView addSubview:_cameraChangeButton];
    
    _dleButton = [[UIButton alloc] init];
    _dleButton.hidden = YES;
    _dleButton.frame = CGRectMake( 50 , SCREEN_HEIGHT - 105.0, 50, 50.0);
    UIImage* img4 = [UIImage imageNamed:@"del"];
    [_dleButton setImage:img4 forState:UIControlStateNormal];
    [_dleButton addTarget:self action:@selector(clickDleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_filteredVideoView addSubview:_dleButton];
    
    _inputLocalVieoBtn = [[UIButton alloc] init];
    //    _inputLocalVieoBtn.hidden = YES;
    _inputLocalVieoBtn.frame = CGRectMake( 50 , SCREEN_HEIGHT - 105.0, 50, 50.0);
    UIImage* img5 = [UIImage imageNamed:@"record_ico_input_1"];
    [_inputLocalVieoBtn setImage:img5 forState:UIControlStateNormal];
    [_inputLocalVieoBtn addTarget:self action:@selector(clickInputBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_filteredVideoView addSubview:_inputLocalVieoBtn];
    
    
    _progressPreView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT -4 , 0, 4)];
    _progressPreView.backgroundColor = UIColorFromRGB(0xffc738);
    [_progressPreView makeCornerRadius:2 borderColor:nil borderWidth:0];
    [_filteredVideoView addSubview:_progressPreView];
    
    
}


- (void)startRecording:(UIButton*)sender {
    _inputLocalVieoBtn.hidden = YES;
    if (!sender.selected) {
        
        _lastTime = _currentTime;
        [_lastAry addObject:[NSString stringWithFormat:@"%f",_lastTime]];
        _camerafilterChangeButton.hidden = YES;
        _cameraPositionChangeButton.hidden = YES;
        _timeLabel.hidden = NO;
        _dleButton.hidden = YES;
        
        sender.selected = YES;
        _pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/Movie%lu.mov",(unsigned long)_urlArray.count]];
        unlink([_pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        NSURL *movieURL = [NSURL fileURLWithPath:_pathToMovie];
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
        _movieWriter.isNeedBreakAudioWhiter = YES;
        _movieWriter.encodingLiveVideo = YES;
        _movieWriter.shouldPassthroughAudio = YES;
        [_filter addTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = _movieWriter;
        [_movieWriter startRecording];
        _isRecoding = YES;
        _photoCaptureButton.backgroundColor = [UIColor colorWithRed:(float)0xfd/256.0 green:(float)0xd8/256.0 blue:(float)0x54/256.0 alpha:1];
        _btView.backgroundColor = [UIColor colorWithRed:(float)0xfd/256.0 green:(float)0xd8/256.0 blue:(float)0x54/256.0 alpha:1];
        _fromdate = [NSDate date];
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                   target:self
                                                 selector:@selector(updateTimer:)
                                                 userInfo:nil
                                                  repeats:YES];
        
    }else
    {
        
        _camerafilterChangeButton.hidden = NO;
        _cameraPositionChangeButton.hidden = NO;
        sender.selected = NO;
        _videoCamera.audioEncodingTarget = nil;
        NSLog(@"Path %@",_pathToMovie);
        if (_pathToMovie == nil) {
            return;
        }
        _btView.backgroundColor = [UIColor colorWithRed:(float)0xfe/256.0 green:(float)0x65/256.0 blue:(float)0x53/256.0 alpha:1];
        _photoCaptureButton.backgroundColor = [UIColor colorWithRed:(float)0xfe/256.0 green:(float)0x65/256.0 blue:(float)0x53/256.0 alpha:1];
        //        UISaveVideoAtPathToSavedPhotosAlbum(_pathToMovie, nil, nil, nil);
        if (_isRecoding) {
            [_movieWriter finishRecording];
            [_filter removeTarget:_movieWriter];
            [_urlArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_pathToMovie]]];
            _isRecoding = NO;
        }
        [_myTimer invalidate];
        _myTimer = nil;
        if (_urlArray.count) {
            _dleButton.hidden = NO;
        }
    }
    
    
}

- (void)stopRecording:(id)sender {
    _videoCamera.audioEncodingTarget = nil;
    NSLog(@"Path %@",_pathToMovie);
    if (_pathToMovie == nil) {
        return;
    }
    //    UISaveVideoAtPathToSavedPhotosAlbum(_pathToMovie, nil, nil, nil);
    if (_isRecoding) {
        [_movieWriter finishRecording];
        [_filter removeTarget:_movieWriter];
        _isRecoding = NO;
    }
    
    _timeLabel.text = @"录制 00:00";
    [_myTimer invalidate];
    _myTimer = nil;
    _HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
    _HUD.label.text = @"视频生成中...";
    if (_photoCaptureButton.selected) {
        [_urlArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_pathToMovie]]];
    }
    
    //    [_urlArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_pathToMovie]]];
    //    [self mergeAndExportVideosAtFileURLs:_urlArray];
    NSString *path = [self getVideoMergeFilePathString];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self mergeAndExportVideos:_urlArray withOutPath:path];
        [_urlArray removeAllObjects];
        [_lastAry removeAllObjects];
        _currentTime = 0;
        _lastTime = 0;
        _dleButton.hidden = YES;
        [_progressPreView setFrame:CGRectMake(0, SCREEN_HEIGHT - 4, 0, 4)];
        _btView.backgroundColor = [UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1];
        _photoCaptureButton.backgroundColor = [UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1];
        _photoCaptureButton.selected = NO;
        _cameraChangeButton.hidden = YES;
        
        
    });
    
    
    
    
    //    http://blog.csdn.net/ismilesky/article/details/51920113  视频与音乐合成
    //    http://www.jianshu.com/p/0f9789a6d99a 视频与音乐合成
    
    
    //[_movieWriter cancelRecording];
}
-(void)clickDleBtn:(UIButton*)sender {
    float progressWidth = [_lastAry.lastObject floatValue]/10*SCREEN_WIDTH;
    [_progressPreView setFrame:CGRectMake(0, SCREEN_HEIGHT - 4, progressWidth, 4)];
    _currentTime = [_lastAry.lastObject floatValue];
    _timeLabel.text = [NSString stringWithFormat:@"录制 00:0%.0f",_currentTime];
    if (_urlArray.count) {
        [_urlArray removeLastObject];
        [_lastAry removeLastObject];
        if (_urlArray.count == 0) {
            _dleButton.hidden = YES;
        }
        if (_currentTime < 3) {
            _cameraChangeButton.hidden = YES;
        }
    }
    
}
-(void)clickInputBtn:(UIButton*)sender {
    TZImagePickerController* imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.isSelectOriginalPhoto = NO;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingImage = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.sortAscendingByModificationDate = YES;
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage,id asset) {
        _HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
        _HUD.label.text = @"视频导出中...";
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
            PHAsset* myasset = asset;
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            //            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            options.version = PHImageRequestOptionsVersionCurrent;
            options.networkAccessAllowed = true; // iCloud的相册需要网络许可，否则icloud中的取出为nil
            PHImageManager *manager = [PHImageManager defaultManager];
            [manager requestAVAssetForVideo:myasset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                if(![asset isKindOfClass:[AVURLAsset class]]){
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    NSURL *url = urlAsset.URL;
                    NSData* videoData = [NSData dataWithContentsOfFile:[[url absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
                    if (videoData.length>1024*1024*4.5) {
                        _HUD.label.text = @"所选视频大于5M,请重新选择";
                        [_HUD hide:YES afterDelay:1.5];
                    }else
                    {
                        AlpEditingPublishingViewController* cor = [[AlpEditingPublishingViewController alloc] init];
                        cor.videoURL = url;
                        
                        [[NSNotificationCenter defaultCenter] removeObserver:self];
                        [_videoCamera stopCameraCapture];
                        //                     [[AppDelegate appDelegate] pushViewController:cor animated:YES];
                        if (self.delegate&&[self.delegate respondsToSelector:@selector(videoCamerView:pushViewCotroller:)]) {
                            [self.delegate videoCamerView:self pushViewCotroller:cor];
                        }
                        [self removeFromSuperview];
                        
                    }
                });
                
            }];
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                ALAsset* myasset = asset;
                NSURL *videoURL =[myasset valueForProperty:ALAssetPropertyAssetURL];
                NSURL *url = videoURL;
                NSData* videoData = [NSData dataWithContentsOfFile:[[url absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
                if (videoData.length>1024*1024*4.5) {
                    _HUD.label.text = @"所选视频大于5M,请重新选择";
                    [_HUD hide:YES afterDelay:1.5];
                }else
                {
                    AlpEditingPublishingViewController* cor = [[AlpEditingPublishingViewController alloc] init];
                    cor.videoURL = url;
                    
                    [[NSNotificationCenter defaultCenter] removeObserver:self];
                    [_videoCamera stopCameraCapture];
                    //                    [[AppDelegate appDelegate] pushViewController:cor animated:YES];
                    if (self.delegate&&[self.delegate respondsToSelector:@selector(videoCamerView:pushViewCotroller:)]) {
                        [self.delegate videoCamerView:self pushViewCotroller:cor];
                    }
                    [self removeFromSuperview];
                }
                
            });
            
            
            
        }
        
        
        NSLog(@"选择结束");
        
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //    [[AppDelegate appDelegate] presentViewController:imagePickerVc animated:YES completion:^{
    
    //    }];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(videoCamerView:presentViewCotroller:)]) {
        [self.delegate videoCamerView:self presentViewCotroller:imagePickerVc];
    }
    
}
- (void)mergeAndExportVideos:(NSArray*)videosPathArray withOutPath:(NSString*)outpath{
    if (videosPathArray.count == 0) {
        return;
    }
    //音频视频合成体
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //创建音频通道容器
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    //创建视频通道容器
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    UIImage* waterImg = [UIImage imageNamed:@"icon_watermark"];
    CMTime totalDuration = kCMTimeZero;
    for (int i = 0; i < videosPathArray.count; i++) {
        //        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videosPathArray[i]]];
        NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVAsset* asset = [AVURLAsset URLAssetWithURL:videosPathArray[i] options:options];
        
        NSError *erroraudio = nil;
        //获取AVAsset中的音频 或者视频
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        //向通道内加入音频或者视频
        BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetAudioTrack
                                       atTime:totalDuration
                                        error:&erroraudio];
        
        NSLog(@"erroraudio:%@%d",erroraudio,ba);
        NSError *errorVideo = nil;
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetVideoTrack
                                       atTime:totalDuration
                                        error:&errorVideo];
        
        NSLog(@"errorVideo:%@%d",errorVideo,bl);
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    }
    NSLog(@"%@",NSHomeDirectory());
    
    //创建视频水印layer 并添加到视频layer上
    //2017 年 04 月 19 日 视频水印由后台统一转码添加   del by hyy；
    CGSize videoSize = [videoTrack naturalSize];
    CALayer* aLayer = [CALayer layer];
    aLayer.contents = (id)waterImg.CGImage;
    aLayer.frame = CGRectMake(videoSize.width - waterImg.size.width - 30, videoSize.height - waterImg.size.height*3, waterImg.size.width, waterImg.size.height);
    aLayer.opacity = 0.9;
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:aLayer];
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    
    
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack* mixVideoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    
    NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
    
    //视频导出工具
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPreset1280x720];
    exporter.videoComposition = videoComp;
    /*
     exporter.progress
     导出进度
     This property is not key-value observable.
     不支持kvo 监听
     只能用定时器监听了  NStimer
     */
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    __weak typeof(self) weakSelf = self;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_videoCamera stopCameraCapture];
            
            AlpEditVideoViewController* vc = [[AlpEditVideoViewController alloc]init];
            vc.width = weakSelf.width;
            vc.hight = weakSelf.hight;
            vc.bit = weakSelf.bit;
            vc.frameRate = weakSelf.frameRate;
            vc.videoURL = [NSURL fileURLWithPath:outpath];;
            [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
            //            [[AppDelegate sharedAppDelegate] pushViewController:view animated:YES];
            if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(videoCamerView:pushViewCotroller:)]) {
                [weakSelf.delegate videoCamerView:weakSelf pushViewCotroller:vc];
            }
            [weakSelf removeFromSuperview];
        });
        
        
    }];
    
    
    ////    UIImage* waterImg = [UIImage imageNamed:@"LDWatermark"];
    //    CMTime totalDuration = kCMTimeZero;
    //    for (int i = 0; i < videosPathArray.count; i++) {
    ////        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videosPathArray[i]]];
    //        NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    //        AVAsset* asset = [AVURLAsset URLAssetWithURL:videosPathArray[i] options:options];
    //
    //        NSError *erroraudio = nil;
    //        //获取AVAsset中的音频 或者视频
    //        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //        //向通道内加入音频或者视频
    //        BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
    //                                      ofTrack:assetAudioTrack
    //                                       atTime:totalDuration
    //                                        error:&erroraudio];
    //
    //        NSLog(@"erroraudio:%@%d",erroraudio,ba);
    //        NSError *errorVideo = nil;
    //        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    //        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
    //                                      ofTrack:assetVideoTrack
    //                                       atTime:totalDuration
    //                                        error:&errorVideo];
    //
    //        NSLog(@"errorVideo:%@%d",errorVideo,bl);
    //        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    //    }
    //    NSLog(@"%@",NSHomeDirectory());
    //
    //    //创建视频水印layer 并添加到视频layer上
    //    //2017 年 04 月 19 日 视频水印由后台统一转码添加   del by hyy；
    ////    CGSize videoSize = [videoTrack naturalSize];
    ////    CALayer* aLayer = [CALayer layer];
    ////    aLayer.contents = (id)waterImg.CGImage;
    ////    aLayer.frame = CGRectMake(videoSize.width - waterImg.size.width - 30, videoSize.height - waterImg.size.height*3, waterImg.size.width, waterImg.size.height);
    ////    aLayer.opacity = 0.9;
    ////
    ////    CALayer *parentLayer = [CALayer layer];
    ////    CALayer *videoLayer = [CALayer layer];
    ////    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    ////    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    ////    [parentLayer addSublayer:videoLayer];
    ////    [parentLayer addSublayer:aLayer];
    ////    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    ////    videoComp.renderSize = videoSize;
    ////
    ////
    ////    videoComp.frameDuration = CMTimeMake(1, 30);
    ////    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    ////    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    ////
    ////    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    ////    AVAssetTrack* mixVideoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    ////    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
    ////    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    ////    videoComp.instructions = [NSArray arrayWithObject: instruction];
    //
    //
    //    NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
    //
    //    //视频导出工具
    //    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
    //                                                                      presetName:AVAssetExportPreset1280x720];
    ////    exporter.videoComposition = videoComp;
    //    /*
    //    exporter.progress
    //     导出进度
    //     This property is not key-value observable.
    //     不支持kvo 监听
    //     只能用定时器监听了  NStimer
    //     */
    //    exporter.outputURL = mergeFileURL;
    //    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    //    exporter.shouldOptimizeForNetworkUse = YES;
    //    [exporter exportAsynchronouslyWithCompletionHandler:^{
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //
    //            [videoCamera stopCameraCapture];
    //
    //            EditVideoViewController* view = [[EditVideoViewController alloc]init];
    //            view.width = _width;
    //            view.hight = _hight;
    //            view.bit = _bit;
    //            view.frameRate = _frameRate;
    //            view.videoURL = [NSURL fileURLWithPath:outpath];;
    //            [[NSNotificationCenter defaultCenter] removeObserver:self];
    //            [[AppDelegate sharedAppDelegate] pushViewController:view animated:YES];
    //            [self removeFromSuperview];
    //        });
    //
    //
    //        }];
}


- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
//最后合成为 mp4
- (NSString *)getVideoMergeFilePathString
{
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *path = [paths objectAtIndex:0];
    
    //沙盒中Temp路径
    NSString *tempPath = NSTemporaryDirectory();
    
    NSString* path = [tempPath stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mov"];
    
    return fileName;
}

- (void)createVideoFolderIfNotExist
{
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *path = [paths objectAtIndex:0];
    
    //沙盒中Temp路径
    NSString *tempPath = NSTemporaryDirectory();
    NSString *folderPath = [tempPath stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建保存视频文件夹失败");
        }
    }
}
-(void)clickBackToHome
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_videoCamera stopCameraCapture];
    if (_isRecoding) {
        [_movieWriter cancelRecording];
        [_filter removeTarget:_movieWriter];
        _isRecoding = NO;
    }
    [_myTimer invalidate];
    _myTimer = nil;
    if (self.backToHomeBlock) {
        NSLog(@"clickBacktoHome");
        self.backToHomeBlock();
        [self removeFromSuperview];
    }
    
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    
    
    
    
}
-(void)changeCameraPositionBtn:(UIButton*)sender{
    
    switch (_position) {
        case CameraManagerDevicePositionBack: {
            if (_videoCamera.cameraPosition == AVCaptureDevicePositionBack) {
                [_videoCamera pauseCameraCapture];
                _position = CameraManagerDevicePositionFront;
                //                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [_videoCamera rotateCamera];
                [_videoCamera resumeCameraCapture];
                
                sender.selected = YES;
                [_videoCamera removeAllTargets];
                //        filter = [[GPUImageBeautifyFilter alloc] init];
                _camerafilterChangeButton.selected = YES;
                _filter = [[GPUImageBeautifyFilter alloc] init];
                [_videoCamera addTarget:_filter];
                [_filter addTarget:_filteredVideoView];
                
                
                //                });
            }
        }
            break;
        case CameraManagerDevicePositionFront: {
            if (_videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
                [_videoCamera pauseCameraCapture];
                _position = CameraManagerDevicePositionBack;
                
                //                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [_videoCamera rotateCamera];
                [_videoCamera resumeCameraCapture];
                
                sender.selected = NO;
                [_videoCamera removeAllTargets];
                _camerafilterChangeButton.selected = NO;
                _filter = [[LFGPUImageEmptyFilter alloc] init];
                [_videoCamera addTarget:_filter];
                [_filter addTarget:_filteredVideoView];
                //                });
            }
        }
            break;
        default:
            break;
    }
    
    if ([_videoCamera.inputCamera lockForConfiguration:nil] && [_videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [_videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [_videoCamera.inputCamera unlockForConfiguration];
    }
    
    
    
}
- (void)changebeautifyFilterBtn:(UIButton*)sender{
    if (!sender.selected) {
        
        sender.selected = YES;
        [_videoCamera removeAllTargets];
        //        filter = [[GPUImageBeautifyFilter alloc] init];
        _filter = [[GPUImageBeautifyFilter alloc] init];
        [_videoCamera addTarget:_filter];
        [_filter addTarget:_filteredVideoView];
        
        
    }else
    {
        sender.selected = NO;
        [_videoCamera removeAllTargets];
        _filter = [[LFGPUImageEmptyFilter alloc] init];
        [_videoCamera addTarget:_filter];
        [_filter addTarget:_filteredVideoView];
    }
}


- (void)updateTimer:(NSTimer *)sender{
    //    NSDateFormatter *dateFormator = [[NSDateFormatter alloc] init];
    //    dateFormator.dateFormat = @"HH:mm:ss";
    //    NSDate *todate = [NSDate date];
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    //    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
    //    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    //    NSDateComponents *comps  = [calendar components:unitFlags _fromdate:_fromdate toDate:todate options:NSCalendarWrapComponents];
    //    //NSInteger hour = [comps hour];
    //    //NSInteger min = [comps minute];
    //    //NSInteger sec = [comps second];
    //    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    NSDate *timer = [gregorian dateFromComponents:comps];
    //    NSString *date = [dateFormator string_fromdate:timer];
    
    
    _currentTime += TIMER_INTERVAL;
    
    
    //    _timeLabel.text = [NSString stringWithFormat:@"录制 00:02%d",(int)_currentTime];
    if (_currentTime>=10) {
        _timeLabel.text = [NSString stringWithFormat:@"录制 00:%d",(int)_currentTime];
    }else
    {
        _timeLabel.text = [NSString stringWithFormat:@"录制 00:0%.0f",_currentTime];
    }
    
    float progressWidth = _progressPreView.frame.size.width+_progressStep;
    [_progressPreView setFrame:CGRectMake(0, SCREEN_HEIGHT - 4, progressWidth, 4)];
    if (_currentTime>3) {
        _cameraChangeButton.hidden = NO;
    }
    
    //时间到了停止录制视频
    if (_currentTime>=_totalTime) {
        
        _photoCaptureButton.enabled = NO;
        
        [self stopRecording:nil];
    }
}

- (void)setfocusImage{
    UIImage *focusImage = [UIImage imageNamed:@"96"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width, focusImage.size.height)];
    imageView.image = focusImage;
    CALayer *layer = imageView.layer;
    layer.hidden = YES;
    [_filteredVideoView.layer addSublayer:layer];
    _focusLayer = layer;
    
}

- (void)layerAnimationWithPoint:(CGPoint)point {
    if (_focusLayer) {
        CALayer *focusLayer = _focusLayer;
        focusLayer.hidden = NO;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [focusLayer setPosition:point];
        focusLayer.transform = CATransform3DMakeScale(2.0f,2.0f,1.0f);
        [CATransaction commit];
        
        
        CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
        animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(1.0f,1.0f,1.0f)];
        //        animation.delegate = self;
        animation.duration = 0.3f;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [focusLayer addAnimation: animation forKey:@"animation"];
        
        // 0.5秒钟延时
        [self performSelector:@selector(focusLayerNormal) withObject:self afterDelay:0.5f];
    }
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
}


- (void)focusLayerNormal {
    _filteredVideoView.userInteractionEnabled = YES;
    _focusLayer.hidden = YES;
}

/**
 @abstract 将UI的坐标转换成相机坐标
 */
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _filteredVideoView.frame.size;
    CGSize apertureSize = CGSizeMake(1280, 720);//设备采集分辨率
    CGPoint point = viewCoordinates;
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    CGFloat xc = .5f;
    CGFloat yc = .5f;
    
    if (viewRatio > apertureRatio) {
        CGFloat y2 = frameSize.height;
        CGFloat x2 = frameSize.height * apertureRatio;
        CGFloat x1 = frameSize.width;
        CGFloat blackBar = (x1 - x2) / 2;
        if (point.x >= blackBar && point.x <= blackBar + x2) {
            xc = point.y / y2;
            yc = 1.f - ((point.x - blackBar) / x2);
        }
    }else {
        CGFloat y2 = frameSize.width / apertureRatio;
        CGFloat y1 = frameSize.height;
        CGFloat x2 = frameSize.width;
        CGFloat blackBar = (y1 - y2) / 2;
        if (point.y >= blackBar && point.y <= blackBar + y2) {
            xc = ((point.y - blackBar) / y2);
            yc = 1.f - (point.x / x2);
        }
    }
    pointOfInterest = CGPointMake(xc, yc);
    return pointOfInterest;
}


-(void)cameraViewTapAction:(UITapGestureRecognizer *)tgr
{
    if (tgr.state == UIGestureRecognizerStateRecognized && (_focusLayer == nil || _focusLayer.hidden)) {
        CGPoint location = [tgr locationInView:_filteredVideoView];
        [self setfocusImage];
        [self layerAnimationWithPoint:location];
        AVCaptureDevice *device = _videoCamera.inputCamera;
        //        CGPoint pointOfInterest = CGPointMake(0.5f, 0.5f);
        //        NSLog(@"taplocation x = %f y = %f", location.x, location.y);
        //        CGSize frameSize = [_filteredVideoView frame].size;
        //
        //        if ([videoCamera cameraPosition] == AVCaptureDevicePositionFront) {
        //            location.x = frameSize.width - location.x;
        //        }
        //
        //        pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        CGPoint pointOfInterest = [self convertToPointOfInterestFromViewCoordinates:location];
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [device setFocusPointOfInterest:pointOfInterest];
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                
            }
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [device unlockForConfiguration];
            
            NSLog(@"FOCUS OK");
        } else {
            NSLog(@"ERROR = %@", error);
        }
        
        
        
    }
}
-(void)notCloseCor {
    [self clickBackToHome];
}

-(void)dealloc {
    NSLog(@"%@释放了",self.class);
}
@end

