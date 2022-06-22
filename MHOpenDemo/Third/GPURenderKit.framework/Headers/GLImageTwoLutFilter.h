//
//  GLImageTwoLutFilter.h
//  WEOpenGLKit
//
//  Created by LHD on 2018/6/30.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "GLImageLutFilter.h"

@interface GLImageTwoLutFilter : GPUImageFilterGroup
{
    GLImageLutFilter *positiveLutFilter, *negativeLutFilter;
}

@property (nonatomic, assign) CGFloat intensity;

/** 正向 Lut Image */
- (void)setPositiveLutImage:(UIImage *)lutImage;
/** 负向 Lut Image */
- (void)setNegativeLutImage:(UIImage *)lutImage;

@end
