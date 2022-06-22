//
//  GLImageCircleFilter.h
//  GPURenderKitDemo
//
//  Created by 刘海东 on 2019/3/18.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import <GPURenderKit/GPURenderKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLImageCircleFilter : GPUImageFilter
{
    GLint iResolutionUniform;
}

@end

NS_ASSUME_NONNULL_END
