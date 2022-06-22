//
//  MHBeautyMenuCell.h


#import <UIKit/UIKit.h>
@class MHBeautiesModel;
NS_ASSUME_NONNULL_BEGIN

@interface MHBeautyMenuCell : UICollectionViewCell

@property (nonatomic, strong) MHBeautiesModel *menuModel;
@property (nonatomic, assign) BOOL isSimplification;///<精简版
- (void)switchBeautyEffect:(BOOL)isSelected;
- (void)takePhotoAnimation;
- (void)changeRecordState:(BOOL)isRecording;
@end

NS_ASSUME_NONNULL_END
