//
//  GLImageThreePartitionFilter.m
//  WEOpenGLKit
//
//  Created by 刘海东 on 2019/2/19.
//  Copyright © 2019 Leo. All rights reserved.
//

#import "GLImageThreePartitionFilter.h"

NSString *const kGLImageThreePartitionFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform float intensity;
 uniform int directionType;
 
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform sampler2D inputImageTexture4;
 
 
 
 vec4 mixLutColor (vec4 textureColor, sampler2D lutTexture) {
     
     highp float blueColor = textureColor.b * 63.0;
     
     highp vec2 quad1;
     quad1.y = floor(floor(blueColor) / 8.0);
     quad1.x = floor(blueColor) - (quad1.y * 8.0);
     
     highp vec2 quad2;
     quad2.y = floor(ceil(blueColor) / 8.0);
     quad2.x = ceil(blueColor) - (quad2.y * 8.0);
     
     highp vec2 texPos1;
     texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
     texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
     
     highp vec2 texPos2;
     texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
     texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
     
     lowp vec4 newColor1 = texture2D(lutTexture, texPos1);
     lowp vec4 newColor2 = texture2D(lutTexture, texPos2);
     
     lowp vec4 newColor = mix(newColor1, newColor2, fract(blueColor));
     
     return vec4(newColor.rgb,intensity);
     
 }
 
 
 void main()
 {
     
     highp vec2 uv = textureCoordinate;
     
     vec4 color;
     
     if (directionType == 0) {
         if (uv.x >= 0.0 && uv.x <= 0.33) { // 上
             
             vec2 coordinate = vec2(uv.x+0.33, uv.y);
             color = texture2D(inputImageTexture, coordinate);
             color = mixLutColor(color,inputImageTexture2);
             
         } else if (uv.x > 0.33 && uv.x <= 0.67) {   // 中
             
             color = texture2D(inputImageTexture, uv);
             color = mixLutColor(color,inputImageTexture3);
             
         } else {    // 下
             
             vec2 coordinate = vec2(uv.x-0.33, uv.y);
             color = texture2D(inputImageTexture, coordinate);
             color = mixLutColor(color,inputImageTexture4);
         }
         
     } else {
         
         if (uv.y >= 0.0 && uv.y <= 0.33) { // 上
             
             vec2 coordinate = vec2(uv.x, uv.y + 0.33);
             color = texture2D(inputImageTexture, coordinate);
             color = mixLutColor(color,inputImageTexture2);
             
         } else if (uv.y > 0.33 && uv.y <= 0.67) {   // 中
             
             color = texture2D(inputImageTexture, uv);
             color = mixLutColor(color,inputImageTexture3);
             
         } else {    // 下
             
             vec2 coordinate = vec2(uv.x, uv.y - 0.33);
             color = texture2D(inputImageTexture, coordinate);
             color = mixLutColor(color,inputImageTexture4);
             
         }
     }
     
     gl_FragColor = color;
 }
 );


@implementation GLImageThreePartitionFilter

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGLImageThreePartitionFragmentShaderString];
    if (self) {
        
        directionTypeUniform = [filterProgram uniformIndex:@"directionType"];
        intensityUniform = [filterProgram uniformIndex:@"intensity"];
        
        self.intensity = 0.5;
        [self setDirectionType:1];
        
        
    }
    return self;
}

- (void)setDirectionType:(int)directionType{
    _directionType = directionType;
    [self setInteger:directionType forUniform:directionTypeUniform program:filterProgram];

}

- (void)setIntensity:(float)intensity
{
    _intensity = intensity;
    [self setFloat:intensity forUniform:intensityUniform program:filterProgram];
}




@end
