//
//  GLImageFaceDetectPointFilter.h
//  GPURenderKit
//
//  Created by 刘海东 on 2019/4/25.
//  Copyright © 2019 刘海东. All rights reserved.
//



#import <GPURenderKit/GPURenderKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 人脸检检测特征点显示 */
@interface GLImageFaceDetectPointFilter : GPUImageFilter
/** 人脸检测点显示 默认开启*/
@property (nonatomic, assign) BOOL isShowFaceDetectPointBool;

- (void)setFacePointsArray:(NSArray *)pointArrays;

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition;


@end

NS_ASSUME_NONNULL_END
