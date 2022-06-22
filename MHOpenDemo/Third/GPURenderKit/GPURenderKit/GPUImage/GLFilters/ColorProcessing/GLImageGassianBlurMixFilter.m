//
//  GLImageGassianBlurMixFilter.m
//  WEOpenGLKit
//
//  Created by LHD on 2018/8/2.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageGassianBlurMixFilter.h"

@implementation GLImageGassianBlurMixFilter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        mixFilter = [[GLImageMixBlendFilter alloc] init];
        [blurFilter addTarget:mixFilter atTextureLocation:1];
        
        self.blurRadiusInPixels = 4.0;
        self.initialFilters = @[blurFilter, mixFilter];
        self.terminalFilter = mixFilter;
        
    }
    return self;
}

- (void)setBlurRadiusInPixels:(CGFloat)blurRadiusInPixels
{
    _blurRadiusInPixels = blurRadiusInPixels;
    [blurFilter setBlurRadiusInPixels:blurRadiusInPixels];
}

- (void)setIntensity:(CGFloat)intensity
{
    _intensity = intensity;
    [mixFilter setIntensity:intensity];
}

@end
