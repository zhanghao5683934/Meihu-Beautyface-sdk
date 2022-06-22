//
//  WNSegmentItem.h


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^YCSegmentTopViewUpdate)(UIView *topView);

@interface WNSegmentItem : UIView

@property (nonatomic, weak) UILabel * _Nullable label;
@property (nonatomic, weak) UIImageView * _Nullable imageView;
@property (nonatomic, weak) UIView *view;

- (instancetype)initWithView:(UIView *)view;
- (void)showVerticalDivider;
- (void)hideVerticalDivider;
- (void)addTipView:(UIView *)tipView;

@end

NS_ASSUME_NONNULL_END
