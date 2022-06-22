//
//  GLImageShapeFilter.h
//  WEOpenGLKit
//
//  Created by 刘海东 on 2018/6/14.
//  Copyright © 2018年 LHD. All rights reserved.
//

//增高瘦身 Filter

#import <GPURenderKit/GPURenderKit.h>

/**
 获取处理后的数据

 @param squareVertexes 顶点坐标数组
 @param textureCoordinates 纹理坐标数组
 @param changeValue 改变的值
 @param type 0 增高 1瘦身
 */
typedef void(^GetVerticesAndTextureCoordinatesHandle)(NSArray *squareVertexes,NSArray *textureCoordinates,float changeValue, NSInteger type);

@interface GLImageShapeFilter : GPUImageFilter


@property (nonatomic, assign) float imageWidth;
@property (nonatomic, assign) float imageHeight;
/** 屏幕宽高比 */
@property (nonatomic, assign) float screenRatio;
/** 归一化的 0.0-1.0*/
/** 区间值 最小 */
@property (nonatomic, assign) float minValue;
/** 区间值 最大 */
@property (nonatomic, assign) float maxValue;
/** 0:增高 1:瘦身 */
@property (nonatomic, assign) NSInteger type;


- (void)changeValue:(float)value;

/** 获取处理后的顶点纹理坐标数组 */
- (void)getVerticesAndTextureCoordinatesHandle:(GetVerticesAndTextureCoordinatesHandle)result;




@end

