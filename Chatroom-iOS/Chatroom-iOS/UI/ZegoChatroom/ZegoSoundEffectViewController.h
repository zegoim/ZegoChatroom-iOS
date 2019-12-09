//
//  ZegoSoundEffectViewController.h
//  KTV
//
//  Created by Sky on 2018/11/30.
//  Copyright © 2018 zego. All rights reserved.
//

#import "ZegoPopupViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZegoSoundEffectViewController : ZegoPopupViewController

@property (assign, nonatomic) BOOL singleAudioChannel;

@property (copy, nonatomic) void (^openLoopbackCallback)(BOOL open);

@end

NS_ASSUME_NONNULL_END
