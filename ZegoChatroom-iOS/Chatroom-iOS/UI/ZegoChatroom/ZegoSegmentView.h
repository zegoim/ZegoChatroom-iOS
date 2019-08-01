//
//  ZegoSegmentView.h
//  KTV
//
//  Created by Sky on 2018/12/2.
//  Copyright © 2018 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZegoSegmentViewUnderLineMode) {
    ZegoSegmentViewUnderLineModeAccordingTitle,        //下划线随着title的宽度变化
    ZegoSegmentViewUnderLineModeFixedWidth,            //下划线等于给定的宽度
};

typedef NS_ENUM(NSInteger, ZegoSegmentViewSegmentTitleMode) {
    ZegoSegmentViewSegmentModeAccordingTitle,          //单个选项卡宽度随着title变化
    ZegoSegmentViewSegmentModeFixedWidth,              //单个选项卡等于给定的宽度
};

@protocol ZegoSegmentViewDelegate <NSObject>

@optional
- (void)didClickSegmentButton:(UIButton *)button;
- (void)willSwitchToIndex:(NSInteger)index;

@end

@interface ZegoSegmentView : UIView


@property (nonatomic, strong) UIScrollView *segmentContainView;
@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, strong) UIView *seperatorView;
@property (nonatomic, strong) UIScrollView *pageContainView;

@property (nonatomic, assign) ZegoSegmentViewUnderLineMode underlineMode;
@property (nonatomic, assign) CGFloat underlineFixedWidth;
@property (nonatomic, assign) ZegoSegmentViewSegmentTitleMode segmentMode;
@property (nonatomic, assign) CGFloat segmentFixedWidth;

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, assign) CGFloat segmentHeight;
@property (nonatomic, assign) CGFloat segmentSpace;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, weak) id delegate;

///titles中仅支持NSString及NSAttrbutedString的数组([未选中状态下的attr,选中状态下的attr])
- (void)updateViewWithTitleArray:(NSArray *)titles;
///titles中仅支持NSString及NSAttrbutedString的数组(包含2个元素，[未选中状态下的attr,选中状态下的attr])
- (void)refreshTitlesWithTitleArray:(NSArray *)titles;

@end

NS_ASSUME_NONNULL_END
