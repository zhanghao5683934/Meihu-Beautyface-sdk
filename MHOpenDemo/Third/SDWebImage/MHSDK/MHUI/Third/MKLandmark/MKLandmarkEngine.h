//
//  MKLandmarkEngine.h
//  MagicCamera
//
//  Created by mkil on 2019/11/5.
//  Copyright © 2019 黎宁康. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLandmarkEngine : NSObject

+ (instancetype)shareManager;

/**
 * 获取用于美型处理的坐标
 * @param vertexPoints      顶点坐标, 共122个顶点
 * @param texturePoints     纹理坐标, 共122个顶点
 @ @param length            数组长度
 * @param faceIndex         人脸索引
 */
-(void)generateFaceAdjustVertexPoints:(float *)vertexPoints withTexturePoints:(float *)texturePoints withLength:(int)length withFaceIndex:(int)faceIndex;

/**
 *  取得嘴唇(唇彩)顶点坐标
 *  @param vertexPoints 存放嘴唇顶点坐标 (40)
 *  @param length       数组长度
 *  @param faceIndex    人脸索引
 */
-(void)getLipsVertices:(float *)vertexPoints withLength:(int)length withFaceIndex:(int)faceIndex;

@end

NS_ASSUME_NONNULL_END
