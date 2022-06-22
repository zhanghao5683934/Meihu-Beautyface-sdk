//  希望您的举手之劳，能为我点颗赞，谢谢~
//  代码地址: https://github.com/Bonway/BBGPUImage
//  BBGPUImage
//  Created by Bonway on 2016/3/17.
//  Copyright © 2016年 Bonway. All rights reserved.
//

#import <GPURenderKit/GPURenderKit.h>

@class GPUImageCombinationFilter;

@interface BBGPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageSobelEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}

/** 美颜程度*/
@property (nonatomic, assign) CGFloat intensity;

/** 亮度*/
@property (nonatomic, assign) CGFloat brightness;
/** 饱和度*/
@property (nonatomic, assign) CGFloat saturation;

@end
