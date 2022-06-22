//
//  GPUImageBeautifyFilter.h
//  MagicCamera
//
//  Created by mkil on 2019/9/4.
//  Copyright © 2019 黎宁康. All rights reserved.
//

#import "GPUImageFilterGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageBeautifyFilter : GPUImageFilterGroup

// 美颜的强度 (0~1, 默认 0.5)
@property (nonatomic, assign) CGFloat intensity;

@end

NS_ASSUME_NONNULL_END
