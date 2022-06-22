//
//  MHStickersView.m


#import "MHStickersView.h"
#import "MHStickerCell.h"
#import "StickerManager.h"
#import "StickerDataListModel.h"
#import "MHSectionStickersView.h"
#import "MHBeautyParams.h"
///修改MHUI
#import "MHBottomView.h"
#define kBasicMasksUrl @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBwYXBpL21hc2svaW5kZXg="
#define kHighStickersUrl @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBwYXBpL1N0aWNrZXIvaGlnaA=="
#define kHighMasksUrl @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBwYXBpL21hc2svaGlnaA=="
#define kBasicStickersUrl @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBwYXBpL1N0aWNrZXIvaW5kZXg="

@interface MHStickersView ()<UIScrollViewDelegate,MHSectionStickersViewDelegate>
@property (nonatomic, assign) NSInteger lastIndex;//记录按钮的索引，以便更新UI
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *views;
@property (nonatomic, assign) NSInteger lastViewIndex;//记录View索引，取消选中贴纸
@property (nonatomic, assign) BOOL isFirstSelect;
@property (nonatomic, assign) NSInteger currentViewIndex;
@property (nonatomic, strong) NSMutableArray *titleBtnArr;
@property (nonatomic, strong) NSMutableArray *allArr;
@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) MHBottomView * bottomView;

@end
@implementation MHStickersView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        ///修改MHUI
        self.backgroundColor = [UIColor clearColor];
        self.lastViewIndex = -1;
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"selectedStickerIndex"];
        [self configureStickerTypes];
    }
    return self;
}

- (void)configureStickerTypes {
    for (UIView *subview in self.subviews){
        [subview removeFromSuperview];
    }
    ///修改MHUI
    NSAttributedString *basicMask = [self stringAttachment:@"基础面具" textColor:FontColorBlackNormal];
    NSAttributedString *basicSticker = [self stringAttachment:@"基础贴纸" textColor:FontColorSelected];
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"MHSDKVersion"];
    NSArray *titleBtns = [NSArray array];
    if (type.integerValue == 0) {
        //低级
        titleBtns = @[basicSticker,basicMask];
        self.urls  = @[kBasicStickersUrl,kBasicMasksUrl];
    } else {
       // 高级
        ///修改MHUI
        NSAttributedString *highMask = [self stringAttachment:@"高级面具" textColor:FontColorBlackNormal];
        NSAttributedString *highSticker = [self stringAttachment:@"高级贴纸" textColor:FontColorBlackNormal];
        titleBtns = @[basicSticker,highSticker,basicMask,highMask];
        self.urls  = @[kBasicStickersUrl,kHighStickersUrl,kBasicMasksUrl,kHighMasksUrl];
    }
    self.allArr = [NSMutableArray arrayWithCapacity:titleBtns.count];
    self.titleBtnArr = [NSMutableArray arrayWithCapacity:titleBtns.count];
    self.views = [NSMutableArray arrayWithCapacity:titleBtns.count];
    for (int i = 0; i<titleBtns.count; i++) {
        UIButton *titleBtn = [UIButton buttonWithType:0];
        [titleBtn setAttributedTitle:titleBtns[i] forState:0];
        titleBtn.frame = CGRectMake((window_width/titleBtns.count)*i, 0, window_width/titleBtns.count, MHStickerSectionHeight);
        titleBtn.tag = 1109+i;
        [titleBtn addTarget:self action:@selector(switchStickerOrMask:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:titleBtn];
        NSMutableArray *muArr = [NSMutableArray array];
        [self.allArr addObject:muArr];
        [self.titleBtnArr addObject:titleBtn];
        MHSectionStickersView *stickersView = [[MHSectionStickersView alloc] initWithFrame:CGRectMake(window_width * i, 0, window_width, self.frame.size.height - MHStickerSectionHeight-0.5)];
        stickersView.tag = i+1111;
        stickersView.lastTag = stickersView.tag;
        stickersView.delegate = self;
        [self.scrollView addSubview:stickersView];
        [self.views addObject:stickersView];
    }
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, MHStickerSectionHeight, window_width, 0.5)];
    _lineView.backgroundColor = LineColor;
    [self addSubview:_lineView];
    [self addSubview:self.scrollView];
    [self addSubview:self.bottomView];
//    self.frame.origin.y
    ///修改MHUI
    CGFloat bottom = self.lineView.frame.origin.y + self.lineView.frame.size.height;
//    CGFloat bottom = MHStickerSectionHeight;
    CGRect rect = self.scrollView.frame;
    self.scrollView.frame = CGRectMake(rect.origin.x, bottom, rect.size.width, rect.size.height);
    self.scrollView.contentSize = CGSizeMake(window_width * titleBtns.count, self.frame.size.height - bottom);
}

- (void)switchStickerOrMask:(UIButton *)btn {
    NSInteger tag = btn.tag - 1109;
    [self.scrollView setContentOffset:CGPointMake(window_width * tag, 0) animated:YES];
    [self switchViewToRequestData:tag];
}

- (void)switchSelectedBtnUI:(NSInteger)index textColor:(UIColor *)color {
    UIButton *curentBtn = self.titleBtnArr[index];
    NSAttributedString *str = curentBtn.currentAttributedTitle;
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithAttributedString:str];
    [str2 addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, str.length)];
    [curentBtn setAttributedTitle:str2 forState:0];
    
}

#pragma mark - 底部按钮响应
- (void)cameraAction:(BOOL)isTakePhoto{
    NSLog(@"点击了拍照");
    if (isTakePhoto) {
        if ([self.delegate respondsToSelector:@selector(takePhoto)]) {
            [self.delegate takePhoto];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(clickPackUp)]) {
            [self.delegate clickPackUp];
        }
    }
    
    
}

#pragma mark - delegate
- (void)handleSelectedStickerEffect:(NSString *)stickerContent stickerModel:(nonnull StickerDataListModel *)model{
    //NSLog(@"sss---%@",stickerContent);
    if (!IsStringWithAnyText(model.name) && !IsStringWithAnyText(model.resource) ) {
        if ([self.delegate respondsToSelector:@selector(handleStickerEffect: sticker:)]) {
            [self.delegate handleStickerEffect:@"" sticker:nil];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(handleStickerEffect: sticker:)]) {
            [self.delegate handleStickerEffect:stickerContent sticker:model];
        }
    }
}

//当切换分类后，点击贴纸，取消上一个分类下贴纸的选中效果
- (void)reloadLastStickerSelectedStatus:(BOOL)needReset {
    if (!self.isFirstSelect) {
        self.lastViewIndex = 0;
        self.isFirstSelect = YES;
    }
    MHSectionStickersView *lastSubView = self.views[self.lastViewIndex];

    NSMutableArray *lastArr = self.allArr[self.lastViewIndex];
    NSString *la = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedStickerIndex"];
    if (la != nil && ![la isEqualToString:@""]) {
        NSInteger laindex = la.integerValue;
        if (laindex < lastArr.count) {
            StickerDataListModel *model = lastArr[laindex];
            model.isSelected = !needReset;
            [lastSubView.collectionView reloadData];
        }
        
    }
    MHSectionStickersView *subView = self.views[self.currentViewIndex];
    subView.lastTag = subView.tag;
    self.lastViewIndex = self.currentViewIndex;
}

#pragma mark - data
- (void)configureStickers:(NSArray *)arr {
    NSMutableArray *muArr = self.allArr.firstObject;
    [muArr addObjectsFromArray:arr];
    MHSectionStickersView *stickersView = self.views.firstObject;
    [stickersView configureData:arr];
}

- (void)switchViewToRequestData:(NSInteger)index {
    
    NSInteger currentIndex = MIN(index, self.allArr.count);
    NSMutableArray *arr = self.allArr[currentIndex];
    MHSectionStickersView *currentSubView = self.views[currentIndex];
    NSString *url = self.urls[currentIndex];
    //NSLog(@"url= %@",url);
    if (arr.count > 0) {
        [currentSubView configureData:arr];
    } else {
        [[StickerManager sharedManager] requestStickersListWithUrl:url
                                                           Success:^(NSArray<StickerDataListModel *> * _Nonnull stickerArray) {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [arr addObjectsFromArray:stickerArray];
                                                                   [currentSubView configureData:arr];
                                                               });
                                                               
                                                           } Failed:^{
                                                               
                                                           }];
    }
    
    
    if (!self.isFirstSelect) {
        self.lastViewIndex = 0;
        self.isFirstSelect = YES;
        self.lastIndex = 0;
    }
    
    MHSectionStickersView *lastSubView = self.views[self.lastViewIndex];
    currentSubView.lastTag = lastSubView.tag;
    
    [self switchSelectedBtnUI:currentIndex textColor:FontColorSelected];
    if (self.lastIndex != currentIndex) {
        [self switchSelectedBtnUI:self.lastIndex textColor:FontColorBlackNormal];
    }
    self.lastIndex = currentIndex;
    self.currentViewIndex = currentIndex;
}

#pragma mark - scrollDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / window_width;
    [self switchViewToRequestData:index];
}

#pragma mark - lazy
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, window_width, self.frame.size.height - MHStickerSectionHeight-0.5)];
        _scrollView.pagingEnabled = YES;
        ///修改MHUI
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

///修改MHUI
- (MHBottomView*)bottomView{

    if (!_bottomView) {
        __weak typeof(self) weakSelf = self;
        CGFloat bottom =  self.frame.size.height - MHBottomViewHeight;
        _bottomView = [[MHBottomView alloc] initWithFrame:CGRectMake(0, bottom, window_width, MHBottomViewHeight)];
        _bottomView.isSticker = YES;
//        _bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _bottomView.clickBtn = ^(BOOL isTakePhoto) {
            [weakSelf cameraAction:isTakePhoto];
        };
    }
    return _bottomView;
}

- (NSAttributedString *)stringAttachment:(NSString *)content textColor:(UIColor *)color {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:content];
    [string addAttributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:Font_12} range:NSMakeRange(0, string.length)];
    if ([content containsString:@"基础"]) {
        return string;
    }
    NSTextAttachment *attchment = [[NSTextAttachment alloc]init];
    attchment.bounds = CGRectMake(0, 2.5,18,10);//设置frame
    UIImage *img = BundleImg(@"pro");
    attchment.image = img;//设置需要插入的图片
    NSAttributedString *attchmentString = [NSAttributedString attributedStringWithAttachment:attchment];
    [string appendAttributedString:attchmentString];
    return string;
}
@end
