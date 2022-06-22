//
//  MHBaseEncrypt.h
//  TXLiteAVDemo_UGC
//
//  Created by apple on 2019/12/17.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "MHEncryptDefine.h"
NS_ASSUME_NONNULL_BEGIN

@interface MHBaseEncrypt : NSObject
+(NSData *)encodeData:(NSData *)data;
+(NSData *)decodeData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
