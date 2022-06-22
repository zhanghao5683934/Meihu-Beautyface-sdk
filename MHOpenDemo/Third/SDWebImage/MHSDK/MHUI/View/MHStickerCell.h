//
//  MHStickerCell.h

#import <UIKit/UIKit.h>
@class StickerDataListModel;
NS_ASSUME_NONNULL_BEGIN

@interface MHStickerIndicatorView : UIView

- (id)initWithTintColor:(UIColor *)tintColor size:(CGFloat)size;

@property(nonatomic, strong) UIColor *tintColor;
@property(nonatomic) CGFloat size;

@property(nonatomic, readonly) BOOL animating;

- (void)startAnimating;

- (void)stopAnimating;

@end


@interface MHStickerCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *selectedImgView;
@property (nonatomic, strong) UIImageView *downloadImg;
@property (nonatomic, strong) StickerDataListModel *listModel;

- (void)setSticker:(StickerDataListModel *)sticker index:(NSInteger)index;

- (void)startDownload;

- (void)stopDownLoad;

@end

NS_ASSUME_NONNULL_END
