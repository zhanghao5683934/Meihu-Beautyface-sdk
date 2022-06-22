//
//  GLImageLutFilter.m
//  WeGPUImage
//
//  Created by LHD on 2018/3/1.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageLutFilter.h"

@implementation GLImageLutFilter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        lookupFilter = [[GPUImageLookupFilter alloc] init];
        [lookupFilter disableSecondFrameCheck];
        [self addFilter:lookupFilter];
        
        self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
        self.terminalFilter = lookupFilter;
        
        self.intensity = 1.0;
    }
    
    return self;
}

- (void)setLutImage:(UIImage *)lutImage
{
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:lutImage];
    [picture addTarget:lookupFilter atTextureLocation:1];
    [picture processImage];
    
    if (lookupImageSource)
    {
        [lookupImageSource removeTarget:lookupFilter];
        lookupImageSource = nil;
    }
    
    lookupImageSource = picture;
}

- (void)setIntensity:(CGFloat)intensity
{
    _intensity = intensity;
    [lookupFilter setIntensity:intensity];
}

@end
