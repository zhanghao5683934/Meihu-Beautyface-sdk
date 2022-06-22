//
//  GLImageBlurSnapViewFilter.h
//  GPURenderKit
//
//  Created by 刘海东 on 2019/4/19.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import <GPURenderKit/GPURenderKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLImageBlurSnapViewFilter : GPUImageTwoInputFilter
{
    GLuint blurOffsetYUniform,blurTextureScalUniform;
    
}


/** 模糊位置【0.0-0.5】 default:0.25*/
@property (nonatomic, assign) float blurOffsetY;

/** 底部纹理缩放系数 【1.0- 5.0】 */
@property (nonatomic, assign) float blurTextureScal;

@end

NS_ASSUME_NONNULL_END
