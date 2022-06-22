//
//  GLImageWaterReflectionFilter.m
//  GPURenderKit
//
//  Created by 刘海东 on 2019/4/17.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import "GLImageWaterReflectionFilter.h"

NSString *const kGLImageWaterReflectionFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform float time;
 
 uniform vec2 resolution;
 
 
#define F cos(x-y)*cos(y),sin(x+y)*sin(y)
 //波纹
 vec2 ripple(vec2 point)
{
    //d 水波纹的剧烈程度
    float d= abs(sin(time))*0.98;
    float x=10.*(point.x+d);
    float y=3.*(point.y+d);
    return vec2(F);
}
 
 void main()
 {
     
     highp vec2 uv = textureCoordinate;
     float aspectRatio = resolution.x/resolution.y;

     float iResolutionX = resolution.x;

     if (uv.y>0.5){
         
         uv = uv+2./iResolutionX*(ripple(uv)-ripple(uv+resolution.xy));
         
         uv.y = 1.0 - uv.y;
         
     }
     
     gl_FragColor = texture2D(inputImageTexture, uv);

 }
 );


@interface GLImageWaterReflectionFilter ()

@property (nonatomic, assign) float time;

@end

@implementation GLImageWaterReflectionFilter

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGLImageWaterReflectionFragmentShaderString];
    if (self) {
        
        iResolutionUniform = [filterProgram uniformIndex:@"resolution"];
        timeUniform = [filterProgram uniformIndex:@"time"];
        
        
    }
    return self;
}


- (void)setupFilterForSize:(CGSize)filterFrameSize
{
    [self setSize:filterFrameSize forUniform:iResolutionUniform program:filterProgram];
    
    self.time  = self.time + 0.05;
    [self setFloat:self.time forUniform:timeUniform program:filterProgram];
}


@end
