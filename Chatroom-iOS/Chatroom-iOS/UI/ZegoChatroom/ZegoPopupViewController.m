//
//  ZegoPopupViewController.m
//  KTV
//
//  Created by Sky on 2018/10/22.
//  Copyright © 2018 zego. All rights reserved.
//

#import "ZegoPopupViewController.h"
#import "Masonry.h"
#import "UIColor+ZegoExtension.h"

@interface ZegoPopupViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) UIView *contentView;

@property (assign ,nonatomic) BOOL isShow;
@property (assign ,nonatomic) BOOL isAnimating;

@end

const CGFloat HeaderRadius = 6.f;

@implementation ZegoPopupViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // view setup
    self.view.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // containerView setup
    self.containerView = [[UIView alloc] init];
    self.containerView.hidden = YES;
    self.containerView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.containerView];
}

#pragma mark - Event Response

- (void)show {
    if (self.isShow || self.isAnimating) {
        return;
    }
    
    self.isAnimating = YES;
    self.containerView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.backgroundColor = ZEGOColorRGBA(0, 0, 0, 0.4);
        self.containerView.transform = CGAffineTransformMakeTranslation(0, -self.containerView.bounds.size.height);
    } completion:^(BOOL finished) {
        self.isShow = YES;
        self.isAnimating = NO;
    }];
}

- (void)dismiss {
    [self dismissWithCallback:nil];
}

- (void)dismissWithCallback:(nullable void (^)(void))callback {
    if (!self.isShow || self.isAnimating) {
        return;
    }
    
    self.isAnimating = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.backgroundColor = UIColor.clearColor;
        self.containerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.isShow = NO;
        self.isAnimating = NO;
        [self dismissViewControllerAnimated:NO completion:callback];
    }];
}

#pragma mark - Public Methods

- (void)setContentView:(UIView *)contentView {
    _contentView = contentView;
    
    CGSize scrSize = UIScreen.mainScreen.bounds.size;
    self.containerView.backgroundColor = [contentView.backgroundColor colorWithAlphaComponent:1];
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        bottomInset = UIApplication.sharedApplication.keyWindow.rootViewController.view.safeAreaInsets.bottom;
    }
    self.containerView.frame = CGRectMake(0, scrSize.height, scrSize.width, contentView.bounds.size.height + HeaderRadius + bottomInset);
    
    [self.containerView addSubview:contentView];
    [contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(HeaderRadius);
        make.left.right.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView).offset(-bottomInset);
    }];
    
    //调整maskView
    CGRect viewRect = CGRectMake(0, 0, scrSize.width, self.containerView.bounds.size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:viewRect byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(HeaderRadius, HeaderRadius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = viewRect;
    maskLayer.path = maskPath.CGPath;
    self.containerView.layer.mask = maskLayer;
    
    [self.view setNeedsUpdateConstraints];
}

#pragma mark - UIGestureRecognizerDelegate

// 不想点击containerView也触发dismiss
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (![gestureRecognizer.view isEqual:touch.view]) {
        return NO;
    }
    return YES;
}

@end
