//
//  GLImageMixBlendFilter.m
//  GLImage
//
//  Created by LHD on 2018/5/18.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageMixBlendFilter.h"

NSString *const kGLImageMixBlendFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture; // 这个是原图 groupFilter location为0的才能传入原图
 uniform sampler2D inputImageTexture2;
 uniform float intensity;
 
 void main()
 {
     lowp vec4 originalColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 blendColor = texture2D(inputImageTexture2, textureCoordinate2);
     gl_FragColor = mix(originalColor, blendColor, intensity);
 }
);

@implementation GLImageMixBlendFilter

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGLImageMixBlendFragmentShaderString];
    if (self) {
    }
    return self;
}

@end
