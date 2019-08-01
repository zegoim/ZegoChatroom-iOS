//
//  ZegoSoundEffectManager.m
//  KTV
//
//  Created by Sky on 2018/11/30.
//  Copyright © 2018 zego. All rights reserved.
//

#import "ZegoSoundEffectManager.h"
#import <ZegoChatroom/ZegoChatroom.h>

@implementation ZegoSoundEffectManager

+ (instancetype)shared {
    static ZegoSoundEffectManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance reset];
    });
    
    return instance;
}

- (void)reset {
    self.voiceChangeValue = 0;
    self.enableLoopback = NO;
    self.angle = 90;
    self.audioReverbMode = -1;
}

- (void)setVoiceChangeValue:(float)voiceChangeValue {
    if (_voiceChangeValue == voiceChangeValue) {
        return;
    }
    _voiceChangeValue = voiceChangeValue;
    ZegoChatroom.shared.voiceChangeValue = voiceChangeValue;
}

- (void)setAngle:(int)angle {
    if (_angle == angle) {
        return;
    }
    _angle = angle;
    ZegoChatroom.shared.virtualStereoAngle = angle;
}

- (void)setAudioReverbMode:(int)audioReverbMode {
    if (_audioReverbMode == audioReverbMode) {
        return;
    }
    _audioReverbMode = audioReverbMode;
    ZegoChatroomAudioReverbConfig *config;
    switch (audioReverbMode) {
        case 0:
            config = [ZegoChatroomAudioReverbConfig configWithModeRoom];
            break;
        case 1:
            config = [ZegoChatroomAudioReverbConfig configWithModeLargeRoom];
            break;
        case 2:
            config = [ZegoChatroomAudioReverbConfig configWithModeConcertHall];
            break;
        case 3:
            config = [ZegoChatroomAudioReverbConfig configWithModeValley];
            break;
        default:
            break;
    }
    ZegoChatroom.shared.audioReverbConfig = config;
}

- (void)setEnableLoopback:(BOOL)enableLoopback {
    if (_enableLoopback == enableLoopback) {
        return;
    }
    _enableLoopback = enableLoopback;
    
    ZegoChatroom.shared.enableLoopback = enableLoopback;
    if (self.onEnableLoopbackChange) {
        self.onEnableLoopbackChange(enableLoopback);
    }
}


@end
