//
//  StickerManager.m


#import "StickerManager.h"
#import "StickerDataListModel.h"
#import "MHBeautyParams.h"
//#import <MHBeautySDK/MHSDK.h>
//#import <MHBeautySDK/MHZipArchive.h>
//#import "SSZipArchive.h"
//#import "MHSDK.h"
#import "MHZipArchive.h"

@interface MHStickerDownloader : NSObject < NSURLSessionDelegate>
@property(nonatomic, strong) NSURLSession *session;

@property(nonatomic, strong) StickerDataListModel *sticker;

@property(nonatomic, strong) NSURL *url;

@property(nonatomic, assign) NSInteger index;

- (instancetype)initWithSticker:(StickerDataListModel *)sticker url:(NSURL *)url index:(NSInteger)index;

- (void)downloadSuccessed:(void (^)(StickerDataListModel *sticker, NSInteger index, MHStickerDownloader *downloader))success failed:(void (^)(StickerDataListModel *sticker, NSInteger index, MHStickerDownloader *downloader))failed;

@end

@implementation MHStickerDownloader

- (instancetype)initWithSticker:(StickerDataListModel *)sticker url:(NSURL *)url index:(NSInteger)index {
    if (self = [super init]) {
        self.sticker = sticker;
        self.index = index;
        self.url = url;
    }
    return self;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // config.HTTPMaximumConnectionsPerHost = 20;
        _session =
        [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}
#pragma mark - 下载贴纸
- (void)downloadSuccessed:(void (^)(StickerDataListModel *sticker, NSInteger index, MHStickerDownloader *downloader))success failed:(void (^)(StickerDataListModel *sticker, NSInteger index, MHStickerDownloader *downloader))failed {
    self.sticker.downloadState = MHStickerDownloadStateDownoading;
    [[self.session downloadTaskWithURL:self.url completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        if (error) {
            self.sticker.downloadState = MHStickerDownloadStateDownoadNot;
            failed(self.sticker, self.index, self);
            
        } else {
            // unzip
            NSString *path = [[StickerManager sharedManager] unzipPath];

           // BOOL unZipSuccess = [SSZipArchive unzipFileAtPath:location.path toDestination:path delegate:self];
            BOOL unZipSuccess = [MHZipArchive unzipFileAtPath:location.path toDestination:path delegate:self];
            if (unZipSuccess) {
                NSString *stickerPath = [NSString stringWithFormat:@"%@/%@/config.json",path,self->_sticker.name];
              //  NSLog(@"stickerPath--%@",stickerPath);
                NSString *content = [NSString stringWithContentsOfFile:stickerPath encoding:NSUTF8StringEncoding error:nil];
                
                
            
               // NSLog(@"content---%@",content);
                // 存储下载的贴纸
                NSString *key = [NSString stringWithFormat:@"%@:%@",self.sticker.name,self.sticker.uptime];
               // NSLog(@"stickerKey--%@",key);
                
                [[NSUserDefaults standardUserDefaults] setObject:content forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                self.sticker.downloadState = MHStickerDownloadStateDownoadDone;
                self.sticker.is_downloaded = [NSNumber numberWithBool:1].stringValue;
                success(self.sticker,self.index,self);
            } else {
                failed(self.sticker, self.index, self);
            }
        }
    }] resume];
    
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler {
    /*
     // Get remote certificate
     SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
     SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
     
     // Set SSL policies for domain name check
     NSMutableArray *policies = [NSMutableArray array];
     [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)challenge.protectionSpace.host)];
     SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
     
     // Evaluate server certificate
     SecTrustResultType result;
     SecTrustEvaluate(serverTrust, &result);
     //BOOL certificateIsValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
     
     // Get local and remote cert data
     NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
     NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"server" ofType:@"cer"];
     NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
     
     // The pinnning check
     if ([remoteCertificateData isEqualToData:localCertificate]) {
     NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
     completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
     } else {
     completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
     }
     */
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

@end

@interface StickerManager()<NSURLSessionDelegate>
@property(nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *downloadCache;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, copy) NSString *stickerUrl;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation StickerManager

+ (instancetype)sharedManager {
    static id _stickersManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _stickersManager = [StickerManager new];
    });
    
    return _stickersManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.unzipPath = [self getUnzipPath];
    }
    return self;
}



- (NSString *)currentVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDic objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}

- (NSString *)bundleName {
    NSString *bundleName = [[NSBundle mainBundle] bundleIdentifier];
    return bundleName;
}

- (NSString *)currentTimeStamp {
    NSDate *datenow = [NSDate date];
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];
    return timeStamp;
}

#pragma mark - 贴纸列表
-(void)requestStickersListWithUrl:(NSString *)url Success:(void (^)(NSArray<StickerDataListModel *>*stickerArray))success Failed:(void (^)(void))fail {
    NSMutableArray *muArr = [NSMutableArray array];
    self.stickerUrl = url;
   
//    [[MHSDK shareInstance] dataTaskWithURLKey:url responseCompletionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error || !data) {
//
//        } else {
//            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            //NSLog(@"sticDIc--%@",dic);
//            if (IsDictionaryWithAnyKeyValue(dic)) {
//                NSString *code = dic[@"code"];
//                if (code.integerValue == 0) {
//                    self.timestamp = dic[@"timestamp"];
//                    if (IsArrayWithAnyItem(dic[@"list"])) {
//                        NSArray *arr = dic[@"list"];
//                       // NSLog(@"arr -- %@",arr);
//                        for (int i = 0; i < arr.count; i++) {
//                            StickerDataListModel *sticker = [StickerDataListModel mh_modelWithData:arr[i]];
//                            if (i == 0) {//第一个是取消，不显示下载图标
//                                sticker.downloadState = MHStickerDownloadStateDownoadDone;
//                                sticker.is_downloaded = @"1";
//                            }
//                            NSString *key = [NSString stringWithFormat:@"%@:%@",sticker.name,sticker.uptime];
//                            NSString *content = [[NSUserDefaults standardUserDefaults] objectForKey:key];
//                            //NSLog(@"stickercontent:---%@",content);
//                            if (content.length > 0) {//该贴纸已经下载过
//                                sticker.is_downloaded = @"1";
//                            }
//                            [muArr addObject:sticker];
//                        }
//                        success(muArr.copy);
//                    }
//
//                }
//            }
//        }
//    }];
    
}

- (NSString *)getUnzipPath {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"sticker"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return path;
}

#pragma mark - download
- (void)downloadSticker:(StickerDataListModel *)sticker index:(NSInteger)index withSuccessed:(void (^)(StickerDataListModel *sticker, NSInteger index))success failed:(void (^)(StickerDataListModel *sticker, NSInteger index))failed {
    
    NSURL *downloadUrl = [NSURL URLWithString:sticker.resource];
   // NSLog(@"downloadUrl--%@",downloadUrl);
    // 判断是否存在对应的下载操作
    if (self.downloadCache[downloadUrl] != nil) {
        return;
    }
    MHStickerDownloader *downloader = [[MHStickerDownloader alloc] initWithSticker:sticker url:downloadUrl index:index];
    
    [self.downloadCache setObject:downloader forKey:downloadUrl];
    
    [downloader downloadSuccessed:^(StickerDataListModel *sticker, NSInteger index, MHStickerDownloader *downloader) {
        [self.downloadCache removeObjectForKey:downloadUrl];
        downloader = nil;
        success(sticker, index);
        
    }  failed:^(StickerDataListModel *sticker, NSInteger index, MHStickerDownloader *downloader) {
        
        [self.downloadCache removeObjectForKey:downloadUrl];
        downloader = nil;
        failed(sticker, index);
        
    }];
}

- (NSMutableDictionary *)downloadCache {
    if (_downloadCache == nil) {
        _downloadCache = [[NSMutableDictionary alloc] init];
    }
    return _downloadCache;
}


@end


