//
//  GLImageShapeHighDefinitionFilter.h
//  WEOpenGLKit
//
//  Created by 刘海东 on 2018/6/26.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import <GPURenderKit/GPURenderKit.h>
//增高瘦身 处理的Filter

@interface GLImageShapeHighDefinitionFilter : GPUImageFilter



/** 顶点坐标 */
@property (nonatomic, copy) NSArray *squareVertexeArray;
/** 纹理坐标 */
@property (nonatomic, copy) NSArray *textureCoordinateArray;
/** 处理图片 */
@property (nonatomic, copy) UIImage *originImage;



/**
 初始化GLImageShapeHighDefinitionFilter

 @param type 0增高 1瘦身
 @param changeValue 高或者宽的 形变值。
 @return GLImageShapeHighDefinitionFilter
 */
- (instancetype)initWithType:(NSInteger)type changeValue:(float)changeValue;


/** 获取处理后的图片 */
- (UIImage *)getImageFromCurrentFramebuffer;

@end
