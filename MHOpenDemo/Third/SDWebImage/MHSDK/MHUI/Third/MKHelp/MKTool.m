//
//  MKTool.m
//  MagicCamera
//
//  Created by mkil on 2019/10/9.
//  Copyright © 2019 黎宁康. All rights reserved.
//

#import "MKTool.h"

@implementation MKTool

/// 获取当前毫秒数
+(uint64_t)getCurrentTimeMillis {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

/// 两点之间距离
float getDistance(float x1, float y1, float x2, float y2) {
    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
}

/**
 *  获取两点的中心点
 *  @param x1 第一个点x坐标
 *  @param y1 第一个点y坐标
 *  @param x2 第二个点x坐标
 *  @param y2 第二个点y坐标
 @  @param point 结果数组
 */
void getCenter(float x1, float y1, float x2, float y2, float point[2]) {
    point[0] = (x1 + x2) / 2.0;
    point[1] = (y1 + y2) / 2.0;
}

@end
