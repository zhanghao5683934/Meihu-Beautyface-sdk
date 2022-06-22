//
//  GLImageStickerFilter.h
//  WEOpenGLKit
//
//  Created by LHD on 2018/6/4.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

typedef NS_ENUM(NSInteger, GL_IMAGE_BLEND_MODE)
{
    GL_IMAGE_BLEND_MODE_NORMAL,
};

@interface GLImageStickerFilter : GPUImageTwoInputFilter
{
    CGSize firstInputSize, secondInputSize;
    GLint stickerSizeUniform, stickerCenterUniform, stickerThetaUniform, stickerAlphaUniform, stickerBlendModeUniform, aspectRatioUniform, mirrorModeUniform;
}

/** 贴纸大小 */
@property (nonatomic, assign) CGSize size;
/** 中心坐标 */
@property (nonatomic, assign) CGPoint center;
/** 旋转角 */
@property (nonatomic, assign) CGFloat theta;
/** 透明度 */
@property (nonatomic, assign) CGFloat alpha;
/** 混合模式 */
@property (nonatomic, assign) int blendMode;
/** 镜像模式 1 开启镜像 0 不开启镜像 */
@property (nonatomic, assign) int mirrorMode;

@end
