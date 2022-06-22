//
//  MKLandmarkEngine.m
//  MagicCamera
//
//  Created by mkil on 2019/11/5.
//  Copyright © 2019 黎宁康. All rights reserved.
//

#import "MKLandmarkEngine.h"
#import "MKLandmarkManager.h"
#import "MKFaceBaseData.h"
#import "MKTool.h"

static MKLandmarkEngine *engine = nil;

@implementation MKLandmarkEngine

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[self alloc] init];
    });
    
    return engine;
}

#pragma mark -
#pragma mark 美型系列
/**
 * 获取用于美型处理的坐标
 * @param vertexPoints      顶点坐标, 共122个顶点
 * @param texturePoints     纹理坐标, 共122个顶点
 @ @param length            数组长度
 * @param faceIndex         人脸索引
 */

-(void)generateFaceAdjustVertexPoints:(float *)vertexPoints withTexturePoints:(float *)texturePoints withLength:(int)length withFaceIndex:(int)faceIndex {
    
    if (vertexPoints == NULL || length != 122 * 2 || texturePoints == NULL) {
        return;
    }
    
    // 计算额外的人脸顶点坐标
    [self calculateExtraFacePoints:vertexPoints withLength:length withFaceIndex:faceIndex];
    // 计算图像边沿顶点坐标
    [self calculateImageEdgePoints:vertexPoints withLength:length];
    // 计算纹理坐标
    for (int i = 0; i < length; i ++) {
        texturePoints[i] = vertexPoints[i] * 0.5 + 0.5;
    }
}

/**
 *  计算人脸额外顶点，新增8个额外顶点坐标
 *  @param vertexPoints 顶点坐标, 共122个顶点
 *  @param length       数组长度
 *  @param faceIndex    人脸索引
 */
-(void)calculateExtraFacePoints:(float *)vertexPoints withLength:(int)length withFaceIndex:(int)faceIndex {
    if (MKLandmarkManager.shareManager.faceData == NULL || MKLandmarkManager.shareManager.faceData.count <= 0 || MKLandmarkManager.shareManager.faceData.count <= faceIndex) {
        return;
    }
    
    MKFaceInfo *faceInfo = MKLandmarkManager.shareManager.faceData[faceIndex];
    
    if(vertexPoints == NULL || (faceInfo.points.count + 8) * 2 > length ) {
        return;
    }
    
    // 取出前106个关键点
    for (int i = 0; i < faceInfo.points.count; i ++) {
        vertexPoints[i * 2] = [faceInfo.points[i] CGPointValue].x;
        vertexPoints[i * 2 + 1] = [faceInfo.points[i] CGPointValue].y;
    }
    
    float tempPoint[2] = {0,0};
    // 嘴唇中心
    getCenter(vertexPoints[mouthUpperLipBottom * 2], vertexPoints[mouthUpperLipBottom * 2 + 1], vertexPoints[mouthLowerLipTop * 2], vertexPoints[mouthLowerLipTop * 2 + 1], tempPoint);
    vertexPoints[mouthCenter * 2] = tempPoint[0];
    vertexPoints[mouthCenter * 2 + 1] = tempPoint[1];
    
    // 左眉心
    getCenter(vertexPoints[leftEyebrowUpperMiddle * 2], vertexPoints[leftEyebrowUpperMiddle * 2 + 1], vertexPoints[leftEyebrowLowerMiddle * 2], vertexPoints[leftEyebrowLowerMiddle * 2 + 1], tempPoint);
    vertexPoints[leftEyebrowCenter * 2] = tempPoint[0];
    vertexPoints[leftEyebrowCenter * 2 + 1] = tempPoint[1];
    
    // 右眉心
    getCenter(vertexPoints[rightEyebrowUpperMiddle * 2], vertexPoints[rightEyebrowUpperMiddle * 2 + 1], vertexPoints[rightEyebrowLowerMiddle * 2], vertexPoints[rightEyebrowLowerMiddle * 2 + 1], tempPoint);
    vertexPoints[rightEyebrowCenter * 2] = tempPoint[0];
    vertexPoints[rightEyebrowCenter * 2 + 1] = tempPoint[1];
    
    // 额头中心
    vertexPoints[headCenter * 2] = vertexPoints[eyeCenter * 2] * 2 - vertexPoints[noseLowerMiddle * 2];
    vertexPoints[headCenter * 2 + 1] = vertexPoints[eyeCenter * 2 + 1] * 2 - vertexPoints[noseLowerMiddle * 2 + 1];
    
    // 额头左侧
    getCenter(vertexPoints[leftEyebrowLeftTopCorner * 2], vertexPoints[leftEyebrowLeftTopCorner * 2 + 1], vertexPoints[headCenter * 2], vertexPoints[headCenter * 2 + 1], tempPoint);
    vertexPoints[leftHead * 2] = tempPoint[0];
    vertexPoints[leftHead * 2 + 1] = tempPoint[1];
    
    // 额头右侧
    getCenter(vertexPoints[rightEyebrowRightTopCorner * 2], vertexPoints[rightEyebrowRightTopCorner * 2 + 1], vertexPoints[headCenter * 2], vertexPoints[headCenter * 2 + 1], tempPoint);
    vertexPoints[rightHead * 2] = tempPoint[0];
    vertexPoints[rightHead * 2 + 1] = tempPoint[1];
    
    // 左脸颊中心
    getCenter(vertexPoints[leftCheekEdgeCenter * 2], vertexPoints[leftCheekEdgeCenter * 2 + 1], vertexPoints[noseLeft * 2], vertexPoints[noseLeft * 2 + 1], tempPoint);
    vertexPoints[leftCheekCenter * 2] = tempPoint[0];
    vertexPoints[leftCheekCenter * 2 + 1] = tempPoint[1];
    
    // 右脸颊中心
    getCenter(vertexPoints[rightCheekEdgeCenter * 2], vertexPoints[rightCheekEdgeCenter * 2 + 1], vertexPoints[noseRight * 2], vertexPoints[noseRight * 2 + 1], tempPoint);
    vertexPoints[rightCheekCenter * 2] = tempPoint[0];
    vertexPoints[rightCheekCenter * 2 + 1] = tempPoint[1];
    
}

/**
 *  计算图像周围顶点
 *  @param vertexPoints 顶点坐标
 *  @param length       数组长度
 */

-(void)calculateImageEdgePoints:(float *)vertexPoints withLength:(int)length {
    
    if (vertexPoints == NULL || length < 122 * 2) {
        return;
    }
    
    // TODO: 方向待处理
    vertexPoints[114 * 2] = 0;
    vertexPoints[114 * 2 + 1] = 1;
    vertexPoints[115 * 2] = 1;
    vertexPoints[115 * 2 + 1] = 1;
    vertexPoints[116 * 2] = 1;
    vertexPoints[116 * 2 + 1] = 0;
    vertexPoints[117 * 2] = 1;
    vertexPoints[117 * 2 + 1] = -1;
    
    // 118 ~ 121 与 114 ~ 117 的顶点坐标恰好反过来
    vertexPoints[118 * 2] = -vertexPoints[114 * 2];
    vertexPoints[118 * 2 + 1] = -vertexPoints[114 * 2 + 1];
    vertexPoints[119 * 2] = -vertexPoints[115 * 2];
    vertexPoints[119 * 2 + 1] = -vertexPoints[115 * 2 + 1];
    vertexPoints[120 * 2] = -vertexPoints[116 * 2];
    vertexPoints[120 * 2 + 1] = -vertexPoints[116 * 2 + 1];
    vertexPoints[121 * 2] = -vertexPoints[117 * 2];
    vertexPoints[121 * 2 + 1] = -vertexPoints[117 * 2 + 1];
}

#pragma mark -
#pragma mark 美妆系列

/**
 *  取得嘴唇(唇彩)顶点坐标
 *  @param vertexPoints 存放嘴唇顶点坐标 (40)
 *  @param length       数组长度
 *  @param faceIndex    人脸索引
 */
-(void)getLipsVertices:(float *)vertexPoints withLength:(int)length withFaceIndex:(int)faceIndex
{
    if (MKLandmarkManager.shareManager.faceData == NULL || MKLandmarkManager.shareManager.faceData.count <= 0 || MKLandmarkManager.shareManager.faceData.count <= faceIndex) {
        return;
    }
    
    // 嘴唇一共20个顶点，大小必须为40
    if (vertexPoints == NULL || length < 40) {
        return;
    }
    
    MKFaceInfo *faceInfo = MKLandmarkManager.shareManager.faceData[faceIndex];
    
    if (faceInfo.points.count < 106) return;
    // 复制84 ~ 103共20个顶点坐标
    for (int i = 0; i < 20; i ++) {
        vertexPoints[i * 2] = [faceInfo.points[84 + i] CGPointValue].x;
        vertexPoints[i * 2 + 1] = [faceInfo.points[84 + i] CGPointValue].y;
    }
}

@end
