//
//  AlpVideoCameraUtils.h
//  AlpVideoCamera
//
//  Created by swae on 2018/9/16.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlpVideoCameraUtils : NSObject

/// 合并并导出视频
/// @param videosPathArray 需要合并的一组视频路径
/// @param outpath 合并完成后视频输出路径
/// @param watermarkImage 视频添加水印的图，没有则不添加，水印最好还是后台添加
/// @param completion 完成后的回调
+ (void)mergeVideos:(NSArray *)videosPathArray
                 exportPath:(NSString *)outpath
       watermarkImg:(UIImage * _Nullable )watermarkImage
                  completion:(nonnull void (^)(NSURL *outLocalURL))completion;

/// 在videoFolder文件中生成需要导入视频的路径字符串
+ (NSString *)getVideoMergeFilePathString;

/// 将UI的坐标转换成相机坐标
+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates frameSize:(CGSize)frameSize;

+ (void)createVideoFolderIfNotExist;

@end

NS_ASSUME_NONNULL_END
