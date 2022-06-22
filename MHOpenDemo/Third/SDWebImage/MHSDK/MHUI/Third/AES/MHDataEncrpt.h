//
//  MHDataEncrpt.h


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHDataEncrpt : NSData
+ (instancetype)shareInstance;
- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv originData:(NSData *)originData;   //加密
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv originData:(NSData *)originData;  //解密

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key;
- (NSData *)AES128DecryptedDataWithKey:(NSString *)key;
- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv;

- (NSData *)AES128DecryptedData:(NSData *)pData;
- (NSData *)AES128EncryptedData:(NSData *)pData;

- (NSString *)mhEncrypt:(NSString *)text;
@end


NS_ASSUME_NONNULL_END
