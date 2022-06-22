//
//  GLImageLutFilter.h
//  WeGPUImage
//
//  Created by LHD on 2018/3/1.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@interface GLImageLutFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
    GPUImageLookupFilter *lookupFilter;
}

@property (nonatomic, assign) CGFloat intensity;

- (void)setLutImage:(UIImage *)lutImage;

@end
