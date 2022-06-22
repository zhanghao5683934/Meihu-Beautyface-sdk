//
//  GLImageStickerFilter.m
//  WEOpenGLKit
//
//  Created by LHD on 2018/6/4.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageStickerFilter.h"

NSString *const kGLImageStickerFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; // sticker texture;
 
 uniform vec2  size;
 uniform vec2  center;
 uniform float theta;
 uniform float alpha;
 uniform int blendMode;
 uniform int mirrorMode;
 uniform float aspectRatio;
 uniform float s;
 uniform float c;
 
 
 highp float lum(lowp vec3 c)
 {
     return dot(c, vec3(0.3, 0.59, 0.11));
 }
 
 lowp vec3 clipcolor(lowp vec3 c)
 {
     highp float l = lum(c);
     lowp float n = min(min(c.r, c.g), c.b);
     lowp float x = max(max(c.r, c.g), c.b);
     
     if (n < 0.0)
     {
         c.r = l + ((c.r - l) * l) / (l - n);
         c.g = l + ((c.g - l) * l) / (l - n);
         c.b = l + ((c.b - l) * l) / (l - n);
     }
     
     if (x > 1.0)
     {
         c.r = l + ((c.r - l) * (1.0 - l)) / (x - l);
         c.g = l + ((c.g - l) * (1.0 - l)) / (x - l);
         c.b = l + ((c.b - l) * (1.0 - l)) / (x - l);
     }
     
     return c;
 }
 
 lowp vec3 setlum(lowp vec3 c, highp float l)
 {
     highp float d = l - lum(c);
     c = c + vec3(d);
     
     return clipcolor(c);
 }
 
 highp float sat(lowp vec3 c)
 {
     lowp float n = min(min(c.r, c.g), c.b);
     lowp float x = max(max(c.r, c.g), c.b);
     
     return x - n;
 }
 
 lowp vec3 setsat(lowp vec3 c, highp float s)
 {
     float minbase = min(min(c.r, c.g), c.b);
     float sbase = sat(c);
     vec3 color;
     
     if (sbase > 0.0)
     {
         color = (c - minbase) * s / sbase;
     }
     else
     {
         color = vec3(0.0);
     }
     
     return color;
 }
 
 // T = F(S, D); // S -> blend, D -> base, T -> result
 vec4 blend(vec4 S, vec4 D)
 {
     vec3 T;
     
     if (blendMode < 1 || blendMode > 27)
     {
         // 其它情况显示base
         T = D.rgb;
     }
     else if (blendMode == 1)
     {
         // normal(正常)
         T = S.rgb;
         
     }
     else if (blendMode == 2)
     {
         // dissolve(溶解)
         // 未实现
         T = D.rgb;
     }
     else if (blendMode == 3)
     {
         // darken(变暗)
         T = min(D.rgb, S.rgb);
     }
     else if (blendMode == 4)
     {
         // multiply(正片叠底)
         T = D.rgb * S.rgb;
     }
     else if (blendMode == 5)
     {
         // color burn(颜色加深)
         T = 1.0 - min((1.0 - D.rgb) / S.rgb, 1.0);
     }
     else if (blendMode == 6)
     {
         // linear burn(线性加深)
         vec3 white = vec3(1.0, 1.0, 1.0);
         T = S.rgb + D.rgb - white;
     }
     else if (blendMode == 7)
     {
         // darker color(深色)
         T = dot(D.rgb, vec3(0.299, 0.587, 0.114)) < dot(S.rgb, vec3(0.299, 0.587, 0.114)) ? D.rgb : S.rgb;
     }
     else if (blendMode == 8)
     {
         // lighten(变亮)
         T = max(D.rgb, S.rgb);
     }
     else if (blendMode == 9)
     {
         // screen(滤色)
         vec3 white = vec3(1.0, 1.0, 1.0);
         T = white - (white - D.rgb) * (white - S.rgb);
     }
     else if (blendMode == 10)
     {
         // color dodge(颜色减淡)
         T = min(D.rgb / (1.0 - S.rgb), 1.0);
     }
     else if (blendMode == 11)
     {
         // linear dodge (线性减淡)
         vec3 white = vec3(1.0, 1.0, 1.0);
         T = D.rgb + S.rgb;
         T = min(white, T);
     }
     else if (blendMode == 12)
     {
         // lighter color(浅色)
         T = dot(D.rgb, vec3(0.299, 0.587, 0.114)) > dot(S.rgb, vec3(0.299, 0.587, 0.114)) ? D.rgb : S.rgb;
     }
     else if (blendMode == 13)
     {
         // overlay(叠加)
         T = 2.0 * D.rgb * S.rgb;
         
         if (D.r >= 0.5)
         {
             T.r = 1.0 - 2.0 * (1.0 - D.r) * (1.0 - S.r);
         }
         
         if (D.g >= 0.5)
         {
             T.g = 1.0 - 2.0 * (1.0 - D.g) * (1.0 - S.g);
         }
         
         if (D.b >= 0.5)
         {
             T.b = 1.0 - 2.0 * (1.0 - D.b) * (1.0 - S.b);
         }
     }
     else if (blendMode == 14)
     {
         // soft light(柔光)
         vec3 white = vec3(1.0, 1.0, 1.0);
         T = 2.0 * D.rgb * S.rgb + D.rgb * D.rgb * (white - 2.0 * S.rgb);
         
         if (S.r >= 0.5)
         {
             T.r = 2.0 * D.r * (1.0 - S.r) + (2.0 * S.r - 1.0) * sqrt(D.r);
         }
         
         if (S.g >= 0.5)
         {
             T.g = 2.0 * D.g * (1.0 - S.g) + (2.0 * S.g - 1.0) * sqrt(D.g);
         }
         
         if (S.b >= 0.5)
         {
             T.b = 2.0 * D.b * (1.0 - S.b) + (2.0 * S.b - 1.0) * sqrt(D.b);
         }
     }
     else if (blendMode == 15)
     {
         // hard light(强光)
         T = 2.0 * D.rgb * S.rgb;
         
         if (S.r >= 0.5)
         {
             T.r = 1.0 - 2.0 * (1.0 - D.r) * (1.0 - S.r);
         }
         
         if (S.g >= 0.5)
         {
             T.g = 1.0 - 2.0 * (1.0 - D.g) * (1.0 - S.g);
         }
         
         if (S.b >= 0.5)
         {
             T.b = 1.0 - 2.0 * (1.0 - D.b) * (1.0 - S.b);
         }
         
     }
     else if (blendMode == 16)
     {
         // vivid light(亮光)
         T.r = S.r < 0.5 ? 1.0 - (1.0 - D.r) / (S.r * 2.0) : D.r / (1.0 - S.r) * 0.5;
         T.g = S.g < 0.5 ? 1.0 - (1.0 - D.g) / (S.g * 2.0) : D.g / (1.0 - S.g) * 0.5;
         T.b = S.b < 0.5 ? 1.0 - (1.0 - D.b) / (S.b * 2.0) : D.b / (1.0 - S.b) * 0.5;
         T = clamp(T, 0.0, 1.0);
     }
     else if (blendMode == 17)
     {
         // linear light(线性光)
         vec3 white = vec3(1.0, 1.0, 1.0);
         T = 2.0 * S.rgb + D.rgb - white;
     }
     else if (blendMode == 18)
     {
         // pin light(点光)
         T.r = S.r < 0.5 ? min(D.r, 2.0 * S.r) : max(D.r, 2.0 * S.r - 1.0);
         T.g = S.g < 0.5 ? min(D.g, 2.0 * S.g) : max(D.g, 2.0 * S.g - 1.0);
         T.b = S.b < 0.5 ? min(D.b, 2.0 * S.b) : max(D.b, 2.0 * S.b - 1.0);
     }
     else if (blendMode == 19)
     {
         // hard mix(实色混合)
         T = floor(S.rgb + D.rgb);
     }
     else if (blendMode == 20)
     {
         // diff(差值)
         T = abs(D.rgb - S.rgb);
     }
     else if (blendMode == 21)
     {
         // exclusion(排除)
         T = S.rgb + D.rgb - 2.0 * S.rgb * D.rgb;
     }
     else if (blendMode == 22)
     {
         // substract(减去)
         vec3 black = vec3(0.0, 0.0, 0.0);
         T = D.rgb - S.rgb;
         T = max(black, T);
     }
     else if (blendMode == 23)
     {
         // divide(划分)
         vec3 white = vec3(1.0, 1.0, 1.0);
         T = white;
         
         if (S.r > 0.0)
         {
             T.r = D.r / S.r;
         }
         
         if (S.g > 0.0)
         {
             T.g = D.g / S.g;
         }
         
         if (S.b > 0.0)
         {
             T.b = D.b / S.b;
         }
         
         T = min(white, T);
     }
     else if (blendMode == 24)
     {
         // hue(色相)
         T = setlum(setsat(S.rgb, sat(D.rgb)), lum(D.rgb));
     }
     else if (blendMode == 25)
     {
         // saturation(饱和度)
         T = setlum(setsat(D.rgb, sat(S.rgb)), lum(D.rgb));
     }
     else if (blendMode == 26)
     {
         // color(颜色)
         T = S.rgb + dot(D.rgb, vec3(0.299, 0.587, 0.114)) - dot(S.rgb, vec3(0.299, 0.587, 0.114));
     }
     else if (blendMode == 27)
     {
         // luminosity(明度)
         T = setlum(D.rgb, lum(S.rgb));
     }
     
     vec4 resultColor = vec4(T, S.a);
     return resultColor;
 }
 
 void main()
 {
     lowp vec4 color = texture2D(inputImageTexture, textureCoordinate);
     
     vec2 coordinateToUse = vec2(textureCoordinate.x * aspectRatio, textureCoordinate.y);
     vec2 centerToUse = vec2(center.x * aspectRatio, center.y);
     vec2 sizeToUse = vec2(size.x * aspectRatio, size.y);
     mat2 rotateMatrix = mat2(c, s, -s, c);
     
     coordinateToUse = (coordinateToUse - centerToUse) * rotateMatrix;
     coordinateToUse = vec2(coordinateToUse.x / sizeToUse.x, coordinateToUse.y / sizeToUse.y) + vec2(0.5);
     
     if (all(greaterThanEqual(coordinateToUse, vec2(0.0))) &&
         all(lessThanEqual(coordinateToUse, vec2(1.0))))
     {
         if (mirrorMode == 1)
         {
             //镜像
             coordinateToUse = vec2(1.0 - coordinateToUse.x, coordinateToUse.y);
         }
         
         lowp vec4 S = texture2D(inputImageTexture2, coordinateToUse);
         lowp vec4 D = color;
         
         vec3 S1 = S.a == 0.0 ? S.rgb : S.rgb / S.a;
         vec4 resultColor = blend(vec4(S1, S.a), D);
         float opacity = alpha * S.a;
         
         resultColor = vec4(resultColor.rgb * opacity + D.rgb * (1.0 - opacity), 1.0);
         
         gl_FragColor = resultColor;
     }
     else
     {
         gl_FragColor = color;
     }
 }
);


@interface GLImageStickerFilter ()
{
    GLint sUniform, cUniform;
}

/** 父视图的宽高比 */
@property (nonatomic, assign) float aspectRatio;

@end

@implementation GLImageStickerFilter

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGLImageStickerFragmentShaderString];
    
    if (self)
    {
        aspectRatioUniform = [filterProgram uniformIndex:@"aspectRatio"];
        stickerSizeUniform = [filterProgram uniformIndex:@"size"];
        stickerCenterUniform = [filterProgram uniformIndex:@"center"];
        stickerThetaUniform = [filterProgram uniformIndex:@"theta"];
        stickerAlphaUniform = [filterProgram uniformIndex:@"alpha"];
        stickerBlendModeUniform = [filterProgram uniformIndex:@"blendMode"];
        mirrorModeUniform = [filterProgram uniformIndex:@"mirrorMode"];
        sUniform = [filterProgram uniformIndex:@"s"];
        cUniform = [filterProgram uniformIndex:@"c"];
        self.size = CGSizeZero;
        self.center = CGPointMake(0.5, 0.5);
        self.theta = 0.0;
        self.aspectRatio = 1.0;
        self.alpha = 1.0;
        self.blendMode = 1;
        self.mirrorMode = 0;
    }
    
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex
{
    [super setInputSize:newSize atIndex:textureIndex];
    
    if (textureIndex == 0)
    {
        self.aspectRatio = newSize.width / newSize.height;
        firstInputSize = newSize;
    }
    else if (textureIndex == 1)
    {
        secondInputSize = newSize;
    }
    
    [self updateSize];
}

- (void)updateSize
{
    if ( CGSizeEqualToSize(_size, CGSizeZero) &&
        !CGSizeEqualToSize(firstInputSize, CGSizeZero) &&
        !CGSizeEqualToSize(secondInputSize, CGSizeZero))
    {
        [self setSize:CGSizeMake(secondInputSize.width / firstInputSize.width, secondInputSize.height / firstInputSize.height) forUniform:stickerSizeUniform program:filterProgram];
    }
}

- (void)setSize:(CGSize)size
{
    _size = size;
    [self setSize:self.size forUniform:stickerSizeUniform program:filterProgram];
}

- (void)setCenter:(CGPoint)center
{
    _center = center;
    [self setPoint:self.center forUniform:stickerCenterUniform program:filterProgram];
}

- (void)setTheta:(CGFloat)theta
{
    _theta = theta;
    [self setFloat:theta forUniform:stickerThetaUniform program:filterProgram];
    [self setFloat:sinf(theta) forUniform:sUniform program:filterProgram];
    [self setFloat:cosf(theta) forUniform:cUniform program:filterProgram];
}

- (void)setAspectRatio:(float)aspectRatio
{
    _aspectRatio = aspectRatio;
    [self setFloat:aspectRatio forUniform:aspectRatioUniform program:filterProgram];
}

- (void)setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    [self setFloat:alpha forUniform:stickerAlphaUniform program:filterProgram];
}

- (void)setBlendMode:(int)blendMode
{
    _blendMode = blendMode;
    [self setInteger:blendMode forUniform:stickerBlendModeUniform program:filterProgram];
}

- (void)setMirrorMode:(int)mirrorMode
{
    _mirrorMode = mirrorMode;
    [self setInteger:mirrorMode forUniform:mirrorModeUniform program:filterProgram];
}

@end
