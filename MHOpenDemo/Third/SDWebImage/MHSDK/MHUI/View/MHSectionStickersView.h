//MHSectionStickersView.h
//单个分类的贴纸

#import <UIKit/UIKit.h>
@class StickerDataListModel;
NS_ASSUME_NONNULL_BEGIN
@protocol MHSectionStickersViewDelegate <NSObject>
- (void)handleSelectedStickerEffect:(NSString *)stickerContent stickerModel:(StickerDataListModel *)model;
- (void)reloadLastStickerSelectedStatus:(BOOL)needReset;
@end


@interface MHSectionStickersView : UIView
@property (nonatomic, strong) NSMutableArray *stickersArray;
@property (nonatomic, assign) NSInteger stickerTag;
@property (nonatomic, weak) id<MHSectionStickersViewDelegate> delegate;
@property (nonatomic, assign) NSInteger lastTag;
@property (nonatomic, assign) NSInteger lastIndex;
@property (nonatomic, strong) UICollectionView *collectionView;

- (void)configureData:(NSArray *)stickersArray;

@end

NS_ASSUME_NONNULL_END
