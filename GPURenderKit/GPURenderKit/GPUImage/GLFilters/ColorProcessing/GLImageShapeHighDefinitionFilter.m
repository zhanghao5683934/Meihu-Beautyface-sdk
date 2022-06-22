//
//  GLImageShapeHighDefinitionFilter.m
//  WEOpenGLKit
//
//  Created by 刘海东 on 2018/6/26.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageShapeHighDefinitionFilter.h"

@interface GLImageShapeHighDefinitionFilter ()
{
    GLfloat squareVertexes[16];
    GLfloat textureCoordinates[16];
    
}
@property (nonatomic, assign) float changValue;
@property (nonatomic, strong) GPUImagePicture *input;
/** 改变的fboSize */
@property (nonatomic, assign) CGSize fboSize;
/** type  */
@property (nonatomic, assign) NSInteger type;
/** 形变值 */
@property (nonatomic, assign) float value;


@end


@implementation GLImageShapeHighDefinitionFilter


- (instancetype)initWithType:(NSInteger)type changeValue:(float)changeValue
{
    self = [super init];
    if (self) {
        _type = type;
        _value = changeValue;
    }
    return self;
}


- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    
    [self renderToTextureWithVertices:squareVertexes textureCoordinates:textureCoordinates];
    [self informTargetsAboutNewFrameAtTime:frameTime];
}


- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 8);
    //    glFlush();
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}


- (CGSize)sizeOfFBO
{
    return _fboSize;
}

#pragma mark setFunc
- (void)setOriginImage:(UIImage *)originImage
{
    _originImage = originImage;
    [self input];
    
    GLint maxTextureSize = [GPUImageContext maximumTextureSizeForThisDevice];
        
    //计算FBOSize
    if (_type == 0)
    {
        //增高
        _fboSize = CGSizeMake(originImage.size.width, originImage.size.height*(1.0+_value));
    }
    else
    {
        //瘦身
        _fboSize = CGSizeMake(originImage.size.width*(1.0+_value), originImage.size.height);
    }
    
    if ( (_fboSize.width > maxTextureSize) || (_fboSize.height > maxTextureSize) )
    {
        
        CGSize adjustedSize;
        if (_fboSize.width > _fboSize.height)
        {
            adjustedSize.width = (CGFloat)maxTextureSize;
            adjustedSize.height = ((CGFloat)maxTextureSize / _fboSize.width) * _fboSize.height;
        }
        else
        {
            adjustedSize.height = (CGFloat)maxTextureSize;
            adjustedSize.width = ((CGFloat)maxTextureSize / _fboSize.height) * _fboSize.width;
        }
        
        _fboSize = adjustedSize;
    }

}

- (GPUImagePicture *)input
{
    if (!_input)
    {
        _input = [[GPUImagePicture alloc]initWithImage:_originImage];
        [_input addTarget:self];
    }
    return _input;
}


- (void)setSquareVertexeArray:(NSArray *)squareVertexeArray
{
    _squareVertexeArray = squareVertexeArray;
    for (int i=0; i!=squareVertexeArray.count; i++) {
        squareVertexes[i] = [self getFloat:squareVertexeArray[i]];
    }
    
}

- (void)setTextureCoordinateArray:(NSArray *)textureCoordinateArray
{
    _textureCoordinateArray = textureCoordinateArray;
    
    for (int i=0; i!=textureCoordinateArray.count; i++) {
        textureCoordinates[i] = [self getFloat:textureCoordinateArray[i]];
    }
}

- (float)getFloat:(NSNumber *)number
{
    return number.floatValue;
}


- (UIImage *)getImageFromCurrentFramebuffer
{

    [self.input processImage];
    [self useNextFrameForImageCapture];
    UIImage *image =  [self imageFromCurrentFramebuffer];

    [self removeOutputFramebuffer];
    [self removeAllTargets];
    if (_input) {
        [_input removeTarget:self];
        [_input removeAllTargets];
        [_input removeOutputFramebuffer];
        _input = nil;
    }
    return image;
}

- (void)dealloc
{
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    NSLog(@"GLImageShapeHighDefinitionFilter---dealloc");
}


@end
