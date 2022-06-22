//
//  MKLandmarkManager.m
//  MagicCamera
//
//  Created by mkil on 2019/9/4.
//  Copyright © 2019 黎宁康. All rights reserved.
//

#import "MKLandmarkManager.h"
#import "MKFaceBaseData.h"
#import "MKTool.h"

#import "MGFaceLicenseHandle.h"

NSString * _Nullable const MKLandmarkAuthorizationNotificationName = @"MKLandmarkAuthorizationActivateNotificationName";

static MKLandmarkManager *manager = nil;

@implementation MKLandmarkManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (void)faceLicenseAuthorization {
    /*
     *  授权和摄像头采集同时进行时会报错(具体原因未知)
     *  错误信息: [AGXA11FamilyCommandBuffer renderCommandEncoderWithDescriptor:], line 114: error 'A command encoder is already encoding to this command buffer
     *
     */
    [MGFaceLicenseHandle licenseForNetwokrFinish:^(bool License, NSDate *sdkDate) {
        if (!License) {
            NSLog(@"联网授权失败!!");
            self.isAuthorization = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:MKLandmarkAuthorizationNotificationName object:nil userInfo:@{@"isActivate":@"0"}];
        } else {
            NSLog(@"联网授权成功");
            self.isAuthorization = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:MKLandmarkAuthorizationNotificationName object:nil userInfo:@{@"isActivate":@"1"}];
        }
    }];
}

-(void)setFaceData:(NSArray *)faceData
{
    _faceData = nil;
    if (faceData) {
        NSMutableArray *datas = [NSMutableArray arrayWithCapacity:1];
        for (int i = 0; i < faceData.count; i ++) {
            ((MGFaceInfo *)faceData[i]).points = [self conversionCoordinatePoint:((MGFaceInfo *)faceData[i]).points];
            [datas addObject:[[MKFaceInfo alloc] initWithInfo:faceData[i]]];
        }
        _faceData = datas;
    }
}

// 像素坐标点转换成位置坐标
-(NSArray<NSValue *> *)conversionCoordinatePoint:(NSArray<NSValue *> *)pixelPoints
{
    NSMutableArray<NSValue *> *points = [NSMutableArray arrayWithCapacity:106];

    for (int i = 0; i < pixelPoints.count; i ++) {
        CGPoint pointer = [pixelPoints[i] CGPointValue];
        CGPoint point = CGPointMake([self changeToGLPointX:pointer.x], [self changeToGLPointY:pointer.y]);
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    
    return points;
}

- (GLfloat)changeToGLPointX:(CGFloat)x{
    GLfloat tempX = (x - _detectionWidth/2) / (_detectionWidth/2);
    return tempX;
}
- (GLfloat)changeToGLPointY:(CGFloat)y{
    GLfloat tempY = (_detectionHeight/2 - (_detectionHeight - y)) / (_detectionHeight/2);
    return tempY;
}

@end

@implementation MKFaceInfo

-(id)initWithInfo:(MGFaceInfo *)info
{
    self = [super init];
    if (self) {
        self.trackID = info.trackID;
        self.index = info.index;
        self.rect = info.rect;
        self.points = info.points;
        self.pitch = info.pitch;
        self.yaw = info.yaw;
        self.roll = info.roll;
    }
    return self;
}


@end
