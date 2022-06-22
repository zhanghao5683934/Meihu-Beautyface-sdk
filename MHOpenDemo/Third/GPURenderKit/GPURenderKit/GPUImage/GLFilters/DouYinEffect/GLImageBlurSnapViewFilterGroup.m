//
//  GLImageBlurSnapViewFilterGroup.m
//  GPURenderKit
//
//  Created by 刘海东 on 2019/4/19.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import "GLImageBlurSnapViewFilterGroup.h"

@interface GLImageBlurSnapViewFilterGroup ()

@property (nonatomic, strong) GPUImageGaussianBlurFilter *gaussianBlurFilter;
@property (nonatomic, strong) GLImageBlurSnapViewFilter *blurSnapViewFilter;


@end


@implementation GLImageBlurSnapViewFilterGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc]init];
        self.gaussianBlurFilter.blurRadiusInPixels = 20.0;
        [self addFilter:self.gaussianBlurFilter];
        
        self.blurSnapViewFilter = [[GLImageBlurSnapViewFilter alloc]init];
        [self addFilter:self.blurSnapViewFilter];
        
        
        [self.gaussianBlurFilter addTarget:self.blurSnapViewFilter atTextureLocation:1];
        
        
        self.initialFilters = [NSArray arrayWithObjects:self.gaussianBlurFilter, self.blurSnapViewFilter, nil];
        self.terminalFilter = self.blurSnapViewFilter;

    }
    return self;
}

- (void)setBlurRadiusInPixels:(float)blurRadiusInPixels{
    
    _blurRadiusInPixels = blurRadiusInPixels;
    if (blurRadiusInPixels<0.0 || blurRadiusInPixels>30.0) {
        _blurRadiusInPixels = 30.0;
    }
    self.gaussianBlurFilter.blurRadiusInPixels = blurRadiusInPixels;
}

- (void)setBlurTextureScal:(float)blurTextureScal{
    self.blurSnapViewFilter.blurTextureScal = blurTextureScal;
}

- (void)setBlurOffsetY:(float)blurOffsetY{
    self.blurSnapViewFilter.blurOffsetY = blurOffsetY;
}


@end
