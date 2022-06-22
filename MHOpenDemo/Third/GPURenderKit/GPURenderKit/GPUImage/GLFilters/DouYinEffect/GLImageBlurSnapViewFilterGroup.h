//
//  GLImageBlurSnapViewFilterGroup.h
//  GPURenderKit
//
//  Created by 刘海东 on 2019/4/19.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import <GPURenderKit/GPURenderKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLImageBlurSnapViewFilterGroup : GPUImageFilterGroup

/** 模糊半径【0.0 - 30.0】default：20.0*/
@property (nonatomic, assign) float blurRadiusInPixels;

/** 模糊位置【0.0-0.5】 default:0.25 */
@property (nonatomic, assign) float blurOffsetY;

/** 底部纹理缩放系数 【1.0- 5.0】 default:2.0 */
@property (nonatomic, assign) float blurTextureScal;


@end

NS_ASSUME_NONNULL_END
