//
//  MHBeautyParams.h


#ifndef MHBeautyParams_h
#define MHBeautyParams_h
//#import "UIView+Additions.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , MHBeautyAssembleType) {
    MHBeautyAssembleType_Beauty = 0,//美颜
    MHBeautyAssembleType_Face = 1,//美型
    MHBeautyAssembleType_CompleteBeauty = 2,//一键美颜
};

typedef NS_ENUM(NSInteger, MHBeautyType) {
    MHBeautyType_Original = 0,//原图
    MHBeautyType_White = 1,//美白
    MHBeautyType_Mopi = 2,//磨皮
    MHBeautyType_Ruddiess = 3, //红润
    MHBeautyType_Brightness = 4 // 亮度
    
};

typedef NS_ENUM(NSInteger,MHBeautyFaceType) {
    MHBeautyFaceType_Original = 0,//原图
    MHBeautyFaceType_BigEyes = 1,//大眼
    MHBeautyFaceType_ThinFace = 2,//瘦脸
    MHBeautyFaceType_Mouth,//嘴型
    MHBeautyFaceType_Nose,//鼻子
    MHBeautyFaceType_Chin,//下巴
    MHBeautyFaceType_Forehead,//额头
    MHBeautyFaceType_Eyebrow,//眉毛
    MHBeautyFaceType_Canthus,//眼角
    MHBeautyFaceType_EyeDistance,//眼距
    MHBeautyFaceType_EyeAlae,//开眼角
    MHBeautyFaceType_ShaveFace,//削脸
    MHBeautyFaceType_LongNose//长鼻
};
///修改MHUI
static const BOOL isNeedBottom = NO;
//各个子view的frame值
static const CGFloat MHMeiyanMenuHeight = 139.f;
static const CGFloat MHMeiyanMenusCellHeight = 90.f;
static const CGFloat MHBeautyViewHeight = 140.f;
static const CGFloat MHFaceViewHeight = 140.f;
static const CGFloat MHStickersViewHeight = 250.f;
static const CGFloat MHFiltersViewHeight = 140.f;
///原来是80
static const CGFloat MHFilterCellHeight = 100.f;
static const CGFloat MHFilterItemColumn = 6;
static const CGFloat MHStickerItemWidth = 55;
static const CGFloat MHStickerItemHeight = 55;
static const CGFloat MHStickerSectionHeight = 40;
///修改MHUI
static const CGFloat MHBottomViewHeight = isNeedBottom?70.f:0.0f;
static const CGFloat MHBottomViewHeight1 = 70.f;
///修改MHUI 原来是120
static const CGFloat MHMagnifyViewHeight = isNeedBottom?250.f:250.f-MHBottomViewHeight1;
static const CGFloat MHSpecificCellHeight = 100.f;
static const CGFloat MHSpecificViewHeight = 140.f;

///修改MHUI 原来是260.5
static const CGFloat MHBeautyAssembleViewHeight = isNeedBottom?330.5f:330.5f-MHBottomViewHeight1;
///修改MHUI 原来是180
static const CGFloat MHSpecificAssembleViewHeight = isNeedBottom?250.f:250.f-MHBottomViewHeight1;
static const CGFloat MHSliderwHeight = 50.f;
static const CGFloat MHSliderwTop = 10.f;
///修改MHUI 透明度属性取值
static const CGFloat MHAlpha = 0.8f;
static const CGFloat MHBlackAlpha = 0.5f;
#define  window_width  [UIScreen mainScreen].bounds.size.width
#define  window_height [UIScreen mainScreen].bounds.size.height

#define ImageBundlePath [[NSBundle mainBundle] pathForResource:@"MHSDK" ofType:@"bundle"]
#define Bundle [NSBundle bundleWithPath:ImageBundlePath]
#define BundleImg(Name) [UIImage imageNamed:Name inBundle:Bundle compatibleWithTraitCollection:nil];
#define FontColorNormal [UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1]
///修改MHUI 黑色模式下字体颜色
#define FontColorBlackNormal [UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:1]
#define FontColorSelected [UIColor colorWithRed:255/255.f green:85/255.f blue:10/255.f alpha:1]
///修改MHUI 原来是240
#define LineColor [UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:0.2]
#define Font_12 [UIFont systemFontOfSize:12]
#define Font_10 [UIFont systemFontOfSize:10]

#define iPhoneX (window_width== 375.f && window_height == 812.f)||(window_width== 414.f && window_height == 896.f)
#define BottomIndicatorHeight (iPhoneX ? 34: 0)

#define IsString(__string) ([(__string) isKindOfClass:[NSString class]])
#define IsStringWithAnyText(__string) (IsString(__string) && ([((NSString *)__string) length] > 0) && (![(__string) isKindOfClass:[NSNull class]]) && (![(__string) isEqualToString:@"(null)"]))
//#define IsNullString(__string) (IsString(__string) && ([((NSString *)__string) length] == 0) && (![(__string) isKindOfClass:[NSNull class]]) && (![(NSString *)__string) isEqualToString:@"(null)"])

#define IsArray(__array) ([(__array) isKindOfClass:[NSArray class]])
#define IsArrayWithAnyItem(__array) (IsArray(__array) && ([((NSArray *)__array) count] > 0))

#define IsDictionary(__dict) ([(__dict) isKindOfClass:[NSDictionary class]])
#define IsDictionaryWithAnyKeyValue(__dict) (IsDictionary(__dict) && ([[((NSDictionary *)__dict) allKeys] count] > 0))

#endif /* MHBeautyParams_h */
