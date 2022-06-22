//
//  GLImageSoulOutFilter.m
//  GPURenderKitDemo
//
//  Created by 刘海东 on 2019/4/16.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import "GLImageSoulOutFilter.h"
#define kMaxResetCount 20
#define kMinResetCount 12


NSString *const kGLImageSoulOutFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform float scale;//缩放比
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     
     highp vec2 uv = textureCoordinate;
     
     vec4 originColor = texture2D(inputImageTexture, uv);
     //uv坐标的中心点并非是（0.0，0.0），所以这里进行一次偏移，后面在偏移回来就可以了
     vec2 center = vec2(0.5, 0.5);
     uv -= center;
     uv = uv / scale;
     uv += center;
     vec4 overlayColor = texture2D(inputImageTexture, uv);
     
     //线性混合
     vec4 color = mix(originColor,overlayColor,fract(scale)*0.2);
     gl_FragColor = color;
     
 }
 );

@interface GLImageSoulOutFilter ()

@property (nonatomic, assign) NSInteger currentFrameCount;

@property (nonatomic, assign) NSInteger resetCount;

@end


@implementation GLImageSoulOutFilter


- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGLImageSoulOutFragmentShaderString];
    if (self) {
        
        self.currentFrameCount = 0;
        self.resetCount = 0;
        
        
    }
    return self;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex{
    
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
    
    self.currentFrameCount = self.currentFrameCount + 1;
    
    
    if (self.currentFrameCount == kMaxResetCount) {
        self.currentFrameCount =0;
    }
    
    if (self.currentFrameCount>=kMinResetCount) {
        self.resetCount = self.resetCount + 12;
    }else{
        self.resetCount = 0;
    }
    
    //这里是做灵魂出窍的重点计算
    NSInteger value = self.resetCount;
    [self updateForegroundTexture:1.0+(value/100.0)];
}


- (void)updateForegroundTexture:(float)scale{
    [self setFloat:scale forUniformName:@"scale"];
}



@end
