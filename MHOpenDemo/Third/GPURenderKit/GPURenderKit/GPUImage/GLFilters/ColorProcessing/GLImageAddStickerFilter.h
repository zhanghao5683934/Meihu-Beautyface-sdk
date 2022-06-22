//
//  GLImageAddStickerFilter.h
//  WEOpenGLKit
//
//  Created by LHD on 2018/6/4.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "GLImageStickerFilter.h"
#import "GPUImagePicture.h"

@interface GLImageAddStickerFilter : GPUImageFilterGroup
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
/** 镜像模式 1 开启镜像 0 不开启镜像 */
@property (nonatomic, assign) int mirrorMode;


/** 设置贴纸图片 */
- (void)setStickerImage:(UIImage *)stickerImage;

@end
