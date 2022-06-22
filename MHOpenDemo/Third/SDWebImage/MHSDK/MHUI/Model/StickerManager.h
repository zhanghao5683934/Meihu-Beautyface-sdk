//
//  StickerManager.h


#import <Foundation/Foundation.h>



@class StickerDataListModel;
NS_ASSUME_NONNULL_BEGIN

@interface StickerManager : NSObject
+ (instancetype)sharedManager;

/**
 解析贴纸zip文件后存储地址
 */
@property (nonatomic, copy) NSString *unzipPath;

/**
 获取贴纸列表
 
 @param success 数据模型的数组
 */
-(void)requestStickersListWithUrl:(NSString *)url Success:(void (^)(NSArray<StickerDataListModel *>*stickerArray))success Failed:(void (^)(void))fail;

/**
 下载选中贴纸
 
 @param sticker StickerDataListModel 贴纸模型
 @param index 点击的indexPath.row
 @param success 成功回调
 @param failed 失败回调
 */
- (void)downloadSticker:(StickerDataListModel *)sticker index:(NSInteger)index withSuccessed:(void (^)(StickerDataListModel *sticker, NSInteger index))success failed:(void (^)(StickerDataListModel *sticker, NSInteger index))failed;

@end


NS_ASSUME_NONNULL_END

