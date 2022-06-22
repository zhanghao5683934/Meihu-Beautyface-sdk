//
//  MHMeiyanMenusView.m

#import "MHMeiyanMenusView.h"
#import "MHBeautyMenuCell.h"
#import "MHStickersView.h"
#import "MHBeautyParams.h"
#import "StickerDataListModel.h"
//#import "StickerManager.h"

#import "MHBeautyAssembleView.h"

#import "MHBeautiesModel.h"
//#import "MHFilterModel.h"

#define kBasicStickerURL @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBwYXBpL1N0aWNrZXIvaW5kZXg="
static NSString *StickerImg = @"stickerFace";
static NSString *BeautyImg = @"beauty1";
static NSString *FaceImg = @"face";
static NSString *CameraImg = @"beautyCamera";
static NSString *FilterImg = @"filter";
static NSString *SpecificImg = @"specific";
static NSString *HahaImg = @"haha";


@interface MHMeiyanMenusView()<UICollectionViewDelegate,UICollectionViewDataSource,MHBeautyAssembleViewDelegate,MHStickersViewDelegate>
//@property (nonatomic, strong) MHBeautyManager *beautyManager;//美型特性管理器，必须传入
@property (nonatomic, strong) UICollectionView *collectionView;
//@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, assign) NSInteger lastIndex;//上一个index
@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) MHBeautyAssembleView *beautyAssembleView;//美颜集合

@property (nonatomic, strong) MHStickersView *stickersView;//贴纸
@property (nonatomic, assign) BOOL menuHidden;
@property (nonatomic, assign) BOOL isSimplification;///<精简版

@end
@implementation MHMeiyanMenusView

- (void)setupDefaultBeautyAndFaceValueWithIsTX:(BOOL)isTX{
    //设置美型默认数据，按照数组的名称设置初始值，不要换顺序
    //此处只是说明该位置对应的类型，如果打开注释，请填写具体数值
    
//    NSArray *originalValuesArr = @[@"0",@"大眼",@"瘦脸",
//    @"嘴型",
//    @"瘦鼻",
//    @"下巴",
//    @"额头",
//    @"眉毛",
//    @"眼角",
//    @"眼距",
//    @"开眼角",
//    @"削脸",
//    @"长鼻"];
//    for (int i = 0; i<originalValuesArr.count; i++) {
//        if (i != 0) {
//            NSString *value = originalValuesArr[i];
//            [self handleFaceBeautyWithType:i sliderValue:value.integerValue];
    // }
     //   NSString *faceKey = [NSString stringWithFormat:@"face_%ld",(long)i];
      //  [[NSUserDefaults standardUserDefaults] setInteger:value.integerValue forKey:faceKey];
//
//    }
    //设置美颜参数,范围是0-9
//    NSArray *beautyArr =
//     @[@"磨皮数值",@"美白数值",@"红润数值"];
     NSString *mopi =  @"7";//磨皮数值
     NSString *white = @"7";//美白数值
     NSString *hongrun = @"5";//红润数值
    if (isTX) {
        [self beautyLevel:mopi.intValue whitenessLevel:white.intValue ruddinessLevel:hongrun.intValue brightnessLevel:57];
    } else {
//        [_beautyManager setBuffing:(mopi.intValue)*100/9];
//        [_beautyManager setSkinWhiting:(white.intValue)*100/9];
//        [_beautyManager setRuddiness:(hongrun.intValue)*100/9];
    }
    //存储数值以便同步更新slider
   //磨皮数值
    NSString *mopiKey = [NSString stringWithFormat:@"beauty_%ld",(long)1];
    [[NSUserDefaults standardUserDefaults] setInteger:mopi.integerValue forKey:mopiKey];
    //美白数值
    NSString *whiteKey = [NSString stringWithFormat:@"beauty_%ld",(long)2];
    [[NSUserDefaults standardUserDefaults] setInteger:white.integerValue forKey:whiteKey];
    //红润数值
    NSString *hongrunKey = [NSString stringWithFormat:@"beauty_%ld",(long)3];
    [[NSUserDefaults standardUserDefaults] setInteger:hongrun.integerValue forKey:hongrunKey];
}
- (instancetype)initWithFrame:(CGRect)frame superView:(UIView *)superView delegate:(id<MHMeiyanMenusViewDelegate>)delegate viewController:(MHOpenSourceViewController*)vc isTXSDK:(BOOL)isTx {
    if (self = [super initWithFrame:frame]) {
        self.superView = superView;
        self.delegate = delegate;
        self.menuHidden = NO;
        self.isTX = isTx;
        self.mRender = vc;
        [self addSubview:self.collectionView];
        self.lastIndex = -1;
        [self getSticks];
    }
    return self;
}

- (void)showMenuView:(BOOL)show {
    if (self.currentView) {
        ///<修改MHUI
        [UIView animateWithDuration:0.3 animations:^{
                
            self.currentView.frame = CGRectMake(0, window_height, window_width, self.currentView.frame.size.height);
            } completion:^(BOOL finished) {
                [self.currentView removeFromSuperview];
                self.show = YES;
                self.currentView = nil;
                self.hidden = NO;
                return;
            }];
        
        
    }
    if (show) {
        if (![self isDescendantOfView:self.superView]) {
               [self.superView addSubview:self];
            
        }
    } else {
        [self removeFromSuperview];
    }
    self.show = show;
}
- (void)showMenusWithoutRecord:(BOOL)show
{
    self.menuHidden = !show;
    [self.collectionView reloadData];
}


- (void)setIsTX:(BOOL)isTX {
    _isTX = isTX;
    self.beautyAssembleView.isTXSDK = isTX;
}

#pragma mark - delegate


//美颜-非腾讯直播SDK使用
- (void)handleBeautyWithType:(NSInteger)type level:(CGFloat)beautyLevel {
    switch (type) {
            case MHBeautyType_Original:{
                [self.mRender setBeautyValue:0];
                [self.mRender setWhithValue:0];
                [self.mRender setSaturationValue:0];
            }
                break;
            
            case MHBeautyType_Mopi:
            
            [self.mRender setBeautyValue:beautyLevel];
           
            break;
            case MHBeautyType_White:
            [self.mRender setWhithValue:beautyLevel];
            break;
            case MHBeautyType_Ruddiess:
            [self.mRender setSaturationValue:beautyLevel];
            break;
            case MHBeautyType_Brightness:
//            [_beautyManager setBrightnessLift:beautyLevel];
            break;
            
        default:
            break;
    }
}

//美型
-(void)handleFaceBeautyWithType:(NSInteger)type sliderValue:(NSInteger)value {
   
    switch (type) {
        case MHBeautyFaceType_Original:{
            //原图-->人脸识别设置
            [self.mRender setThinFaceValue:0];
            [self.mRender setEyeValue:0];
            
        }
            break;
        case MHBeautyFaceType_ThinFace:
            [self.mRender setThinFaceValue:(int)value];

            break;
        case MHBeautyFaceType_BigEyes:
            [self.mRender setEyeValue:(int)value];
            break;
       
        default:
            break;
    }
   
}



//滤镜
- (void)handleFiltersEffectWithType:(NSInteger)filter  withFilterName:(nonnull NSString *)filterName{
//    MHFilterModel *model = [MHFilterModel unzipFiltersFile:filterName];
//    if (model) {
//        NSDictionary *dic = @{@"kUniformList":model.uniformList,
//              @"kUniformData":model.uniformData,
//              @"kUnzipDesPath":model.unzipDesPath,
//              @"kName":model.name,
//              @"kFragmentShader":model.fragmentShader
//        };
//        [_beautyManager setFilterType:filter newFilterInfo:dic];
//    } else {
//        [_beautyManager setFilterType:filter newFilterInfo:[NSDictionary dictionary]];
//    }
}
///修改MHUI
///<照相
- (void)takePhoto{
    if ([self.delegate respondsToSelector:@selector(cameraAction)]) {
        [self.delegate cameraAction];
    }
}
///<隐藏
- (void)clickPackUp{
    [self showMenuView:YES];
}



//贴纸
- (void)handleStickerEffect:(NSString *)stickerContent sticker:(StickerDataListModel *)model{
//    if (model == nil){
//        _beautyManager.isUseSticker = NO;
//    }else{
//        _beautyManager.isUseSticker = YES;
//    }
//    [self.beautyManager setSticker:stickerContent];
}

#pragma mark - 贴纸解析
- (void)getSticks {
//     __weak typeof(self) weakSelf = self;
//    dispatch_async(dispatch_queue_create("com.suory.stickers", DISPATCH_QUEUE_SERIAL), ^{
//        [[StickerManager sharedManager] requestStickersListWithUrl:kBasicStickerURL Success:^(NSArray<StickerDataListModel *> * _Nonnull stickerArray) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf.stickersView configureStickers:stickerArray];
//            });
//        } Failed:^{
//
//        }];
//    });
}


#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHBeautyMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHBeautyMenuCell" forIndexPath:indexPath];
    cell.isSimplification = self.isSimplification;
    cell.menuModel = self.array[indexPath.row];
    if (![cell.menuModel.beautyTitle isEqualToString:@"单击拍"]){
        cell.hidden = self.menuHidden;
    }else{
        //短视频图片变化
        [cell changeRecordState:self.menuHidden];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((window_width-40)/self.array.count, MHMeiyanMenusCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了MHUI");
    MHBeautiesModel *currentModel = self.array[indexPath.row];
    if ([currentModel.beautyTitle isEqual:@""]) {
        if ([self.delegate respondsToSelector:@selector(cameraAction)]) {
            [self.delegate cameraAction];
        }
        return;
    }
    else if([currentModel.beautyTitle isEqual:@"单击拍"]){
        if ([self.delegate respondsToSelector:@selector(recordAction)]) {
            [self.delegate recordAction];
        }
        return;
    }else if ([currentModel.beautyTitle isEqual:@"贴纸"]){
        [self showBeautyViews:self.stickersView];
    }else if ([currentModel.beautyTitle isEqual:@"美颜"]){
        [self.beautyAssembleView configureUI];
        [self showBeautyViews:self.beautyAssembleView];
    }
    
    currentModel.isSelected = YES;
    if (self.lastIndex >= 0) {
        MHBeautiesModel *lastModel = self.array[self.lastIndex];
        lastModel.isSelected = NO;
    }
    self.lastIndex = indexPath.row;
    [self.collectionView reloadData];
}

#pragma mark - 切换美颜效果分类
- (void)showBeautyViews:(UIView *)currentView {
    
    [self.superView addSubview:currentView];
    CGRect rect = currentView.frame;
    rect.origin.y = window_height - currentView.frame.size.height - BottomIndicatorHeight;
    [currentView setFrame:rect];
    self.currentView = currentView;
    ///修改MHUI
    self.currentView.transform = CGAffineTransformMakeTranslation(0.00,  currentView.frame.size.height);
        [UIView animateWithDuration:0.3 animations:^{
           
            self.currentView.transform = CGAffineTransformMakeTranslation(0.00, 0.00);

        }];
    if ([currentView isEqual:self.beautyAssembleView]) {
        [self.beautyAssembleView configureUI];
        //[self.beautyAssembleView configureSlider];
    }
    ///修改MHUI
    self.hidden = YES;
}
- (void)animationOfTakingPhoto{
    MHBeautyMenuCell *cell = (MHBeautyMenuCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndex:2]];
    [cell takePhotoAnimation];
}
#pragma mark - lazy
- (MHBeautyAssembleView *)beautyAssembleView {
    if (!_beautyAssembleView) {
        _beautyAssembleView = [[MHBeautyAssembleView alloc] initWithFrame:CGRectMake(0, window_height-MHBeautyAssembleViewHeight-BottomIndicatorHeight, window_width, MHBeautyAssembleViewHeight)];
        _beautyAssembleView.delegate = self;
        
    }
    return _beautyAssembleView;
}


- (MHStickersView *)stickersView {
    if (!_stickersView) {
        _stickersView = [[MHStickersView alloc] initWithFrame:CGRectMake(0, window_height-MHStickersViewHeight-BottomIndicatorHeight , window_width, MHStickersViewHeight)];
        _stickersView.delegate = self;
        ///修改MHUI
        _stickersView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:MHBlackAlpha];
    }
    return _stickersView;
}

-(NSMutableArray *)array {
    if (!_array) {
        NSArray *arr = @[@"美颜"];
        NSArray *imgArr = @[BeautyImg,CameraImg,StickerImg];
        _array = [NSMutableArray array];
        for (int i = 0; i<arr.count; i++) {
           MHBeautiesModel *model = [[MHBeautiesModel alloc] init];
            model.imgName = imgArr[i];
            model.beautyTitle = arr[i];
            model.menuType = MHBeautyMenuType_Menu;
            [_array addObject:model];
        }
    }
    return _array;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0,20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, window_width, self.frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHBeautyMenuCell"];
    }
    return _collectionView;
}
- (BOOL)isSimplification{
    return  [[[NSUserDefaults standardUserDefaults] objectForKey:@"MHSDKVersion"] isEqual:@"2"];
}

@end
