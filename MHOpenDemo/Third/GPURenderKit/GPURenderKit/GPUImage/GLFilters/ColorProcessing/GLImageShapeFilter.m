//
//  GLImageShapeFilter.m
//  WEOpenGLKit
//
//  Created by 刘海东 on 2018/6/14.
//  Copyright © 2018年 LHD. All rights reserved.
//

#import "GLImageShapeFilter.h"
/** 增高最多是原图的增高的8% */
#define kStretchMaxRatio 0.08
/** 增高的最大值 */
#define kStretchMax_h (_imageHeight*kStretchMaxRatio)
/** 0.6是产品定义的 */
#define kRatio 0.6
/** 压缩的比例值 */
#define kCompress_ratio (0.8 *kRatio)
@interface GLImageShapeFilter ()
{
    GLfloat squareVertexes[16];
    GLfloat textureCoordinates[16];

}
@property (nonatomic, assign) float changValue;
@end


@implementation GLImageShapeFilter




- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
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


#pragma mark 配置竖直方向上面的顶点数据
- (void )verticalConfigVertex
{
    
    float imageRatio = (float)self.imageWidth/self.imageHeight;
    float screenRatio = self.screenRatio;
    float xfactor=1.0;
    float yfactor=1.0;
    
    
    float tempValue = self.changValue;
    //负值
    float xMinus = -xfactor;
    float yMinus = -yfactor;
    
    //正值
    float xPlus = xfactor;
    float yPlus = yfactor;
    
    
    float x1,x2,x3,x4,x5,x6,x7,x8 = 0.0;
    float y1,y2,y3,y4,y5,y6,y7,y8 = 0.0;
    float tx1,tx2,tx3,tx4,tx5,tx6,tx7,tx8 = 0.0;
    float ty1,ty2,ty3,ty4,ty5,ty6,ty7,ty8 = 0.0;
    
    
    if (imageRatio > screenRatio) {
        
        //宽顶到边
        yMinus = xMinus*screenRatio/(_imageWidth/(_imageHeight+tempValue*kStretchMax_h));
        yPlus = xPlus*screenRatio/(_imageWidth/(_imageHeight+tempValue*kStretchMax_h));
        
        //原来的比例
        float originY = xPlus*screenRatio/imageRatio;
        
        //高大于宽
        x1 = xMinus;
        y1 = yMinus;
        tx1 = 0;
        ty1 = 0;
        
        x2 = xPlus;
        y2 = yMinus;
        tx2 = 1;
        ty2 = 0;
        
        
        /** 极限值的判断处理 */
        if ((yMinus<-1.0000001 || yMinus>-0.0000001) || (yPlus>1.0000001 || yPlus<.0000001)) {
            
            //负值
            yMinus = -yfactor;
            //正值
            yPlus = yfactor;
            
            xMinus = yMinus*_imageWidth/(_imageHeight+tempValue*kStretchMax_h)/screenRatio;
            xPlus = xPlus*_imageWidth/(_imageHeight+tempValue*kStretchMax_h)/screenRatio;
            
            //原来的比例
            float originX = yMinus*imageRatio/screenRatio;
            
            x1 = xMinus;
            y1 = yMinus;
            tx1 = 0;
            ty1 = 0;
            
            x2 = xPlus;
            y2 = yMinus;
            tx2 = 1;
            ty2 = 0;
            
            //原来的高
            CGFloat h = ABS(1-2*_maxValue + 1) *xMinus/originX;
            
            x3 = xMinus;
            y3 = -(1.0-h);
            tx3 = 0;
            ty3 = (1-_maxValue);
            
            x4 = xPlus;
            y4 = -(1.0-h);
            tx4 = 1;
            ty4 = (1-_maxValue);
            
            
            x5 = xMinus;
            y5 = (1-2*_minValue*xMinus/originX);
            tx5 = 0;
            ty5 = (1-_minValue);
            
            
            x6 = xPlus;
            y6 = (1-2*_minValue*xMinus/originX);
            tx6 = 1;
            ty6 = (1-_minValue);
            
            x7 = xMinus;
            y7 = yPlus;
            tx7 = 0;
            ty7 = 1;
            
            x8 = xPlus;
            y8 = yPlus;
            tx8 = 1;
            ty8 = 1;
            
        }
        else
        {
            //形变
            CGFloat h = yPlus;
            CGFloat value = (h - originY);
            
            x3 = xMinus;
            y3 = (1-2*_maxValue)*originY-value;
            tx3 = 0;
            ty3 = (1-_maxValue);
            
            x4 = xPlus;
            y4 = (1-2*_maxValue)*originY-value;
            tx4 = 1;
            ty4 = (1-_maxValue);
            
            x5 = xMinus;
            y5 =  (1-2*_minValue)*originY+value;
            tx5 = 0;
            ty5 = (1-_minValue);
            
            x6 = xPlus;
            y6 = (1-2*_minValue)*originY+value;
            tx6 = 1;
            ty6 = (1-_minValue);
            
            x7 = xMinus;
            y7 = yPlus;
            tx7 = 0;
            ty7 = 1;
            
            x8 = xPlus;
            y8 = yPlus;
            tx8 = 1;
            ty8 = 1;
            
            
        }
        
        
    }
    else
    {
        
        //高顶到边
        xMinus = yMinus*_imageWidth/(_imageHeight+tempValue*kStretchMax_h)/screenRatio;
        xPlus = yPlus*_imageWidth/(_imageHeight+tempValue*kStretchMax_h)/screenRatio;
        //原来的比例
        float originX = yMinus*imageRatio/screenRatio;
        
        x1 = xMinus;
        y1 = yMinus;
        tx1 = 0;
        ty1 = 0;
        
        x2 = xPlus;
        y2 = yMinus;
        tx2 = 1;
        ty2 = 0;
        
        //原来的高
        CGFloat h = ABS(1-2*_maxValue + 1) *xMinus/originX;
        
        x3 = xMinus;
        y3 = -(1.0-h);
        tx3 = 0;
        ty3 = (1-_maxValue);
        
        
        x4 = xPlus;
        y4 = -(1.0-h);
        tx4 = 1;
        ty4 = (1-_maxValue);
        
        
        x5 = xMinus;
        y5 = (1-2*_minValue*xMinus/originX);
        tx5 = 0;
        ty5 = (1-_minValue);
        
        
        x6 = xPlus;
        y6 = (1-2*_minValue*xMinus/originX);
        tx6 = 1;
        ty6 = (1-_minValue);
        
        x7 = xMinus;
        y7 = yPlus;
        tx7 = 0;
        ty7 = 1;
        
        x8 = xPlus;
        y8 = yPlus;
        tx8 = 1;
        ty8 = 1;
    }
    
    
    squareVertexes[0] = x1;
    squareVertexes[1] = -y1;
    
    squareVertexes[2] = x2;
    squareVertexes[3] = -y2;
    
    squareVertexes[4] = x3;
    squareVertexes[5] = -y3;
    
    squareVertexes[6] = x4;
    squareVertexes[7] = -y4;
    
    squareVertexes[8] = x5;
    squareVertexes[9] = -y5;
    
    squareVertexes[10] = x6;
    squareVertexes[11] = -y6;
    
    squareVertexes[12] = x7;
    squareVertexes[13] = -y7;
    
    squareVertexes[14] = x8;
    squareVertexes[15] = -y8;
    
    textureCoordinates[0] = tx1;
    textureCoordinates[1] = 1-ty1;
    
    textureCoordinates[2] = tx2;
    textureCoordinates[3] = 1-ty2;
    
    textureCoordinates[4] = tx3;
    textureCoordinates[5] = 1-ty3;
    
    textureCoordinates[6] = tx4;
    textureCoordinates[7] = 1-ty4;
    
    textureCoordinates[8] = tx5;
    textureCoordinates[9] = 1-ty5;
    
    textureCoordinates[10] = tx6;
    textureCoordinates[11] = 1-ty6;
    
    textureCoordinates[12] = tx7;
    textureCoordinates[13] = 1-ty7;
    
    textureCoordinates[14] = tx8;
    textureCoordinates[15] = 1-ty8;

}

#pragma mark 配置水平方向上面的顶点数据
- (void )horizontalConfigVertex
{
    float imageRatio = (float)self.imageWidth/self.imageHeight;
    float screenRatio = self.screenRatio;
    float xfactor=1.0;
    float yfactor=1.0;
    
    float tempValue = self.changValue;
    //负值
    float xMinus = -xfactor;
    float yMinus = -yfactor;
    
    //正值
    float xPlus = xfactor;
    float yPlus = yfactor;
    
    float x1,x2,x3,x4,x5,x6,x7,x8 = 0.0;
    float y1,y2,y3,y4,y5,y6,y7,y8 = 0.0;
    float tx1,tx2,tx3,tx4,tx5,tx6,tx7,tx8 = 0.0;
    float ty1,ty2,ty3,ty4,ty5,ty6,ty7,ty8 = 0.0;
    
    //压缩最大的值域区间的80%
    float compressMaxValue = (_maxValue - _minValue)*_imageWidth*kCompress_ratio;
    
    if (imageRatio > screenRatio) {
        
        //宽顶到边
        yMinus = xMinus*screenRatio/imageRatio;
        yPlus = xPlus*screenRatio/imageRatio;
                
        //改变的比例
        float neW_xMinus = yMinus*((self.imageWidth-compressMaxValue*tempValue)/self.imageHeight)/screenRatio;
        //改变的值
        float w = ABS(xMinus - neW_xMinus);
        
        x1 = xMinus+w;
        y1 = yMinus;
        tx1 = 0;
        ty1 = 0;
        
        x2 = xMinus+w;
        y2 = yPlus;
        tx2 = 0;
        ty2 = 1;
        
        x3 = (1-2*_minValue)/xMinus+w;
        y3 = yMinus;
        tx3 = _minValue;
        ty3 = 0;
        
        x4 = (1-2*_minValue)/xMinus+w;
        y4 = yPlus;
        tx4 = _minValue;
        ty4 = 1;
        
        x5 =  (1-2*_maxValue)/xMinus-w;
        y5 = yMinus;
        tx5 = _maxValue;
        ty5 = 0;
        
        
        x6 = (1-2*_maxValue)/xMinus-w;
        y6 = yPlus;
        tx6 = _maxValue;
        ty6 = 1;
        
        x7 = xPlus-w;
        y7 = yMinus;
        tx7 = 1;
        ty7 = 0;
        
        x8 = xPlus-w;
        y8 = yPlus;
        tx8 = 1;
        ty8 = 1;
    }
    else
    {
        
        
        xMinus = yMinus*((_imageWidth+tempValue*compressMaxValue*-1)/_imageHeight)/screenRatio;
        xPlus = yPlus*((_imageWidth+tempValue*compressMaxValue*-1)/_imageHeight)/screenRatio;
        //        NSLog(@"高顶到边");
        //原来的比例
        float originX = yPlus*imageRatio/screenRatio;
        float w = originX - xPlus;
        //高大于宽
        x1 = xMinus;
        y1 = yMinus;
        tx1 = 0;
        ty1 = 0;
        
        x2 = xMinus;
        y2 = yPlus;
        tx2 = 0;
        ty2 = 1;
        
        x3 = -(1-2*_minValue)*originX+w;
        y3 = yMinus;
        tx3 = _minValue;
        ty3 = 0;
        
        x4 = -(1-2*_minValue)*originX+w;
        y4 = yPlus;
        tx4 = _minValue;
        ty4 = 1;
        
        x5 = -(1-2*_maxValue)*originX-w;
        y5 = yMinus;
        tx5 = _maxValue;
        ty5 = 0;
        
        x6 = -(1-2*_maxValue)*originX-w;
        y6 = yPlus;
        tx6 = _maxValue;
        ty6 = 1;
        
        x7 = xPlus;
        y7 = yMinus;
        tx7 = 1;
        ty7 = 0;
        
        x8 = xPlus;
        y8 = yPlus;
        tx8 = 1;
        ty8 = 1;
    }
    
    squareVertexes[0] = x1;
    squareVertexes[1] = y1;
    
    squareVertexes[2] = x2;
    squareVertexes[3] = y2;
    
    squareVertexes[4] = x3;
    squareVertexes[5] = y3;
    
    squareVertexes[6] = x4;
    squareVertexes[7] = y4;
    
    squareVertexes[8] = x5;
    squareVertexes[9] = y5;
    
    squareVertexes[10] = x6;
    squareVertexes[11] = y6;
    
    squareVertexes[12] = x7;
    squareVertexes[13] = y7;
    
    squareVertexes[14] = x8;
    squareVertexes[15] = y8;
    
    textureCoordinates[0] = tx1;
    textureCoordinates[1] = ty1;
    
    textureCoordinates[2] = tx2;
    textureCoordinates[3] = ty2;
    
    textureCoordinates[4] = tx3;
    textureCoordinates[5] = ty3;
    
    textureCoordinates[6] = tx4;
    textureCoordinates[7] = ty4;
    
    textureCoordinates[8] = tx5;
    textureCoordinates[9] = ty5;
    
    textureCoordinates[10] = tx6;
    textureCoordinates[11] = ty6;
    
    textureCoordinates[12] = tx7;
    textureCoordinates[13] = ty7;
    
    textureCoordinates[14] = tx8;
    textureCoordinates[15] = ty8;
    
}



- (void)changeValue:(float)value
{
    self.changValue = value;
    if (_type == 0)
    {
        //增高
         [self verticalConfigVertex];
    }
    else
    {
        //瘦身
         [self horizontalConfigVertex];
    }
}

- (void)getVerticesAndTextureCoordinatesHandle:(GetVerticesAndTextureCoordinatesHandle)result
{
    
    if (result) {
        
        NSMutableArray *squareVertexeArray = [NSMutableArray array];
        NSMutableArray *textureCoordinatesArray = [NSMutableArray array];
        
        float changeValue = 0.0;
        
        if (_type==0)
        {
            NSLog(@"增高");
            //增高
            for (int i=0; i!=16; i++)
            {
                float value = squareVertexes[i];
                float yNormaliValue = ABS(squareVertexes[1])*1.0;
                if (i%2==0)
                {
                    //x 坐标
                    if (i == 0 || i == 4 || i == 8 || i == 12) {
                        value = -1.0;
                    }
                    else
                    {
                        value = 1.0;
                    }
                }
                else
                {
                    //y坐标
                    value = value/yNormaliValue;
                }
                squareVertexeArray[i] = [NSNumber numberWithDouble:value];
            }
            
            
            for (int i=0; i!=16; i++) {
                float value = textureCoordinates[i];
                textureCoordinatesArray[i] = [NSNumber numberWithDouble:value];
            }

            changeValue = kStretchMaxRatio*self.changValue;
        }
        else
        {
            //瘦身
            NSLog(@"瘦身");
            for (int i=0; i!=16; i++)
            {
                float value = squareVertexes[i];
                float xNormaliValue = ABS(squareVertexes[0])*1.0;
                float yNormaliValue = ABS(squareVertexes[1])*1.0;
                if (i%2==0)
                {
                    //x坐标
                    value = value/xNormaliValue;
                }
                else
                {
                    //y坐标
                    value = value/yNormaliValue;
                }
                squareVertexeArray[i] = [NSNumber numberWithDouble:value];
            }

            
            for (int i=0; i!=16; i++) {
                float value = textureCoordinates[i];
                textureCoordinatesArray[i] = [NSNumber numberWithDouble:value];
            }
            
            float compressMaxValue = (_maxValue - _minValue)*_imageWidth*kCompress_ratio*self.changValue;
            changeValue = compressMaxValue/_imageWidth*(-1.0);
        }
        
        result(squareVertexeArray,textureCoordinatesArray,changeValue,_type);
    }
    
}

- (void)dealloc
{
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    NSLog(@"GLImageShapeFilter---dealloc");
}



@end
