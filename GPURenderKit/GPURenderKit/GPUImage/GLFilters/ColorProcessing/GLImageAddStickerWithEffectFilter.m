//
//  GLImageAddStickerWithEffectFilter.m
//  WEOpenGLKit
//
//  Created by LHD on 2018/6/4.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageAddStickerWithEffectFilter.h"

@interface GLImageAddStickerWithEffectFilter ()

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

@property (nonatomic, strong) GPUImageHSBFilter *hsbFilter;

@property (nonatomic, strong) GLImageGassianBlurMixFilter *blurFilter;

- (void)updateEffectFilterChain;

@end

@implementation GLImageAddStickerWithEffectFilter
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
        stickerFiler.theta = 0;
        [self addFilter:stickerFiler];
        
        self.initialFilters = @[stickerFiler];
        self.terminalFilter = stickerFiler;
        
//        self.blurRadiusInPixels = 20.0;
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
    [self setBlurRadiusInPixels:stickerImage.size.width / 50.0];
    [self updateEffectFilterChain];
    [self stickerProcessImageIfNeeded];
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    __weak typeof(self) weakSelf = self;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [weakSelf stickerProcessImageIfNeeded];
    });
    
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

- (void)stickerProcessImageIfNeeded
{
    if (self.enableBlur || self.enableHue)
    {
        [stickerImageSource processImage];
    }
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

- (void)updateEffectFilterChain
{
    __weak typeof(self) weakSelf = self;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        NSMutableArray *effectFilters = [[NSMutableArray alloc] init];
        
        if (_enableHue)
        {
            [effectFilters addObject:weakSelf.hsbFilter];
        }
        
        if (_enableBlur)
        {
            [effectFilters addObject:weakSelf.blurFilter];
        }
        
        id preFilter = stickerImageSource;
        GPUImageOutput<GPUImageInput> *theFilter = nil;
        
        for (int i = 0; i < effectFilters.count; i++)
        {
            theFilter = [effectFilters objectAtIndex:i];
            [preFilter removeAllTargets];
            [preFilter addTarget:theFilter];
            preFilter = theFilter;
        }
        
        [preFilter removeAllTargets];
        [preFilter addTarget:stickerFiler atTextureLocation:1];
    });
}

#pragma mark - GLImageAddStickerWithEffectFilter (Effect)

- (void)setEnableBlur:(BOOL)enableBlur
{
    _enableBlur = enableBlur;
    [self updateEffectFilterChain];
}

- (void)setEnableHue:(BOOL)enableHue
{
    _enableHue = enableHue;
    [self updateEffectFilterChain];
}

- (void)setHue:(CGFloat)hue
{
    [self.hsbFilter reset];
    [self.hsbFilter rotateHue:hue];
}

- (GPUImageHSBFilter *)hsbFilter
{
    if (!_hsbFilter)
    {
        _hsbFilter = [[GPUImageHSBFilter alloc] init];
    }
    
    return _hsbFilter;
}

- (void)setBlurRadiusInPixels:(CGFloat)blurRadiusInPixels
{
    _blurRadiusInPixels = blurRadiusInPixels;
    [self.blurFilter setBlurRadiusInPixels:blurRadiusInPixels];
}

- (void)setBlur:(CGFloat)blur
{
    _blur = blur;
    [self.blurFilter setIntensity:blur];
}

- (GLImageGassianBlurMixFilter *)blurFilter
{
    if (!_blurFilter)
    {
        _blurFilter = [[GLImageGassianBlurMixFilter alloc] init];
    }
    
    return _blurFilter;
}

@end
