//
//  GLImageAddStickerWithEffectFilter.h
//  WEOpenGLKit
//
//  Created by LHD on 2018/6/4.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "GLImageStickerFilter.h"
#import "GPUImageHSBFilter.h"
#import "GLImageGassianBlurMixFilter.h"
#import "GPUImagePicture.h"

@interface GLImageAddStickerWithEffectFilter : GPUImageFilterGroup
{
    GLImageStickerFilter *stickerFiler;
    GPUImagePicture *stickerImageSource;
}

/** 贴纸大小（需要归一化，如果不设置则取贴纸真实尺寸和super的尺寸比值） */
@property (nonatomic, assign) CGSize size;
/** 中心坐标（需要归一化） */
@property (nonatomic, assign) CGPoint center;
/** 旋转角（弧度） */
@property (nonatomic, assign) CGFloat theta;
/** 透明度 */
@property (nonatomic, assign) CGFloat alpha;
/** 混合模式 */
@property (nonatomic, assign) int blendMode;

/** 设置贴纸图片 */
- (void)setStickerImage:(UIImage *)stickerImage;

@end


@interface GLImageAddStickerWithEffectFilter (Effect)

/** 打开模糊 */
@property (nonatomic, assign) BOOL enableBlur;
/** 模糊半径 */
@property (nonatomic, assign) CGFloat blurRadiusInPixels;
/** 模糊程度 */
@property (nonatomic, assign) CGFloat blur;
/** 打开色相 */
@property (nonatomic, assign) BOOL enableHue;
/** 色相偏差 */
@property (nonatomic, assign) CGFloat hue;

@end
