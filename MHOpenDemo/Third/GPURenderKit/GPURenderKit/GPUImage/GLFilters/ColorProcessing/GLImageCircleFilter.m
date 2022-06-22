//
//  GLImageCircleFilter.m
//  GPURenderKitDemo
//
//  Created by 刘海东 on 2019/3/18.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import "GLImageCircleFilter.h"
#include <math.h>
NSString *const kGLImageCircleFragmentShaderString = SHADER_STRING
(
 precision mediump float;

 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform highp vec2 iResolution;
 
 
 float roundRect(in vec2 distFromCenter, in vec2 halfSize, in float cornerRadius)
{
    float t = length(max(abs(distFromCenter) - (halfSize - cornerRadius), 0.)) - cornerRadius;
    return smoothstep(-1., 1.,t);
    
}
 
 void main()
 {
     
     highp vec2 uv = textureCoordinate;
     
     
     
     vec4 color = texture2D(inputImageTexture, uv);
     
          
     highp vec2 fragCoord = uv * iResolution;
     vec2 xy = fragCoord.xy - iResolution.xy *0.5;
     vec2 hsize = iResolution.xy / 2.0;
     float p = roundRect(xy, hsize, 100.0);
     p = 1.0-p;
     gl_FragColor = vec4(color.r*p,color.g*p,color.b*p,p);
 }
 );

@implementation GLImageCircleFilter


- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kGLImageCircleFragmentShaderString]))
    {
        return nil;
    }
    
    iResolutionUniform = [filterProgram uniformIndex:@"iResolution"];
    
    return self;
}

- (void)setupFilterForSize:(CGSize)filterFrameSize
{

    NSLog(@"setupFilterForSize---%@",NSStringFromCGSize(filterFrameSize));
    [self setSize:filterFrameSize forUniform:iResolutionUniform program:filterProgram];

}




@end
