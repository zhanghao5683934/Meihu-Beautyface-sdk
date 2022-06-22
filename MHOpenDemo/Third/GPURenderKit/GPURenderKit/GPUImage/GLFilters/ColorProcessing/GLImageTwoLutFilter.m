//
//  GLImageTwoLutFilter.m
//  WEOpenGLKit
//
//  Created by LHD on 2018/6/30.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageTwoLutFilter.h"

@implementation GLImageTwoLutFilter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        positiveLutFilter = [[GLImageLutFilter alloc] init];
        negativeLutFilter = [[GLImageLutFilter alloc] init];
        [positiveLutFilter addTarget:negativeLutFilter];
        self.initialFilters = @[positiveLutFilter];
        self.terminalFilter = negativeLutFilter;
        self.intensity = 0.0;
    }
    return self;
}

- (void)setPositiveLutImage:(UIImage *)lutImage
{
    [positiveLutFilter setLutImage:lutImage];
}

- (void)setNegativeLutImage:(UIImage *)lutImage
{
    [negativeLutFilter setLutImage:lutImage];
}

- (void)setIntensity:(CGFloat)intensity
{
    _intensity = intensity;
    
    if (intensity >= 0.0)
    {
        positiveLutFilter.intensity = intensity;
        negativeLutFilter.intensity = 0.0;
    }
    else
    {
        positiveLutFilter.intensity = 0.0;
        negativeLutFilter.intensity = -intensity;
    }
}

@end
