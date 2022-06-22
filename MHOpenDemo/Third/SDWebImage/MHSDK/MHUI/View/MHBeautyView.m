//MHBeautyView.m

//美颜页面

#import "MHBeautyView.h"
#import "MHBeautyMenuCell.h"
#import "MHBeautyParams.h"
#import "MHBeautiesModel.h"

static NSString *OriginalImg = @"beautyOrigin";
static NSString *WhiteImg = @"beautyWhite";
static NSString *MopiImg = @"beautyMopi";
static NSString *RuddinessImg = @"beautyRuddise";
static NSString *BrightnessImg = @"brightness";


@interface MHBeautyView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger lastIndex;
@property (nonatomic, assign) NSInteger beautyType;
@property (nonatomic, strong) NSMutableArray *arr;
@end
@implementation MHBeautyView
//#ifdef SAVEEFFECTMODE
//NSInteger currentValue = [[NSUserDefaults standardUserDefaults] integerForKey:title];
//[self beautyEffect:indexPath.row sliderValue:currentValue];
//#endif

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:MHBlackAlpha];
        self.lastIndex = -1;
    }
    return self;
}

- (void)clearAllBeautyEffects {
    for (int i = 0; i<self.array.count; i++) {
        NSString *beautKey = [NSString stringWithFormat:@"beauty_%ld",(long)i];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:beautKey];
    }
}

- (void)cancelSelectedBeautyType:(NSInteger)type {
    for (int i = 0; i<self.array.count; i++) {
        MHBeautiesModel *model = self.array[i];
        if (model.type == type) {
            model.isSelected = NO;
        }
    }
    self.lastIndex = -1;
    [self.collectionView reloadData];
}

#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHBeautyMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHBeautyMenuCell" forIndexPath:indexPath];
    cell.menuModel = self.array[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((window_width-40)/4, MHMeiyanMenusCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastIndex == indexPath.row) {
        return;
    }
    MHBeautiesModel *currentModel = self.array[indexPath.row];
    currentModel.isSelected = YES;
    if (self.lastIndex >= 0) {
        MHBeautiesModel *lastModel = self.array[self.lastIndex];
        lastModel.isSelected = NO;
    }
    if (indexPath.row == 0) {
        //2020-07-04点击原图不能清除之前的磨砂美白等数据的缓存
        //[self clearAllBeautyEffects];
    }
    
    self.lastIndex = indexPath.row;
    [self.collectionView reloadData];
    self.beautyType = indexPath.row;
    
    NSString *faceKey = [NSString stringWithFormat:@"beauty_%ld",(long)self.beautyType];
    NSInteger currentValue = [[NSUserDefaults standardUserDefaults] integerForKey:faceKey];
    
    if ([self.delegate respondsToSelector:@selector(handleBeautyEffects:sliderValue:)]) {
        [self.delegate handleBeautyEffects:self.beautyType sliderValue:currentValue];
    }
}

#pragma mark - lazy
- (NSMutableArray *)array {
    if (!_array) {
        NSArray *titleArr = @[@"原图",@"美白",@"磨皮",@"红润"/*,@"亮度"*/];
        
        ///MHUI修改20210304余设置生效
//        NSString * buffing = [NSString  stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"beauty_1"]];
//        NSString * white = [NSString  stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"beauty_2"]];
//        NSString * ruddiness = [NSString  stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"beauty_3"]];
//        NSString * brightness = [NSString  stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"beauty_4"]];
        
//        [Buffing isEqualToString:@"(null)"]
        
//        NSArray *originalValuesArr = @[@"0",IsStringWithAnyText(buffing)?buffing:@"5",IsStringWithAnyText(white)?white:@"5",IsStringWithAnyText(ruddiness)?ruddiness:@"7",IsStringWithAnyText(brightness)?brightness:@"5.7"];
        NSArray *originalValuesArr = @[@"0",@"5",@"5",@"7",@"5.7"];
        NSArray *imgArr = @[OriginalImg,WhiteImg,MopiImg,RuddinessImg,BrightnessImg];
        _array = [NSMutableArray array];
        for (int i = 0; i<titleArr.count; i++) {
            MHBeautiesModel *model = [[MHBeautiesModel alloc] init];
            model.imgName = imgArr[i];
            model.beautyTitle = titleArr[i];
            model.menuType = MHBeautyMenuType_Beauty;
            model.type = i;
            model.originalValue =  originalValuesArr[i];
            NSString *beautKey = [NSString stringWithFormat:@"beauty_%ld",(long)i];
            NSInteger originalValue = model.originalValue.integerValue;
            [[NSUserDefaults standardUserDefaults] setInteger:originalValue forKey:beautKey];
            [_array addObject:model];
        }
    }
    return _array;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(20, 20,20,20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, window_width,self.frame.size.height) collectionViewLayout:layout];
        ///修改MHUI
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHBeautyMenuCell"];
    }
    return _collectionView;
}

- (NSInteger)currentIndex{
    return _lastIndex;
}



@end

