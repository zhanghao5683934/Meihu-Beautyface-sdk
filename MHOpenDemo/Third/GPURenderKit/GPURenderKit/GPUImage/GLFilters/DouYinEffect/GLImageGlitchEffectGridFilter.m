//
//  GLImageGlitchEffectGridFilter.m
//  WEOpenGLKit
//
//  Created by 刘海东 on 2018/8/31.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageGlitchEffectGridFilter.h"

@implementation GLImageGlitchEffectGridFilter

NSString *const kGLImageGlitchEffectGridFilterFragmentShaderString = SHADER_STRING
(
 precision lowp float;
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture; // 原图的纹理
 uniform sampler2D inputImageTexture2; //

 uniform float colorFloat;
 uniform float intensity;
 uniform int blendMode;

 
 //返回小数部分
 float fracFunc (float x)
{
    return x - floor(x);
}
 
 //两者之间插值
 float lerpFunc(float a, float b, float w) {
     return a + w*(b-a);
 }
 
 highp float lum(lowp vec3 c) {
     return dot(c, vec3(0.3, 0.59, 0.11));
 }
 
 lowp vec3 clipcolor(lowp vec3 c) {
     highp float l = lum(c);
     lowp float n = min(min(c.r, c.g), c.b);
     lowp float x = max(max(c.r, c.g), c.b);
     if (n < 0.0) {
         c.r = l + ((c.r - l) * l) / (l - n);
         c.g = l + ((c.g - l) * l) / (l - n);
         c.b = l + ((c.b - l) * l) / (l - n);
     }
     if (x > 1.0) {
         c.r = l + ((c.r - l) * (1.0 - l)) / (x - l);
         c.g = l + ((c.g - l) * (1.0 - l)) / (x - l);
         c.b = l + ((c.b - l) * (1.0 - l)) / (x - l);
     }
     return c;
 }
 
 lowp vec3 setlum(lowp vec3 c, highp float l) {
     highp float d = l - lum(c);
     c = c + vec3(d);
     return clipcolor(c);
 }
 
 highp float sat(lowp vec3 c) {
     lowp float n = min(min(c.r, c.g), c.b);
     lowp float x = max(max(c.r, c.g), c.b);
     return x - n;
 }
 
 lowp vec3 setsat(lowp vec3 c, highp float s) {
     float minbase = min(min(c.r, c.g), c.b);
     float sbase = sat(c);
     vec3 color;
     if (sbase > 0.0) {
         color = (c - minbase) * s / sbase;
     } else {
         color = vec3(0.0);
     }
     return color;
 }

 // T = F(S, D);
 // S -> blend, D -> base, T -> result
 vec4 blend(vec4 S, vec4 D) {
     vec3 T;
     if(blendMode == 1)
     {
         //差值diff
         T = abs(D.rgb - S.rgb);
     }
     else
     {
         // color burn(颜色加深)
         T = 1.0 - min((1.0 - D.rgb) / S.rgb, 1.0);
     }
     vec4 resultColor = vec4(T, S.a);
     return resultColor;
 }
 
 void main()
 {
     
     vec2 uv = textureCoordinate;
     vec4 glitch = texture2D(inputImageTexture2,uv);
     
     float thresh = 1.001 - intensity * 1.001;
     float w_d = step(thresh, pow(glitch.z, 2.5)); // displacement glitch
     float w_f = step(thresh, pow(glitch.w, 2.5)); // frame glitch
     float w_c = step(thresh, pow(glitch.z, 3.5)); // color glitch

     // Displacement.
     float x = fracFunc(uv.x+glitch.x*w_d);
     float y = fracFunc(uv.y+glitch.y*w_d);
     vec2 uv1 = vec2(x,y);
     vec4 source = texture2D(inputImageTexture, uv1);
     
     // Mix with trash frame.
     float r1  = lerpFunc(source.r, texture2D(inputImageTexture, uv1).r, w_f);
     float g1  = lerpFunc(source.g, texture2D(inputImageTexture, uv1).g, w_f);
     float b1  = lerpFunc(source.b, texture2D(inputImageTexture, uv1).b, w_f);
     vec3 color = vec3(r1,g1,b1);
     
     
     // blend.
     lowp vec4 S = vec4(color,1.0);
     lowp vec4 D = glitch;
     vec3 S1 = S.a == 0.0 ? S.rgb : S.rgb / S.a;
     vec4 resultColor = blend(vec4(S1, S.a), D);
     float opacity = colorFloat * S.a;
     resultColor = vec4(resultColor.rgb * opacity + D.rgb * (1.0 - opacity), 1.0);
     vec4 neg = resultColor;
     
     //
     float r3 = lerpFunc(color.r, neg.r, w_c);
     float g3 = lerpFunc(color.g, neg.g, w_c);
     float b3 = lerpFunc(color.b, neg.b, w_c);
     vec3 color3 = vec3(r3, g3, b3);
     
     gl_FragColor = vec4(color3,1.0);
     
 }
 );


- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGLImageGlitchEffectGridFilterFragmentShaderString];
    intensityUniform = [filterProgram uniformIndex:@"intensity"];
    colorIntensityUniform = [filterProgram uniformIndex:@"colorFloat"];
    blendModeUniform = [filterProgram uniformIndex:@"blendMode"];
    
    [self disableSecondFrameCheck];
    self.intensity = 0.0;
    self.colorIntensity = 1.0;
    self.blendMode = 1;
    return self;
}

- (void)setIntensity:(float)intensity
{
    _intensity = intensity;
    [self setFloat:intensity forUniform:intensityUniform program:filterProgram];
    [plaidImageSource processImage];

}

- (void)setColorIntensity:(float)colorIntensity
{
    _colorIntensity = colorIntensity;
    [self setFloat:colorIntensity forUniform:colorIntensityUniform program:filterProgram];
    [plaidImageSource processImage];

}

- (void)setBlendMode:(int)blendMode
{
    _blendMode = blendMode;
    [self setInteger:blendMode forUniform:blendModeUniform program:filterProgram];
    [plaidImageSource processImage];
}

- (void)setPlaidImage:(UIImage *)plaidImage
{
    
    __weak __typeof(self)weakSelf = self;
    runSynchronouslyOnVideoProcessingQueue(^{
        [plaidImageSource removeTarget:weakSelf];
        plaidImageSource = nil;
        plaidImageSource = [[GPUImagePicture alloc] initWithImage:plaidImage];
        [plaidImageSource addTarget:weakSelf atTextureLocation:1];
        [plaidImageSource processImage];
    });
    

}


@end
