//
//  MHFilterModel.h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHFilterModel : NSObject
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *vertexShader;
@property(nonatomic,copy)NSString *fragmentShader;
@property(nonatomic,strong)NSArray *uniformList;
@property(nonatomic,strong)NSDictionary *uniformData;
@property(nonatomic,copy)NSString *strength;
@property(nonatomic,copy)NSString *texelOffset;
@property(nonatomic,copy)NSString *audioPath;
@property(nonatomic,copy)NSString *audioLooping;
@property(nonatomic,copy)NSString *unzipDesPath;
+ (MHFilterModel *)unzipFiltersFile:(NSString *)filterFileName;
@end

NS_ASSUME_NONNULL_END
