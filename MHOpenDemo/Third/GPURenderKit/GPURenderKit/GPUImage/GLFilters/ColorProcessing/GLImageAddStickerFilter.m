//
//  GLImageAddStickerFilter.m
//  WEOpenGLKit
//
//  Created by LHD on 2018/6/4.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageAddStickerFilter.h"
#import "GLImageMixBlendFilter.h"

@implementation GLImageAddStickerFilter
{
    UIImage *_stickerImage;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        stickerFiler = [[GLImageStickerFilter alloc] init];
        [stickerFiler disableSecondFrameCheck];
        stickerFiler.theta = 45 * M_PI / 180.0;
        [self addFilter:stickerFiler];
        
        self.initialFilters = @[stickerFiler];
        self.terminalFilter = stickerFiler;
    }
    
    return self;
}

- (void)setStickerImage:(UIImage *)stickerImage
{
    _stickerImage = stickerImage;
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:stickerImage];
    [picture addTarget:stickerFiler atTextureLocation:1];
    [picture processImage];
    
    if (stickerImageSource)
    {
        [stickerImageSource removeTarget:stickerFiler];
        stickerImageSource = nil;
    }
    
    stickerImageSource = picture;
}

- (void)setSize:(CGSize)size
{
    _size = size;
    [stickerFiler setSize:size];
}

- (void)setCenter:(CGPoint)center
{
    _center = center;
    [stickerFiler setCenter:center];
}

- (void)setTheta:(CGFloat)theta
{
    _theta = theta;
    [stickerFiler setTheta:theta];
}

- (void)setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    [stickerFiler setAlpha:alpha];
}

- (void)setBlendMode:(int)blendMode
{
    _blendMode = blendMode;
    [stickerFiler setBlendMode:blendMode];
}

- (void)setMirrorMode:(int)mirrorMode
{
    _mirrorMode = mirrorMode;
    [stickerFiler setMirrorMode:mirrorMode];
}

@end
