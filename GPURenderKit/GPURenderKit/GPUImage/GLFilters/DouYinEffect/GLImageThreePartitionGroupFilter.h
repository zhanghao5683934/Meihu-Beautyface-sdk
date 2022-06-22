//
//  GLImageThreePartitionGroupFilter.h
//  WEOpenGLKit
//
//  Created by 刘海东 on 2019/2/19.
//  Copyright © 2019 Leo. All rights reserved.
//

#import <GPURenderKit/GPURenderKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLImageThreePartitionGroupFilter : GPUImageFilterGroup

/** directionType:0 竖直方向 1:水平方向 */
@property (nonatomic, assign) int directionType;

@property (nonatomic, assign) float intensity;


- (void)setTopLutImg:(UIImage *)topLutImg;
- (void)setMidLutImg:(UIImage *)midLutImg;
- (void)setBottomLutImg:(UIImage *)bottomLutImg;



@end

NS_ASSUME_NONNULL_END
