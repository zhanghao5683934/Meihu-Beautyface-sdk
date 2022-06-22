//
//  GLImageFaceDetectPointFilter.m
//  GPURenderKit
//
//  Created by 刘海东 on 2019/4/25.
//  Copyright © 2019 刘海东. All rights reserved.
//

#import "GLImageFaceDetectPointFilter.h"

NSString *const kGLImageFaceDetectPointFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     
     highp vec2 uv = textureCoordinate;     
     gl_FragColor = vec4(0.2, 0.709803922, 0.898039216, 1.0);
 }
 );

NSString *const kGLImageFaceDetectPointVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     gl_PointSize = 8.0;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

@interface GLImageFaceDetectPointFilter ()

@property (nonatomic, strong) NSArray *pointArrays;

@property (nonatomic, assign) GLfloat videoFrameW;
@property (nonatomic, assign) GLfloat videoFrameH;
/** 是否是前置摄像头 */
@property (nonatomic, assign) BOOL isFront;

@end


@implementation GLImageFaceDetectPointFilter

- (instancetype)init
{
    self = [super initWithVertexShaderFromString:kGLImageFaceDetectPointVertexShaderString fragmentShaderFromString:kGLImageFaceDetectPointFragmentShaderString];
    if (self) {
        self.isShowFaceDetectPointBool = YES;
    }
    return self;
}

- (void)setFacePointsArray:(NSArray *)pointArrays{
    _pointArrays = pointArrays;    
}

- (void)setIsShowFaceDetectPointBool:(BOOL)isShowFaceDetectPointBool{
    _isShowFaceDetectPointBool = isShowFaceDetectPointBool;
}


- (void)setupFilterForSize:(CGSize)filterFrameSize
{
    self.videoFrameW = filterFrameSize.width;
    self.videoFrameH = filterFrameSize.height;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates{
    
    
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    //是否开启人脸监测点
    if (!_isShowFaceDetectPointBool) {
        [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
        return;
    }
    
    if (self.pointArrays.count==0) {
        [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
        return;
    }

    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    
    [self setUniformsForProgramAtIndex:0];
    
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    const GLsizei pointCount = (GLsizei)self.pointArrays.count;
    GLfloat tempPoint[pointCount * 2];
    
    for (int i = 0; i < self.pointArrays.count; i ++) {
        CGPoint pointer = [self.pointArrays[i] CGPointValue];
        
        if (self.isFront) {
            tempPoint[i*2+0]=  (pointer.y/_videoFrameW) *2.0 - 1.0;
            tempPoint[i*2+1]=  (pointer.x/_videoFrameH) *2.0 - 1.0;
        }else{
            tempPoint[i*2+0]=  1.0 - ((pointer.y/_videoFrameW) * 2.0);
            tempPoint[i*2+1]=  (pointer.x/_videoFrameH) *2.0 - 1.0;
        }
    }
    
    glVertexAttribPointer(self->filterPositionAttribute, 2, GL_FLOAT, GL_FALSE, 0, tempPoint);
    glDrawArrays(GL_POINTS, 0, (GLsizei)self.pointArrays.count);

    [self informTargetsAboutNewFrameAtTime:frameTime];
    [firstInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }

}

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition{
    
    if (captureDevicePosition == AVCaptureDevicePositionBack) {
        self.isFront = NO;
    }else{
        self.isFront = YES;
    }
}


@end
