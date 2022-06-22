
//  StickerListModel.h


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MHStickerDownloadState)
{
    MHStickerDownloadStateDownoadNot,//Not downloaded
    MHStickerDownloadStateDownoadDone,//Downloaded
    MHStickerDownloadStateDownoading,//downloading
};

@interface StickerDataListModel : NSObject
@property (nonatomic,copy) NSArray  *stickerList;
@property (nonatomic, assign) BOOL isSelected;//YES：选中显示边框
@property (nonatomic, copy) NSString *name;//贴纸名称
@property (nonatomic, copy) NSString *thumb;//缩略图
@property (nonatomic, copy) NSString *is_downloaded;//是否下载，YESL：已经下载
@property (nonatomic, copy) NSString *category;//扩展字段，暂时无用
@property (nonatomic, copy) NSString *resource;//贴纸下载链接
@property (nonatomic, copy) NSString *folderPath;//
@property (nonatomic, copy) NSString *uptime;//贴纸上传时间
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *beauty;//美型美颜参数，为空时不处理，0表示未设置
@property (nonatomic, assign) MHStickerDownloadState downloadState;//下载状态
/***************************美颜美型参数************************/
@property (nonatomic, copy) NSString *white;
@property (nonatomic, copy) NSString *mopi;
@property (nonatomic, copy) NSString *ruddies;
@property (nonatomic, copy) NSString *saturatio;
@property (nonatomic, copy) NSString *eye_brow;
@property (nonatomic, copy) NSString *big_eye;
@property (nonatomic, copy) NSString *eye_length;
@property (nonatomic, copy) NSString *eye_corner;
@property (nonatomic, copy) NSString *eye_alat;
@property (nonatomic, copy) NSString *face_lift;
@property (nonatomic, copy) NSString *face_shave;
@property (nonatomic, copy) NSString *mouse_lift ;
@property (nonatomic, copy) NSString *nose_lift;
@property (nonatomic, copy) NSString *chin_lift;
@property (nonatomic, copy) NSString *forehead_lift;
@property (nonatomic, copy) NSString *lengthen_noseLift;
+ (StickerDataListModel *)mh_modelWithData:(NSDictionary *)data;

@end

