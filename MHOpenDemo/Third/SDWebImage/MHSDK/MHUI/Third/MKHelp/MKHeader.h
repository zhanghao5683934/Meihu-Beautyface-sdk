//
//  MKHeader.h
//  MagicCamera
//
//  Created by mkil on 2019/9/4.
//  Copyright © 2019 黎宁康. All rights reserved.
//

#ifndef MKHeader_h
#define MKHeader_h

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

// 色彩滤镜路径
#define kStyleFilterPath            [[NSBundle mainBundle] pathForResource:@"Filters" ofType:nil]
// 特效滤镜路径
#define kStickerFilterPath          [[NSBundle mainBundle] pathForResource:@"Stickers" ofType:nil]

// 强弱引用
#define weakSelf()          __weak typeof(self) wself = self;
#define strongSelf()        __strong typeof(self) self = wself;

#endif /* MKHeader_h */
