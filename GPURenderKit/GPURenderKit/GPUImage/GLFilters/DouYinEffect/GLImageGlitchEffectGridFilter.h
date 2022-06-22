//
//  GLImageGlitchEffectGridFilter.h
//  WEOpenGLKit
//
//  Created by 刘海东 on 2018/8/31.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import <GPURenderKit/GPURenderKit.h>

//故障效果---格子故障
@interface GLImageGlitchEffectGridFilter : GPUImageTwoInputFilter
{
    GLint intensityUniform;
    GLint colorIntensityUniform;
    GLint blendModeUniform;
    GPUImagePicture *plaidImageSource;
}

@property (nonatomic, assign) float intensity;
@property (nonatomic, assign) float colorIntensity;
@property (nonatomic, assign) int blendMode;
- (void)setPlaidImage:(UIImage *)plaidImage;

@end
