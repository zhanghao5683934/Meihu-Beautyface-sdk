//MHBeautyView

//美颜UI

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MHBeautyViewDelegate <NSObject>
@required

/**
 美颜

 @param beautyType 美颜类型，详情见MHFiltersContants.h
 @param value 美颜参数
 */
- (void)handleBeautyEffects:(NSInteger)beautyType sliderValue:(NSInteger)value;
@end
@interface MHBeautyView : UIView
@property (nonatomic, weak) id<MHBeautyViewDelegate> delegate;


/**
 选中一键美颜功能的后，取消美颜选中状态
 
 @param type 选中的美颜类型
 */
- (void)cancelSelectedBeautyType:(NSInteger)type;

/**
 获取当前选中的类型索引
 */
- (NSInteger)currentIndex;

@end

NS_ASSUME_NONNULL_END
