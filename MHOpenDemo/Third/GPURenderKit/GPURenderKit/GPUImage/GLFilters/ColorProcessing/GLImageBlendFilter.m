//
//  GLImageBlendFilter.m
//  GLImage
//
//  Created by LHD on 2018/5/16.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageBlendFilter.h"

@implementation GLImageBlendFilter

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString
{
    self = [super initWithFragmentShaderFromString:fragmentShaderString];
    
    if (self)
    {
        intensityUniform = [filterProgram uniformIndex:@"intensity"];
        self.intensity = 0.0;
    }
    
    return self;
}

- (void)setIntensity:(CGFloat)intensity
{
    _intensity = intensity;
    [self setFloat:intensity forUniform:intensityUniform program:filterProgram];
}

@end
