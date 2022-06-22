//
//  MHStickerCell.m


#import "MHStickerCell.h"
#import "StickerDataListModel.h"
#import "UIImageView+WebCache.h"
#import "MHBeautyParams.h"

@interface MHStickerIndicatorView ()
{
    CALayer *_animationLayer;
}

@end

@implementation MHStickerIndicatorView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tintColor = [UIColor whiteColor];
        //_size = 25.0f;
        [self commonInit];
    }
    return self;
}

- (id)initWithTintColor:(UIColor *)tintColor size:(CGFloat)size {
    self = [super init];
    if (self) {
        _size = size;
        _tintColor = tintColor;
        [self commonInit];
    }
    return self;
    
}

#pragma mark -
#pragma mark Methods

- (void)commonInit {
    self.userInteractionEnabled = NO;
    self.hidden = YES;
    _animationLayer = [[CALayer alloc] init];
    [self.layer addSublayer:_animationLayer];
    
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

- (void)setupAnimation {
    _animationLayer.sublayers = nil;
    
    [self setupAnimationInLayer:_animationLayer withSize:CGSizeMake(_size, _size) tintColor:_tintColor];
    _animationLayer.speed = 0.0f;
}

- (void)setupAnimationInLayer:(CALayer *)layer withSize:(CGSize)size tintColor:(UIColor *)tintColor {
    CGFloat duration = 0.6f;
    
    // Rotate animation
    CAKeyframeAnimation *rotateAnimation = [self createKeyframeAnimationWithKeyPath:@"transform.rotation.z"];
    
    rotateAnimation.values = @[@0, @M_PI, @(2 * M_PI)];
    rotateAnimation.duration = duration;
    rotateAnimation.repeatCount = HUGE_VALF;
    
    
    // Draw ball clip
    CAShapeLayer *circle = [CAShapeLayer layer];
    UIBezierPath *circlePath =
    [UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width / 2, size.height / 2) radius:size.width / 2 startAngle:1.5 * M_PI endAngle:M_PI clockwise:true];
    
    circle.path = circlePath.CGPath;
    circle.lineWidth = 2;
    circle.fillColor = nil;
    circle.strokeColor = tintColor.CGColor;
    
    circle.frame =
    CGRectMake(0, 0, size.width, size.height);
    [circle addAnimation:rotateAnimation forKey:@"animation"];
    [layer addSublayer:circle];
}

- (CAKeyframeAnimation *)createKeyframeAnimationWithKeyPath:(NSString *)keyPath {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.removedOnCompletion = NO;
    return animation;
}

- (void)startAnimating {
    if (!_animationLayer.sublayers) {
        [self setupAnimation];
    }
    self.hidden = NO;
    _animationLayer.speed = 1.0f;
    _animating = YES;
}

- (void)stopAnimating {
    _animationLayer.speed = 0.0f;
    _animating = NO;
    self.hidden = YES;
}

#pragma mark Setters
- (void)setSize:(CGFloat)size {
    if (_size != size) {
        _size = size;
        [self setupAnimation];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    if (![_tintColor isEqual:tintColor]) {
        _tintColor = tintColor;
        
        CGColorRef tintColorRef = tintColor.CGColor;
        for (CALayer *sublayer in _animationLayer.sublayers) {
            sublayer.backgroundColor = tintColorRef;
            
            if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
                CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
                shapeLayer.strokeColor = tintColorRef;
                shapeLayer.fillColor = tintColorRef;
            }
        }
    }
}
#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _animationLayer.frame = self.bounds;
    
    BOOL animating = _animating;
    
    if (animating)
        [self stopAnimating];
    
    [self setupAnimation];
    
    if (animating)
        [self startAnimating];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(_size, _size);
}
@end



@interface MHStickerCell ()
@property (nonatomic, strong) UIImageView *stickerView;
@property(nonatomic, strong) MHStickerIndicatorView *indicatorView;

@end
@implementation MHStickerCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.selectedImgView];
        [self addSubview:self.stickerView];
        [self addSubview:self.downloadImg];
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void)setSticker:(StickerDataListModel *)sticker index:(NSInteger)index {
    _listModel = sticker;
    if (index == 0) {
        if (self.indicatorView.animating == YES) {
            [self.indicatorView stopAnimating];
        }
    }
    self.stickerView.image = [UIImage imageNamed:sticker.thumb];
    self.downloadImg.hidden = YES;
}

- (void)setListModel:(StickerDataListModel *)listModel {
    if (!listModel) {
        return;
    }
    _listModel = listModel;
    NSString * thumb = listModel.thumb;
    if (!IsString(thumb)) {
        return;
    }
    [self.stickerView sd_setImageWithURL:[NSURL URLWithString:thumb]];
    self.selectedImgView.hidden = !listModel.isSelected;
    if (listModel.is_downloaded.boolValue == YES) {
        if (self.indicatorView.animating == YES) {
            [self.indicatorView stopAnimating];
        }
        self.downloadImg.hidden = YES;
        listModel.downloadState = MHStickerDownloadStateDownoadDone;
        } else {
            
            if (listModel.downloadState == MHStickerDownloadStateDownoading) {
                self.downloadImg.hidden = YES;
                if (self.indicatorView.animating != YES) {
                    [self.indicatorView startAnimating];
                }
            } else {
                if (self.indicatorView.animating == YES) {
                    [self.indicatorView stopAnimating];
                }
                
                listModel.downloadState = MHStickerDownloadStateDownoadNot;
                self.downloadImg.hidden = NO;
                
            }
            
        }
}

/**
 动画
 */
- (void)startDownload {
    self.listModel.downloadState = MHStickerDownloadStateDownoading;
    self.downloadImg.hidden = YES;
    [self.indicatorView startAnimating];
}

- (void)stopDownLoad {
    self.listModel.downloadState = MHStickerDownloadStateDownoadDone;
    self.downloadImg.hidden = YES;
    [self.indicatorView stopAnimating];
}

#pragma mark - lazy
- (UIImageView *)selectedImgView {
    if (!_selectedImgView) {
        UIImage *img = BundleImg(@"ic_border_selected");
        _selectedImgView = [[UIImageView alloc] initWithImage:img];
        _selectedImgView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _selectedImgView.hidden = YES;
    }
    return _selectedImgView;
}

- (UIImageView *)stickerView {
    if (!_stickerView) {
        _stickerView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 45)/2, (self.frame.size.height - 45)/2, 45, 45)];
    }
    return _stickerView;
}

- (UIImageView *)downloadImg {
    if (!_downloadImg) {
        UIImage *img = BundleImg(@"stickerDownload");
        _downloadImg = [[UIImageView alloc] initWithImage:img];
        _downloadImg.frame = CGRectMake(_stickerView.frame.size.width - 13, _stickerView.frame.size.height - 13, 13, 13);
    }
    return _downloadImg;
}

- (MHStickerIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[MHStickerIndicatorView alloc] initWithTintColor:[UIColor whiteColor] size:25];
        _indicatorView.frame = CGRectMake((self.frame.size.width - 25)/2, (self.frame.size.height - 25)/2, 25, 25);
    }
    return _indicatorView;
}
@end
