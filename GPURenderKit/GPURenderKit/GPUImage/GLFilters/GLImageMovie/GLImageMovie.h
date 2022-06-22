//
//  GLImageMovie.h
//  WEOpenGLDemo
//
//  Created by 刘海东 on 2019/1/4.
//  Copyright © 2019 Leo. All rights reserved.
//

#import "GPUImage.h"
NS_ASSUME_NONNULL_BEGIN

@interface GLImageMovie : GPUImageOutput

@property (nonatomic, assign) BOOL runBenchmark;

- (void)processMovieFrameSampleBuffer:(CMSampleBufferRef)sampleBufferRef;

- (void)endProcessing;


@end

NS_ASSUME_NONNULL_END
