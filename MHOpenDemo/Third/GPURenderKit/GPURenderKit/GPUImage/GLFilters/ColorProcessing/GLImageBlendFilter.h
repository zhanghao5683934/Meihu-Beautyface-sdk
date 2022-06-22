//
//  GLImageBlendFilter.h
//  GLImage
//
//  Created by LHD on 2018/5/16.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface GLImageBlendFilter : GPUImageTwoInputFilter
{
    GLint intensityUniform;
}

@property (nonatomic, assign) CGFloat intensity;

@end
