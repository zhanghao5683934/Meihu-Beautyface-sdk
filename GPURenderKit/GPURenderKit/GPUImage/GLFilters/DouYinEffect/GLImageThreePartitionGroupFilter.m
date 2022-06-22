//
//  GLImageThreePartitionGroupFilter.m
//  WEOpenGLKit
//
//  Created by 刘海东 on 2019/2/19.
//  Copyright © 2019 Leo. All rights reserved.
//

#import "GLImageThreePartitionGroupFilter.h"


@implementation GLImageThreePartitionGroupFilter
{
    GLImageThreePartitionFilter *threePartitionFilter;
    GPUImagePicture *topLutPic;
    GPUImagePicture *midLutPic;
    GPUImagePicture *bottomLutPic;

}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        threePartitionFilter = [[GLImageThreePartitionFilter alloc]init];
        [self addFilter:threePartitionFilter];
        self.initialFilters = @[threePartitionFilter];
        self.terminalFilter = threePartitionFilter;
        threePartitionFilter.intensity = 0.0;
        
    }
    return self;
}

- (void)setIntensity:(float)intensity
{
    _intensity = intensity;
    threePartitionFilter.intensity = intensity;
}

- (void)setDirectionType:(int)directionType{
    _directionType = directionType;
    threePartitionFilter.directionType = directionType;
}

- (void)setTopLutImg:(UIImage *)topLutImg
{
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:topLutImg];
    [picture addTarget:threePartitionFilter atTextureLocation:1];
    [picture processImage];
    [threePartitionFilter disableSecondFrameCheck];
    
    if (topLutPic)
    {
        [topLutPic removeTarget:threePartitionFilter];
        topLutPic = nil;
    }
    
    topLutPic = picture;

}
- (void)setMidLutImg:(UIImage *)midLutImg
{

    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:midLutImg];
    [picture addTarget:threePartitionFilter atTextureLocation:2];
    [picture processImage];
    [threePartitionFilter disableThirdFrameCheck];
    
    if (midLutPic)
    {
        [midLutPic removeTarget:threePartitionFilter];
        midLutPic = nil;
    }
    
    midLutPic = picture;
}
- (void)setBottomLutImg:(UIImage *)bottomLutImg
{
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:bottomLutImg];
    [picture addTarget:threePartitionFilter atTextureLocation:3];
    [picture processImage];
    [threePartitionFilter disableFourthFrameCheck];
    
    if (bottomLutPic)
    {
        [bottomLutPic removeTarget:threePartitionFilter];
        bottomLutPic = nil;
    }
    
    bottomLutPic = picture;
    
}

@end
