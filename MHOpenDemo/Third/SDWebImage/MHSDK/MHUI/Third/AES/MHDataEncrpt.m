//
//  MHDataEncrpt.m

#import "MHDataEncrpt.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "MHBaseEncrypt.h"

@implementation MHDataEncrpt

+ (instancetype)shareInstance {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [MHDataEncrpt new];
    });
    return _instance;
}

- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv originData:(NSData *)originData{//加密
    const char *cStr = [key UTF8String];
    unsigned char pKey[kCCKeySizeAES128 + 1];
    bzero(pKey, sizeof(pKey));
    CC_MD5(cStr, strlen(cStr), pKey);
    
    cStr = [iv UTF8String];
    unsigned char pIV[kCCKeySizeAES128 + 1];
    bzero(pIV, sizeof(pIV));
    CC_MD5(cStr, strlen(cStr), pIV);
    
    NSUInteger dataLength = [originData length];
    NSMutableData *mData = [NSMutableData dataWithData:originData];
//    int pad = kCCBlockSizeAES128 - (dataLength % kCCBlockSizeAES128); //Compute how many characters need to pad
//    if(pad > 0) {
//        unsigned char * pPad = malloc(pad);
//        for(int i=0; i<pad; i++) {
//            pPad[i] = (char)pad;
//        }
//        [mData appendBytes:pPad length:pad];
//    }
    
    dataLength = [mData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          0x0001,
                                          pKey,
                                          kCCBlockSizeAES128,
                                          pIV,
                                          [originData bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}


- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv originData:(NSData *)originData{//解密
    const char *cStr = [key UTF8String];
    unsigned char pKey[kCCKeySizeAES128 + 1];
    bzero(pKey, sizeof(pKey));
    CC_MD5(cStr, strlen(cStr), pKey);
    
    
    cStr = [iv UTF8String];
    unsigned char pIV[kCCKeySizeAES128 + 1];
    bzero(pIV, sizeof(pIV));
    CC_MD5(cStr, strlen(cStr), pIV);
    
    NSUInteger dataLength = [originData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,
                                          pKey,
                                          kCCBlockSizeAES128,
                                          pIV,
                                          [originData bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        // unpadding
        unsigned char* pChar = (unsigned char*)buffer;
        pChar += (numBytesEncrypted - 1);
        int pad = (int)*pChar;
        pChar = (unsigned char*)buffer;
        pChar += numBytesEncrypted - pad;
        *pChar = '\0';
        return [NSData dataWithBytesNoCopy:buffer length:(numBytesEncrypted - pad)];
    }
    free(buffer);
    return nil;
}

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key
{
    return [self AES128EncryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key
{
    return [self AES128DecryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCDecrypt key:key iv:iv];
}

- (NSData *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    const char *cStr = [key UTF8String];
    unsigned char pKey[kCCKeySizeAES128 + 1];
    bzero(pKey, sizeof(pKey));
    CC_MD5(cStr, strlen(cStr), pKey);
    
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    
    cStr = [iv UTF8String];
    unsigned char pIV[kCCKeySizeAES128 + 1];
    bzero(pIV, sizeof(pIV));
    CC_MD5(cStr, strlen(cStr), pIV);
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    if (iv) {
        [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    }
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          0x00000000,
                                          pKey,
                                          kCCBlockSizeAES128,
                                          pIV,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)AES128EncryptedData:(NSData *)pData {
   // pData = [pData AES128EncryptWithKey:@"****************" iv:@"################"];
    NSData *esData = [[MHDataEncrpt shareInstance] AES128EncryptWithKey:@"****************" iv:@"################" originData:pData];
    return [MHBaseEncrypt encodeData:esData];
}

- (NSData *)AES128DecryptedData:(NSData *)pData {
    pData = [MHBaseEncrypt decodeData:pData];
    return [[MHDataEncrpt shareInstance] AES128EncryptWithKey:@"****************" iv:@"################" originData:pData];
}

- (NSString *)mhEncrypt:(NSString *)text{
    const char *cStr = [text UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    NSString *string;
    for (int i=0; i<24; i++) {
        string=[result substringWithRange:NSMakeRange(8, 16)];
    }
    
    return string;
}

@end

