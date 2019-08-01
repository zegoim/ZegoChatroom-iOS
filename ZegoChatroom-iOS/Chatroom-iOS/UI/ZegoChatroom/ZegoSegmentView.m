//
//  ZegoSegmentView.m
//  KTV
//
//  Created by Sky on 2018/12/2.
//  Copyright © 2018 zego. All rights reserved.
//

#import "ZegoSegmentView.h"
#import "Masonry.h"

#define SegmentHeight 44
#define SegmentFixedWidth 100
#define TitleFont [UIFont systemFontOfSize:16]
#define UnderlineHeight 2
#define UnderlineFixedWidth 50

@interface ZegoSegmentView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSMutableArray <UIButton *>*titleButtons;
@property (nonatomic, strong) UIButton *selectedButton;

@end

@implementation ZegoSegmentView

- (void)dealloc {
    _segmentContainView.delegate = nil;
    _pageContainView.delegate = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        _titleButtons = [NSMutableArray array];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _segmentContainView = [[UIScrollView alloc]init];
    _segmentContainView.bounces = NO;
    _segmentContainView.showsVerticalScrollIndicator = NO;
    _segmentContainView.showsHorizontalScrollIndicator = NO;
    _seperatorView = [[UIView alloc]init];
    _seperatorView.backgroundColor = [UIColor lightGrayColor];
    _underLineView = [[UIView alloc]init];
    _underLineView.backgroundColor = [UIColor blackColor];
    _pageContainView = [[UIScrollView alloc]init];
    _pageContainView.bounces = NO;
    _pageContainView.showsVerticalScrollIndicator = NO;
    _pageContainView.showsHorizontalScrollIndicator = NO;
    _pageContainView.pagingEnabled = YES;
    _pageContainView.delegate = self;
    
    [self addSubview:_segmentContainView];
    [self addSubview:_seperatorView];
    [self.segmentContainView addSubview:_underLineView];
    [self addSubview:_pageContainView];
}

- (void)updateConstraints {
    [self.segmentContainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(self.segmentHeight > 0 ? self.segmentHeight:SegmentHeight);
    }];
    [self.seperatorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.segmentContainView);
        make.height.mas_equalTo(1);
    }];
    [self.pageContainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentContainView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
    
    [super updateConstraints];
}

- (void)updateViewWithTitleArray:(NSArray *)titles {
    _titles = titles;
    
    //remove all buttons
    for (UIButton *button in self.titleButtons) {
        [button removeFromSuperview];
    }
    [self.titleButtons removeAllObjects];
    
    CGFloat btnOrigionX = 0.f;
    CGFloat segmentH = _segmentHeight > 0 ? _segmentHeight:SegmentHeight;
    CGFloat segmentW = _segmentFixedWidth > 0 ? _segmentFixedWidth:SegmentFixedWidth;
    
    for (int i = 0; i < titles.count; ++i) {
        UIButton *segmentBtn = [[UIButton alloc]init];
        segmentBtn.titleLabel.font = self.titleFont ?:TitleFont;
        [segmentBtn setTitleColor:self.titleColor ?:[UIColor blackColor] forState:UIControlStateNormal];
        [segmentBtn setTitleColor:self.selectedColor ?:[UIColor blackColor] forState:UIControlStateSelected];
        
        id title = titles[i];
        if ([title isKindOfClass:NSString.class]) {
            [segmentBtn setTitle:title forState:UIControlStateNormal];
        }else if ([title isKindOfClass:NSArray.class]) {
            [segmentBtn setAttributedTitle:title[0] forState:UIControlStateNormal];
            [segmentBtn setAttributedTitle:title[1] forState:UIControlStateSelected];
        }
        
        [segmentBtn sizeToFit];
        segmentBtn.tag = i;
        [segmentBtn addTarget:self action:@selector(didClickSegmentButton:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect btnRect = segmentBtn.bounds;
        switch (self.segmentMode) {
            case ZegoSegmentViewSegmentModeAccordingTitle:{
                btnRect = CGRectMake(btnOrigionX, 0, btnRect.size.width + 2*_segmentSpace, segmentH);
            }
                break;
            case ZegoSegmentViewSegmentModeFixedWidth:{
                btnRect = CGRectMake(btnOrigionX, 0, segmentW, segmentH);
            }
                break;
        }
        btnOrigionX += btnRect.size.width;
        
        segmentBtn.frame = btnRect;
        [self.titleButtons addObject:segmentBtn];
        [self.segmentContainView addSubview:segmentBtn];
    }
    
    self.segmentContainView.contentSize = CGSizeMake(btnOrigionX, 0);
    self.segmentContainView.contentOffset = CGPointZero;
    self.pageContainView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width*titles.count, 0);
    self.pageContainView.contentOffset = CGPointZero;
    if (self.titleButtons.count > 0) {
        UIButton *button = self.titleButtons[0];
        button.selected = YES;
        self.selectedButton = button;
        
        self.underLineView.bounds = CGRectMake(0, 0, (self.underlineMode == ZegoSegmentViewUnderLineModeAccordingTitle ? button.titleLabel.bounds.size.width:(_underlineFixedWidth > 0 ? _underlineFixedWidth:UnderlineFixedWidth)), UnderlineHeight);
        self.underLineView.center = CGPointMake(button.center.x, segmentH - UnderlineHeight*.5f - 1);
    }else {
        self.underLineView.bounds = CGRectZero;
    }
}

- (void)refreshTitlesWithTitleArray:(NSArray *)titles {
    NSInteger count = MIN(self.titleButtons.count, titles.count);
    for (int i = 0; i < count; ++i) {
        UIButton *titleBtn = self.titleButtons[i];
        id title = titles[i];
        if ([title isKindOfClass:NSString.class]) {
            [titleBtn setTitle:title forState:UIControlStateNormal];
        }else if ([title isKindOfClass:NSArray.class]) {
            [titleBtn setAttributedTitle:title[0] forState:UIControlStateNormal];
            [titleBtn setAttributedTitle:title[1] forState:UIControlStateSelected];
        }
    }
}

#pragma mark - Action

- (void)didClickSegmentButton:(UIButton *)sender {
    NSInteger index = sender.tag;
    
    if ([self.delegate respondsToSelector:@selector(didClickSegmentButton:)]) {
        [self.delegate didClickSegmentButton:sender];
    }
    if ([self.delegate respondsToSelector:@selector(willSwitchToIndex:)]) {
        [self.delegate willSwitchToIndex:index];
    }
    
    self.index = index;
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        return;
    }
    [self refreshContents];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self refreshContents];
}

- (void)refreshContents {
    CGFloat scrW = [UIScreen mainScreen].bounds.size.width;
    NSInteger pageIndex = (self.pageContainView.contentOffset.x/scrW)+.5f;
    self.index = pageIndex;
}

- (void)setIndex:(NSInteger)index {
    if (index > self.titleButtons.count-1 || index == _index) {
        return;
    }
    _index = index;
    
    if ([self.delegate respondsToSelector:@selector(willSwitchToIndex:)]) {
        [self.delegate willSwitchToIndex:index];
    }
    
    UIButton *button = self.titleButtons[index];
    self.selectedButton.selected = NO;
    button.selected = YES;
    self.selectedButton = button;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.pageContainView.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width * self.index, 0);
        self.underLineView.bounds = CGRectMake(0, 0, (self.underlineMode == ZegoSegmentViewUnderLineModeAccordingTitle ? button.titleLabel.bounds.size.width:(self.underlineFixedWidth > 0 ? self.underlineFixedWidth:UnderlineFixedWidth)), UnderlineHeight);
        self.underLineView.center = CGPointMake(button.center.x, (self.segmentHeight > 0 ? self.segmentHeight:SegmentHeight) - UnderlineHeight*.5f);
    }];
}

@end
