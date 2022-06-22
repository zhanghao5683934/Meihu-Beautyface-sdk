//
//  MHSectionStickersView.m


#import "MHSectionStickersView.h"
#import "MHStickerCell.h"
#import "StickerManager.h"
#import "StickerDataListModel.h"
#import "MHBeautyParams.h"

@interface MHSectionStickersView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *indexsArr;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation MHSectionStickersView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.lastIndex = -1;
    }
    return self;
}

- (void)configureData:(NSArray *)stickersArray {
    //NSLog(@"%@",stickersArray);
    [self.stickersArray removeAllObjects];
    [self.stickersArray addObjectsFromArray:stickersArray];
    [self.collectionView reloadData];
}

- (void)configureStickerData:(NSInteger *)stickersType {
   
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.stickersArray.count + (isNeedBottom?5:0);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHStickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHStickerCell" forIndexPath:indexPath];
    if (self.stickersArray.count > indexPath.row) {
        cell.listModel = self.stickersArray[indexPath.row];
    }else{
        UICollectionViewCell * cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:@"customCollectionCell" forIndexPath:indexPath];
        return cell1;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(MHStickerItemWidth, MHStickerItemHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row>=self.stickersArray.count) {
        return;
    }
    if (self.tag != self.lastTag) {//已经切换分类，取消上一个分类下的选中效果
        if ([self.delegate respondsToSelector:@selector(reloadLastStickerSelectedStatus:)]) {
            [self.delegate reloadLastStickerSelectedStatus:YES];
        }
        self.lastIndex = -1;
    }
   
    if (self.lastIndex == indexPath.item) {
        return;
    }
    StickerDataListModel *currentModel = self.stickersArray[indexPath.row];
    
    if (self.lastIndex >= 0) {
        StickerDataListModel *lastModel = self.stickersArray[self.lastIndex];
        lastModel.isSelected = NO;
    }
  
    MHStickerCell *cell = (MHStickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.indexsArr removeAllObjects];//点击多个同时下载只显示最后一个贴纸特效
    [self.indexsArr addObject:@(indexPath.row)];
    if (currentModel.is_downloaded.boolValue == NO) {
        [cell startDownload];
        [[StickerManager sharedManager] downloadSticker:currentModel index:indexPath.row withSuccessed:^(StickerDataListModel * _Nonnull sticker, NSInteger index) {
            sticker.downloadState = MHStickerDownloadStateDownoadDone;
            [self.stickersArray replaceObjectAtIndex:indexPath.item withObject:sticker];
            NSNumber *lastSelectedIndex = self.indexsArr.lastObject;
            if (index == lastSelectedIndex.integerValue) {
                sticker.isSelected = YES;
                NSString *key = [NSString stringWithFormat:@"%@:%@",sticker.name,sticker.uptime];
                if ([self.delegate respondsToSelector:@selector(handleSelectedStickerEffect: stickerModel:)]) {
                    [self.delegate handleSelectedStickerEffect:key stickerModel:sticker];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (collectionView) {
                    for (NSIndexPath *path in collectionView.indexPathsForVisibleItems) {
                        if (index == path.item) {
                            [collectionView reloadData];
                            break;
                        }
                    }
                    
                }
                
            });
           
            self.lastIndex = indexPath.item;
            NSString *itemStr = [NSString stringWithFormat:@"%ld",(long)indexPath.item];
            [[NSUserDefaults standardUserDefaults] setObject:itemStr forKey:@"selectedStickerIndex"];
        } failed:^(StickerDataListModel * _Nonnull sticker, NSInteger index) {
            sticker.isSelected = NO;
            sticker.downloadState = MHStickerDownloadStateDownoadNot;
            [self.stickersArray replaceObjectAtIndex:indexPath.item withObject:sticker];
            if (self.lastIndex >= 0) {
                StickerDataListModel *lastModel = self.stickersArray[self.lastIndex];
                lastModel.isSelected = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [collectionView reloadData];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下载失败" message:@"请稍后重试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            });
            
        }];
    } else {

//        if (self.lastTag == 1114) {
            for (StickerDataListModel * model in self.stickersArray) {
                if (model == currentModel) {
                    model.isSelected = YES;
                }else{
                    model.isSelected = NO;
                }
            }
//        }
        NSString *key = [NSString stringWithFormat:@"%@:%@",currentModel.name,currentModel.uptime];
//        currentModel.isSelected = YES;
        if ([self.delegate respondsToSelector:@selector(handleSelectedStickerEffect: stickerModel:)]) {
            [self.delegate handleSelectedStickerEffect:key stickerModel:currentModel];
        }
        [collectionView reloadData];
         self.lastIndex = indexPath.item;
        NSString *itemStr = [NSString stringWithFormat:@"%ld",(long)indexPath.item];
        [[NSUserDefaults standardUserDefaults] setObject:itemStr forKey:@"selectedStickerIndex"];
    }
}

#pragma mark - lazy
- (NSMutableArray *)indexsArr {
    if (!_indexsArr) {
        _indexsArr = [NSMutableArray array];
    }
    return _indexsArr;
}

-(NSMutableArray *)stickersArray {
    if (!_stickersArray) {
        _stickersArray = [NSMutableArray array];
    }
    return _stickersArray;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 15;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, window_width, self.frame.size.height) collectionViewLayout:layout];
        ///修改MHUI
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHStickerCell class] forCellWithReuseIdentifier:@"MHStickerCell"];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"customCollectionCell"];
    }
    return _collectionView;
}

@end
