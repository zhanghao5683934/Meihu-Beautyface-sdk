//
//  MHMeiyanMenusView.h


#import <UIKit/UIKit.h>
#import "MHOpenSourceViewController.h"
NS_ASSUME_NONNULL_BEGIN
@protocol MHMeiyanMenusViewDelegate <NSObject>
@required


///**
// 
//美颜
// @param beauty 磨皮 0-9，数值越大，效果越明显
// @param white 美白 0-9，数值越大，效果越明显
// @param ruddiness 红润 0-9，数值越大，效果越明显
// */
//- (void)beautyEffectWithLevel:(NSInteger)beauty whitenessLevel:(NSInteger)white ruddinessLevel:(NSInteger)ruddiness;
- (void)cameraAction;
//短视频录制按键回调
- (void)recordAction;
@end
@interface MHMeiyanMenusView : UIView

/// 初始化美颜菜单
/// @param frame frame
/// @param superView 所要添加到的视图
/// @param delegate 代理
/// @param manager  美颜管理器，完成初始化后传入
/// @param isTx 是否是腾讯直播SDK，YES：是，NO：其他直播SDK

- (instancetype)initWithFrame:(CGRect)frame superView:(UIView *)superView delegate:(id<MHMeiyanMenusViewDelegate>)delegate viewController:(MHOpenSourceViewController*)vc isTXSDK:(BOOL)isTx;

@property (nonatomic, weak) id<MHMeiyanMenusViewDelegate> delegate;

@property (nonatomic, strong) MHOpenSourceViewController * mRender;
/**
 控制美颜菜单显示

 @param show YES表示显示，NO表示隐藏
 */
- (void)showMenuView:(BOOL)show;

/**
 获取当前美颜菜单显示状态，YES：显示，NO：隐藏
 */
@property (nonatomic, assign,getter=isShow) BOOL show;

/**
是否是腾讯直播SDK，YES：是，NO：其他直播SDK
*/

@property (nonatomic, assign) BOOL isTX;

/*
 美狐sdk底部选项框内容信息数组
 */
@property (nonatomic, strong) NSMutableArray *array;

/*
 是否隐藏除拍摄按钮外的其他按钮
 */
- (void)showMenusWithoutRecord:(BOOL)show;

///设置默认美型或者美颜数据，供外部调用，需要在m文件的该方法中完善数据
/// @param isTX 是否是腾讯SDK
- (void)setupDefaultBeautyAndFaceValueWithIsTX:(BOOL)isTX;
- (void)animationOfTakingPhoto;
@end

NS_ASSUME_NONNULL_END
