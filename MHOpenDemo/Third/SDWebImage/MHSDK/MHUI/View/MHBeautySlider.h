//
//  MHBeautySlider.h
// 自定义Slider控件，显示滑动数值

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHBeautySlider : UISlider
@property (nonatomic, copy) NSString *sliderValue;
@property (nonatomic, strong) UIFont *sliderFont;
@property (nonatomic, strong) UIColor *valueColor;
@property (nonatomic, copy) void(^touchDown)(MHBeautySlider *slider);
@property (nonatomic, copy) void(^valueChanged)(MHBeautySlider *slider);
@property (nonatomic, copy) void(^touchUpInside)(MHBeautySlider *slider);

@end

NS_ASSUME_NONNULL_END
