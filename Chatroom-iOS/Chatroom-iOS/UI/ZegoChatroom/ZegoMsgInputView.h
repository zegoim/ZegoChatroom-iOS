//
//  ZegoMsgInputView.h
//  KTV
//
//  Created by Sky on 2018/10/26.
//  Copyright © 2018 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoMsgInputView : UIView

@property (copy, nonatomic) void (^msgCallback)(NSString *msg);

- (void)startInput;
- (BOOL)isEditing;

@end

NS_ASSUME_NONNULL_END
