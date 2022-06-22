//MHStickersView.h
//贴纸UI


#import <UIKit/UIKit.h>
@class StickerDataListModel;
NS_ASSUME_NONNULL_BEGIN
@protocol MHStickersViewDelegate <NSObject>
@required
- (void)handleStickerEffect:(NSString *)stickerContent sticker:(StickerDataListModel *)model;
/// 照相按钮
- (void)takePhoto;
- (void)clickPackUp;
@end
@interface MHStickersView : UIView
@property (nonatomic, weak) id<MHStickersViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *array;

- (void)configureStickers:(NSArray *)arr;

- (void)configureStickerTypes;
@end

NS_ASSUME_NONNULL_END
