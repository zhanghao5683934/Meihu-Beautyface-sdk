//
//  MHFiltersView.h
//滤镜UI

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MHFiltersViewDelegate <NSObject>
@required
- (void)handleFiltersEffect:(NSInteger)filterType filterName:(NSString *)filtetName;

@end
@interface MHFiltersView : UIView
@property (nonatomic, weak) id<MHFiltersViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
