//
//  GPUImageBeautifyFilter.m
//  MagicCamera
//
//  Created by mkil on 2019/9/4.
//  Copyright © 2019 黎宁康. All rights reserved.
//

#import "GPUImageBeautifyFilter.h"
#import <GPUImage/GPUImage.h>

@interface GPUImageCombinationFilter : GPUImageThreeInputFilter
{
    GLint buffingDegreeUniform;
}

@property (nonatomic, assign) CGFloat intensity;

@end

NSString *const kGPUImageCombinationFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 
 uniform mediump float buffingDegree;
 
 void main()
 {
     // 双边滤波
     highp vec4 bilateral = texture2D(inputImageTexture, textureCoordinate);
     // 边缘检测
     highp vec4 canny = texture2D(inputImageTexture2, textureCoordinate2);
     // 原图
     highp vec4 source = texture2D(inputImageTexture3,textureCoordinate3);
     
     //高反差保留算法 (原图 - 高斯模糊图 注:双边代替高斯)
     highp vec4 highPass = source - bilateral;
     
     // 强光处理 color = 2 * color1 * color2
     mediump float intensity = 24.0;   // 强光程度
     highPass.r = clamp(2.0 * highPass.r * highPass.r * intensity,0.0,1.0);
     highPass.g = clamp(2.0 * highPass.g * highPass.g * intensity,0.0,1.0);
     highPass.b = clamp(2.0 * highPass.b * highPass.b * intensity,0.0,1.0);
     
     // 融合 -> 磨皮
     // 蓝色通道
     mediump float value = clamp((min(source.b, bilateral.b) - 0.2) * 5.0, 0.0, 1.0);
     // RGB 的最大值
     mediump float maxChannelColor = max(max(highPass.r, highPass.g), highPass.b);
     // 磨皮程度
     mediump float currentIntensity = (1.0 - maxChannelColor / (maxChannelColor + 0.2)) * value * buffingDegree;
     // 混合
     // mix = x⋅(1−a)+y⋅a
     highp vec4 fuse = vec4(mix(source.rgb,bilateral.rgb,currentIntensity), 1.0);
     
     //精准磨皮 
     lowp float r = source.r;
     lowp float g = source.g;
     lowp float b = source.b;
     
     highp vec4 result;
     
     if (canny.r < 0.2 && r > 0.3725 && g > 0.1568 && b > 0.0784 && r > b && (max(max(r, g), b) - min(min(r, g), b)) > 0.0588 && abs(r-g) > 0.0588) {
         result = fuse;
     } else {
         result = source;
     }
     
     gl_FragColor = result;
 }
 );


@implementation GPUImageCombinationFilter

- (id)init {
    if (self = [super initWithFragmentShaderFromString:kGPUImageCombinationFragmentShaderString]) {
        buffingDegreeUniform = [filterProgram uniformIndex:@"buffingDegree"];
    }
    self.intensity = 0.5;
    return self;
}

- (void)setIntensity:(CGFloat)intensity {
    _intensity = intensity;
    [self setFloat:intensity forUniform:buffingDegreeUniform program:filterProgram];
}

@end

@interface GPUImageBeautifyFilter()
{
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageUnsharpMaskFilter *usmFilter;
    GPUImageHSBFilter *hsbFilter;
}

@end

@implementation GPUImageBeautifyFilter

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    // 双边模糊
    bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    bilateralFilter.distanceNormalizationFactor = 3.5;
    [self addFilter:bilateralFilter];
    
    // Canny边缘检测
    cannyEdgeFilter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    [self addFilter:cannyEdgeFilter];
    
    // 磨皮 -> 融合
    combinationFilter = [[GPUImageCombinationFilter alloc] init];
    combinationFilter.intensity = 0.9;
    [self addFilter:combinationFilter];
    
    // USM锐化
    usmFilter = [[GPUImageUnsharpMaskFilter alloc] init];
    usmFilter.intensity = 0.8;
    
    // 调整 HSB
    hsbFilter = [[GPUImageHSBFilter alloc] init];
    [hsbFilter adjustBrightness:1.1];
    [hsbFilter adjustSaturation:1.1];
    
    [bilateralFilter addTarget:combinationFilter];
    [cannyEdgeFilter addTarget:combinationFilter];
    
    [combinationFilter addTarget:usmFilter];
    [usmFilter addTarget:hsbFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:bilateralFilter,cannyEdgeFilter,combinationFilter,nil];
    self.terminalFilter = hsbFilter;
    
    return self;
}

- (void)setIntensity:(CGFloat)intensity
{
    _intensity = intensity;
    combinationFilter.intensity = intensity;
}

#pragma mark -
#pragma mark GPUImageInput protocol

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    for (GPUImageOutput<GPUImageInput> *currentFilter in self.initialFilters)
    {
        if (currentFilter != self.inputFilterToIgnoreForUpdates)
        {
            if (currentFilter == combinationFilter) {
                textureIndex = 2;
            }
            [currentFilter newFrameReadyAtTime:frameTime atIndex:textureIndex];
        }
    }
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    for (GPUImageOutput<GPUImageInput> *currentFilter in self.initialFilters)
    {
        if (currentFilter == combinationFilter) {
            textureIndex = 2;
        }
        [currentFilter setInputFramebuffer:newInputFramebuffer atIndex:textureIndex];
    }
}

@end
