//
//  GLImageFaceChangeFilterGroup.h
//  GPURenderKit
//
//  Created by 刘海东 on 2019/4/26.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import <GPURenderKit/GPURenderKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLImageFaceChangeFilterGroup : GPUImageFilterGroup


/** 是否检测到人脸 */
@property (nonatomic, assign) BOOL isHaveFace;
/** 瘦脸调节【-1.0 - 1.0】 */
@property (nonatomic, assign) float thinFaceParam;
/** 眼睛调节【-1.0 - 1.0】*/
@property (nonatomic, assign) float eyeParam;
/** 鼻子调节【-1.0 - 1.0】*/
@property (nonatomic, assign) float noseParam;

/** 人脸检测点显示 默认开启*/
@property (nonatomic, assign) BOOL isShowFaceDetectPointBool;

- (void)setFacePointsArray:(NSArray *)pointArrays;

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition;


@end

NS_ASSUME_NONNULL_END
