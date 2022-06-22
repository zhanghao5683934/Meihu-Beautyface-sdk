//
//  GLImageFourPointsMirrorFilter.m
//  WEOpenGLKit
//
//  Created by 刘海东 on 2019/2/20.
//  Copyright © 2019 Leo. All rights reserved.
//

#import "GLImageFourPointsMirrorFilter.h"

NSString *const kGLImagePointsMirrorFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     
     highp vec2 uv = textureCoordinate;
     
     if (uv.x <= 0.5) {
         uv.x = uv.x * 2.0;
     } else {
         uv.x = (uv.x - 0.5) * 2.0;
     }
     
     if (uv.y <= 0.5) {
         uv.y = uv.y * 2.0;
     } else {
         uv.y = (uv.y - 0.5) * 2.0;
     }
     
     gl_FragColor = texture2D(inputImageTexture, uv);
 }
 );





@implementation GLImageFourPointsMirrorFilter


- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGLImagePointsMirrorFragmentShaderString];
    if (self) {
        
    }
    return self;
}


@end
