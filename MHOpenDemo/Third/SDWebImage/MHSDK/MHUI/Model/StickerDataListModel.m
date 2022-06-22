//
//  StickerDataListModel.m


#import <Foundation/Foundation.h>

#import "StickerDataListModel.h"

@implementation StickerDataListModel

+ (StickerDataListModel *)mh_modelWithData:(NSDictionary *)data {
    StickerDataListModel *model = [StickerDataListModel new];
    model.name = data[@"name"];
    model.thumb = data[@"thumb"];
    model.is_downloaded = data[@"is_downloaded"];
    model.category = data[@"category"];
    model.resource = data[@"resource"];
    //NSLog(@"resource----%@", model.resource);
    model.uptime = data[@"uptime"];
    model.type = data[@"type"];
    model.beauty = data[@"beauty"];
    if (model.beauty != nil && model.beauty.length > 0) {
        NSData *jsonData = [model.beauty dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                            error:&err];
        model.white = dic[@"skin_whiting"];
        
        model.mopi = dic[@"skin_smooth"];
        
        model.ruddies = dic[@"skin_tenderness"];
        
        model.saturatio = dic[@"skin_saturatio"];
        
        model.eye_brow = dic[@"eye_brow"];
        
        model.big_eye = dic[@"big_eye"];
        
        model.eye_length = dic[@"eye_length"];
        
        model.eye_corner = dic[@"eye_corner"];
        
        model.eye_alat = dic[@"eye_alat"];
       
        model.face_lift = dic[@"face_lift"];
        
        model.face_shave = dic[@"face_shave"];
        
        model.mouse_lift = dic[@"mouse_lift"];
        
        model.nose_lift = dic[@"nose_lift"];
        
        model.chin_lift = dic[@"chin_lift"];
        
        model.forehead_lift = dic[@"forehead_lift"];
        
        model.lengthen_noseLift = dic[@"lengthen_noseLift"];
    }
    return model;
}
@end
