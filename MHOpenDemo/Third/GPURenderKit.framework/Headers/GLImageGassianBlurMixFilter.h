//
//  GLImageGassianBlurMixFilter.h
//  WEOpenGLKit
//
//  Created by LHD on 2018/8/2.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GLImageMixBlendFilter.h"

@interface GLImageGassianBlurMixFilter : GPUImageFilterGroup
{
    GPUImageGaussianBlurFilter *blurFilter;
    GLImageMixBlendFilter *mixFilter;
}

@property (nonatomic, assign) CGFloat intensity;
@property (nonatomic, assign) CGFloat blurRadiusInPixels;

@end
