//
//  GLImageFaceChangeFilterGroup.m
//  GPURenderKit
//
//  Created by 刘海东 on 2019/4/26.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import "GLImageFaceChangeFilterGroup.h"

@interface GLImageFaceChangeFilterGroup ()

@property (nonatomic, strong) GLImageFaceChangeFilter *faceChangeFilter;
@property (nonatomic, strong) GLImageFaceDetectPointFilter *faceDetectPointFilter;
@property (nonatomic, strong) GPUImageScreenBlendFilter *blendFilter;

@end


@implementation GLImageFaceChangeFilterGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.faceChangeFilter = [[GLImageFaceChangeFilter alloc]init];
        [self addFilter:self.faceChangeFilter];

        self.faceDetectPointFilter = [[GLImageFaceDetectPointFilter alloc]init];
        self.faceDetectPointFilter.isShowFaceDetectPointBool = YES;
        [self addFilter:self.faceDetectPointFilter];
        
        // 混合模式
        self.blendFilter = [[GPUImageScreenBlendFilter alloc] init];
        [self addFilter:self.blendFilter];
        
        [self.faceChangeFilter addTarget:self.blendFilter atTextureLocation:0];
        [self.faceDetectPointFilter addTarget:self.blendFilter atTextureLocation:1];

        self.initialFilters = [NSArray arrayWithObjects:self.faceChangeFilter, self.faceDetectPointFilter, self.blendFilter,nil];
        self.terminalFilter = self.blendFilter;

        
    }
    return self;
}

- (void)setFacePointsArray:(NSArray *)pointArrays{
    
    [self.faceChangeFilter setFacePointsArray:pointArrays];
    [self.faceDetectPointFilter setFacePointsArray:pointArrays];

}

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition{
    
    [self.faceChangeFilter setCaptureDevicePosition:captureDevicePosition];
    [self.faceDetectPointFilter setCaptureDevicePosition:captureDevicePosition];

}


#pragma mark ------------------------------------------------------ publicFunc ------------------------------------------------------
- (void)setIsHaveFace:(BOOL)isHaveFace{
    self.faceChangeFilter.isHaveFace = isHaveFace;
}

- (void)setThinFaceParam:(float)thinFaceParam{
    self.faceChangeFilter.thinFaceParam = thinFaceParam;
}

- (void)setEyeParam:(float)eyeParam{
    self.faceChangeFilter.eyeParam = eyeParam;
}

- (void)setNoseParam:(float)noseParam{
    self.faceChangeFilter.noseParam = noseParam;
}

- (void)setIsShowFaceDetectPointBool:(BOOL)isShowFaceDetectPointBool{
    self.faceDetectPointFilter.isShowFaceDetectPointBool = isShowFaceDetectPointBool;
}


@end
