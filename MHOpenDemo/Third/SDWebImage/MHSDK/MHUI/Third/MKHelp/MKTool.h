//
//  MKTool.h
//  MagicCamera
//
//  Created by mkil on 2019/10/9.
//  Copyright © 2019 黎宁康. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKTool : NSObject

/// 获取当前毫秒数
+ (uint64_t)getCurrentTimeMillis;

/// 两点之间距离
float getDistance(float x1, float y1, float x2, float y2);

/**
 *  获取两点的中心点
 *  @param x1 第一个点x坐标
 *  @param y1 第一个点y坐标
 *  @param x2 第二个点x坐标
 *  @param y2 第二个点y坐标
 @  @param point 结果数组
 */
void getCenter(float x1, float y1, float x2, float y2, float point[2]);
@end

NS_ASSUME_NONNULL_END
