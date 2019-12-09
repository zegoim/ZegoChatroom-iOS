//
//  ZegoPopupViewController.h
//  KTV
//
//  Created by Sky on 2018/10/22.
//  Copyright © 2018 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 带阴影蒙版的上滑弹框VC容器（ps:present时最好不设置动画然后调用show方法）
 */
@interface ZegoPopupViewController : UIViewController

- (void)setContentView:(UIView *)contentView;

- (void)show;
- (void)dismiss;
- (void)dismissWithCallback:(nullable void(^)(void))callback;

@end

NS_ASSUME_NONNULL_END
