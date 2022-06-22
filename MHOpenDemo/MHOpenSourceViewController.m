//
//  MHOpenSourceViewController.m
//  MHOpenDemo
//
//  Created by Apple on 2021/5/31.
//

#import "MHOpenSourceViewController.h"
#import <GPURenderKit/GPURenderKit.h>
#import "MGFaceLicenseHandle.h"
#import "MGFacepp.h"
#import "MHMeiyanMenusView.h"
#import "MHBeautyParams.h"
#import "BBGPUImageBeautifyFilter.h"

@interface MHOpenSourceViewController ()<GPUImageVideoCameraDelegate,MHMeiyanMenusViewDelegate>
@property (nonatomic, strong) MGFacepp *markManager;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *preview;
@property (nonatomic, strong) BBGPUImageBeautifyFilter *beautifyFilter;
@property (nonatomic, strong) GLImageFaceChangeFilterGroup *faceChangeFilterGroup;
@property (nonatomic, strong) GPUImageSketchFilter *sketchFilter;

@property (nonatomic, strong) GPUImageVignetteFilter  * vignetteFilter ;
@property (nonatomic, strong) MHMeiyanMenusView *menusView;
@property (nonatomic, strong) UIButton *rotateBtn;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;
@property (nonatomic, assign) BOOL faceServiceBool;
@property (nonatomic, assign) BOOL takePhone;
@end

@implementation MHOpenSourceViewController

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  
    [_menusView showMenuView:YES];
}



- (MHMeiyanMenusView *)menusView {
    if (!_menusView) {
        _menusView = [[MHMeiyanMenusView alloc] initWithFrame:CGRectMake(0, window_height - MHMeiyanMenuHeight - BottomIndicatorHeight, window_width, MHMeiyanMenuHeight)
                                                superView:self.view
                                                     delegate:self  viewController:self isTXSDK:NO];
       
    }
    return _menusView;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    [self checkFaceServiceBlock:^(BOOL results) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.faceServiceBool = results;
            if (results) {
                [self configFaceMarkManager];
                [self setupFaceConfig];
            }else{
                NSLog(@"授权未通过，未能开启人脸关键点识别服务。");
                [self setupNoFaceConfig];
            }
        });
    }];
    _takePhone = NO;
    [self.view addSubview:self.menusView];
    

}

- (void)checkFaceServiceBlock:(void(^)(BOOL results))block{
    
    /** 进行联网授权版本判断，联网授权就需要进行网络授权 */
    BOOL needLicense = [MGFaceLicenseHandle getNeedNetLicense];
    if (needLicense) {
        [MGFaceLicenseHandle licenseForNetwokrFinish:^(bool License, NSDate *sdkDate) {
            if (!License) {
                NSLog(@"联网授权失败 ！！！");
                if (block) {
                    block(NO);
                }
            } else {
                NSLog(@"联网授权成功");
                if (block) {
                    block(YES);
                }
            }
        }];
        
    } else {
        NSLog(@"SDK 为非联网授权版本！");
        if (block) {
            block(NO);
        }
    }
}

- (void)setupFaceConfig{
    
    //添加瘦脸，大眼filter
    self.faceChangeFilterGroup = [[GLImageFaceChangeFilterGroup alloc]init];
    self.faceChangeFilterGroup.isShowFaceDetectPointBool = NO;
    [self.faceChangeFilterGroup setCaptureDevicePosition:self.videoCamera.cameraPosition];
    [self.faceChangeFilterGroup addTarget:self.preview];
    [self.beautifyFilter addTarget:self.faceChangeFilterGroup];
    [self.vignetteFilter addTarget:self.beautifyFilter];
    [self.videoCamera addTarget:self.beautifyFilter];
    
    [self rotateBtn];
    [self switchView];
    [self backBtn];
    [self.view bringSubviewToFront:self.menusView];
    
}

- (void)setupNoFaceConfig{
    
    
    [self.beautifyFilter addTarget:self.preview];
    [self.videoCamera addTarget:self.beautifyFilter];
    
    
    [self rotateBtn];
}



- (void)configFaceMarkManager{
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGFACEMODELNAME ofType:@""];
    NSData *modelData = [NSData dataWithContentsOfFile:modelPath];
    
    int maxFaceCount = 0;
    int faceSize = 100;
    int internal = 40;

    MGDetectROI detectROI = MGDetectROIMake(0, 0, 0, 0);

    self.markManager = [[MGFacepp alloc] initWithModel:modelData
                                               maxFaceCount:maxFaceCount
                                              faceppSetting:^(MGFaceppConfig *config) {
                                                  config.minFaceSize = faceSize;
                                                  config.interval = internal;
                                                  config.orientation = 90;
                                                  config.detectionMode = MGFppDetectionModeTrackingFast;
                                                  config.detectROI = detectROI;
                                                  config.pixelFormatType = PixelFormatTypeNV21;
                                              }];
    
}

#pragma mark ------------------------------------------------------ lazy ------------------------------------------------------
- (GPUImageView *)preview{
    if (!_preview) {
        _preview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
        _preview.layer.contentsScale = 2.0;
        _preview.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [_preview setBackgroundColorRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        [self.view addSubview:_preview];
    }
    return _preview;
}

- (BBGPUImageBeautifyFilter *)beautifyFilter{
    if (!_beautifyFilter) {
        _beautifyFilter = [[BBGPUImageBeautifyFilter alloc]init];
        _beautifyFilter.intensity = 0.0;
    }
    return _beautifyFilter;
}

- (GPUImageSketchFilter *)sketchFilter{
    if (!_sketchFilter) {
        _sketchFilter = [[GPUImageSketchFilter alloc] init];
    }
    return _sketchFilter;
}

- (GPUImageVignetteFilter*)vignetteFilter{
    if (!_vignetteFilter) {
        _vignetteFilter = [[GPUImageVignetteFilter alloc] init];
        _vignetteFilter.vignetteStart = 0.3;
        _vignetteFilter.vignetteEnd = 0.75;
    }
    return _vignetteFilter;
}


- (GPUImageVideoCamera *)videoCamera
{
    if (!_videoCamera)
    {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.runBenchmark = NO;
        _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _videoCamera.delegate = self;
        self.devicePosition = _videoCamera.cameraPosition;
        [_videoCamera startCameraCapture];
    }
    
    return _videoCamera;
}

- (UIButton *)rotateBtn{
    if (!_rotateBtn) {
        _rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_rotateBtn];
        UIImage *image = [UIImage imageNamed:@"rotate"];
        _rotateBtn.frame = CGRectMake(kScreen_W - 1.5 *image.size.width, 100, image.size.width,image.size.height );
        [_rotateBtn setImage:image forState:UIControlStateNormal];
        [_rotateBtn addTarget:self action:@selector(rotateBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotateBtn;
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_backBtn];
        UIImage *image = [UIImage imageNamed:@"back"];
        _backBtn.frame = CGRectMake(20, 50, image.size.width,image.size.height );
        [_backBtn setImage:image forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

    
    
- (UISwitch *)switchView{
    if (!_switchView) {
        
        _switchView = [[UISwitch alloc] initWithFrame:CGRectMake(20, CGRectGetMinY(self.rotateBtn.frame), 51, 31)];
        _switchView.on = YES;
        [_switchView addTarget:self action:@selector(switchViewvalueChanged:) forControlEvents:(UIControlEventValueChanged)];
        [self.view addSubview:_switchView];
    }
    return _switchView;
}


- (void)backAction:(UIButton*)sender{
    [_videoCamera stopCameraCapture];
    [self removeAllObject];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

    
    
- (void)rotateBtnAction{
    [_videoCamera rotateCamera];
    self.devicePosition = _videoCamera.cameraPosition;
    
    if (self.faceServiceBool) {
        [self.faceChangeFilterGroup setCaptureDevicePosition:self.videoCamera.cameraPosition];
    }
    
}

/** 是否显示人脸检测关键点 */
- (void)switchViewvalueChanged:(UISwitch *)switchView{
    
    self.faceChangeFilterGroup.isShowFaceDetectPointBool = switchView.isOn;
}


#pragma mark ------------------------------------------------------ GPUImageVideoCameraDelegate ------------------------------------------------------
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{

    if (self.faceServiceBool) {
        if (self.markManager.status != MGMarkWorking) {
            [self detectSampleBuffer:sampleBuffer];
        }
    }else{
        NSLog(@"未能开启人脸检测");
    }
}


- (void)detectSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    MGImageData *imageData = [[MGImageData alloc] initWithSampleBuffer:sampleBuffer];
    [self.markManager beginDetectionFrame];

    NSArray *tempArray = [self.markManager detectWithImageData:imageData];
    NSUInteger faceCount = tempArray.count;
    if (faceCount == 0) {
        self.faceChangeFilterGroup.isHaveFace = NO;
        [self.faceChangeFilterGroup setFacePointsArray:@[]];
    }else{
        self.faceChangeFilterGroup.isHaveFace = YES;
    }
    NSLog(@"face Count : %zd",faceCount);
    for (MGFaceInfo *faceInfo in tempArray) {
        [self.markManager GetGetLandmark:faceInfo isSmooth:YES pointsNumber:106];
        [self.faceChangeFilterGroup setFacePointsArray:faceInfo.points];
    }
    [self.markManager endDetectionFrame];
}


#pragma mark ------------------------------------------------------ 清空所有数据 ------------------------------------------------------
- (void)removeAllObject{
    [_videoCamera stopCameraCapture];
    if (_faceChangeFilterGroup) {
        [_faceChangeFilterGroup removeAllTargets];
        _faceChangeFilterGroup = nil;
    }
    
    if (_beautifyFilter) {
        [_beautifyFilter removeAllTargets];
        _beautifyFilter = nil;
    }
    
    if (_preview) {
        _preview = nil;
    }
    
    if (_markManager) {
        _markManager = nil;
    }
}
#pragma mark -MHMeiyanMenusViewDelegate
- (void)cameraAction{
    _takePhone = YES;
}
    
#pragma mark - 属性赋值

- (void)setBeautyValue:(CGFloat)beautyValue{
    _beautyValue = beautyValue;
    self.beautifyFilter.intensity = beautyValue;
}
- (void)setWhithValue:(CGFloat)whithValue{
    _whithValue = whithValue;
    self.beautifyFilter.brightness = 1+whithValue/5.0;
}
- (void)setSaturationValue:(CGFloat)saturationValue{
    _saturationValue = saturationValue;
    self.beautifyFilter.saturation = 1+saturationValue;
}

- (void)setThinFaceValue:(CGFloat)thinFaceValue{
    _thinFaceValue = thinFaceValue;
    self.faceChangeFilterGroup.thinFaceParam = thinFaceValue/100.0;
}

- (void)setEyeValue:(CGFloat)eyeValue{
    _eyeValue = eyeValue;
    self.faceChangeFilterGroup.eyeParam = eyeValue/100.0;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
