//
//  ZegoSoundEffectView.h
//  KTV
//
//  Created by Sky on 2018/11/30.
//  Copyright © 2018 zego. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

extern const NSString *ZegoKTVSoundEffectItemName;//string
extern const NSString *ZegoKTVSoundEffectItemIcon;//string
extern const NSString *ZegoKTVSoundEffectItemSelect;//number:bool
extern const NSString *ZegoKTVSoundEffectItemAction;//block

@interface ZegoSoundEffectView : UIView

@property (copy, nonatomic) void (^enableLoopbackCallback)(BOOL enable);

- (void)setLoopback:(BOOL)enableLoopback;
- (void)setItems:(NSArray <NSDictionary*>*)items;

@end

NS_ASSUME_NONNULL_END
