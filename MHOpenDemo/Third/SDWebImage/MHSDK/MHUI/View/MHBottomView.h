//
//  MHBottomView.h
//  TXLiteAVDemo_UGC
//
//  Created by Apple on 2021/2/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHBeautyParams.h"
NS_ASSUME_NONNULL_BEGIN

@interface MHBottomView : UIView
@property (nonatomic,strong)void(^clickBtn)(BOOL isTakePhoto);
@property (nonatomic, assign) BOOL isSticker;
@end

NS_ASSUME_NONNULL_END
