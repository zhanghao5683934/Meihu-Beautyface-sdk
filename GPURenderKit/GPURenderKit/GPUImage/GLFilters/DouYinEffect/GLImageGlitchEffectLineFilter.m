//
//  GLImageGlitchEffectLineFilter.m
//  WEOpenGLKit
//
//  Created by 刘海东 on 2018/9/5.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageGlitchEffectLineFilter.h"

@implementation GLImageGlitchEffectLineFilter


NSString *const kGLImageGlitchEffectLineFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 uniform sampler2D inputImageTexture;
 varying lowp vec2 textureCoordinate;
 uniform float intensity;
 //返回小数部分
 float fracFunc (float x)
{
    return x - floor(x);
}
 //
 float nrand(float x, float y)
{
    return fracFunc(sin(dot(vec2(x, y), vec2(12.9898, 78.233))) * 43758.5453);
}
 //两者之间插值
 float lerpFunc(float a, float b, float w)
{
    return a + w*(b-a);
}
 
 void main()
 {
     
     vec2 uv = textureCoordinate;
     //scanLineJitter
     //intensity 【0.0 - 1.0】
     float scanLineJitter = intensity *1.3;
     float sl_thresh = clamp(1.0-scanLineJitter*1.2,0.0,1.0);
     float sl_disp = 0.002 + pow(scanLineJitter, 3.0) * 0.05;
     vec2 slj_uv = vec2(sl_disp,sl_thresh);
     
     //colorDrift 颜色偏移
     //取值【0.0 - 1.0】
     float amount = 0.032;
     if(intensity<=0.001)
     {
         amount = 0.0;
     }
     float time = 1.0 *606.11;
     vec2 colorDrift = vec2(amount,time);
     
     // Scan line jitter 抖动效果
     float jitter = nrand(uv.y, scanLineJitter) * 2.0 - 1.0;
     jitter *= step(slj_uv.y, abs(jitter)) * slj_uv.x;
     
     // Color drift
     float drift = sin(colorDrift.y) * colorDrift.x;
     
     vec2 src1uv = vec2(fracFunc(uv.x + jitter ),uv.y);
     vec4 src1 = texture2D(inputImageTexture, src1uv);
     
     vec2 src2uv = vec2(fracFunc(uv.x + jitter +drift),uv.y);
     vec4 src2 = texture2D(inputImageTexture, src2uv);
     
     gl_FragColor = vec4(src1.r, src2.g, src1.b, 1.0);
 }
 );

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGLImageGlitchEffectLineFilterFragmentShaderString];
    if (self) {
        
        intensityUniform = [filterProgram uniformIndex:@"intensity"];
        self.intensity = 0.0;
    }
    return self;
}

- (void)setIntensity:(float)intensity
{
    _intensity = intensity;
    [self setFloat:intensity forUniform:intensityUniform program:filterProgram];
}

@end
