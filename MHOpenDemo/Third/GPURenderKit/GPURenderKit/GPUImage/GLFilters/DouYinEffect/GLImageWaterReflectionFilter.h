//
//  GLImageWaterReflectionFilter.h
//  GPURenderKit
//
//  Created by 刘海东 on 2019/4/17.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import <GPURenderKit/GPURenderKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLImageWaterReflectionFilter : GPUImageFilter
{
    GLint iResolutionUniform,timeUniform;
}

@end

NS_ASSUME_NONNULL_END
