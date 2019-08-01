//
//  ZegoSoundEffectManager.h
//  KTV
//
//  Created by Sky on 2018/11/30.
//  Copyright © 2018 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoSoundEffectManager : NSObject

@property (copy, nonatomic) void (^onEnableLoopbackChange)(BOOL enableLoopback);

@property (assign, nonatomic) BOOL enableLoopback;
@property (assign, nonatomic) int angle;
@property (assign, nonatomic) int audioReverbMode;
@property (assign, nonatomic) float voiceChangeValue;

+ (instancetype)shared;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
