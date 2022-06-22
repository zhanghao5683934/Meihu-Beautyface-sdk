//
//  GLImageGlitchEffectLineFilter.h
//  WEOpenGLKit
//
//  Created by 刘海东 on 2018/9/5.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import <GPURenderKit/GPURenderKit.h>
//故障效果---线条故障
@interface GLImageGlitchEffectLineFilter : GPUImageFilter
{
    GLint intensityUniform;
    
}

@property (nonatomic, assign) float intensity;


@end
