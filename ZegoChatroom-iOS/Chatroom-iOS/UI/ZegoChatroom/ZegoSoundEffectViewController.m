//
//  ZegoSoundEffectViewController.m
//  KTV
//
//  Created by Sky on 2018/11/30.
//  Copyright © 2018 zego. All rights reserved.
//

#import "ZegoSoundEffectViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "UIView+ZegoExtension.h"
#import "UIColor+ZegoExtension.h"
#import "ZegoSegmentView.h"
#import "ZegoSoundEffectView.h"
#import "ZegoSoundEffectManager.h"
#import "ZegoHudManager.h"

@interface ZegoSoundEffectViewController ()

@property (strong, nonatomic) ZegoSegmentView *content;
@property (strong, nonatomic) ZegoSoundEffectView *effectView1;
@property (strong, nonatomic) ZegoSoundEffectView *effectView2;
@property (strong, nonatomic) ZegoSoundEffectView *effectView3;

@end

@implementation ZegoSoundEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupManager];
    [self setupContentView];
}

- (void)setupManager {
    __weak typeof(self)weakself = self;
    ZegoSoundEffectManager.shared.onEnableLoopbackChange = ^(BOOL enableLoopback) {
        __strong typeof(weakself)strongself = weakself;
        if (!strongself) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongself.effectView1 setLoopback:enableLoopback];
            [strongself.effectView2 setLoopback:enableLoopback];
            [strongself.effectView3 setLoopback:enableLoopback];
        });
    };
}

- (void)setupContentView {
    __weak typeof(self)weakself = self;
    
    CGSize scrSize = UIScreen.mainScreen.bounds.size;
    CGFloat contentHeight = 244;
    ZegoSegmentView *content = [[ZegoSegmentView alloc] init];
    content.backgroundColor = UIColor.whiteColor;
    content.frame = CGRectMake(0, 0, scrSize.width, contentHeight);
    content.segmentMode = ZegoSegmentViewSegmentModeFixedWidth;
    content.segmentFixedWidth = UIScreen.mainScreen.bounds.size.width/3;
    content.underlineMode = ZegoSegmentViewUnderLineModeFixedWidth;
    content.underlineFixedWidth = 15;
    content.underLineView.backgroundColor = UIColor.themeBlue;
    content.seperatorView.backgroundColor = ZEGOColorHEX(0xf0f0f0);
    content.selectedColor = UIColor.themeBlue;
    content.titleColor = ZEGOColorHEX(0x333333);
    content.titleFont = [UIFont systemFontOfSize:16];
    [content updateViewWithTitleArray:@[@"变声",@"立体音",@"混响"]];
    
    ZegoSoundEffectView *effectView1 = [[ZegoSoundEffectView alloc] init];
    [effectView1 setLoopback:ZegoSoundEffectManager.shared.enableLoopback];
    [effectView1 setItems:self.effectItems1];
    effectView1.enableLoopbackCallback = ^(BOOL enable) {
        [weakself setLoopbackEnable:enable];
    };
    
    ZegoSoundEffectView *effectView2 = [[ZegoSoundEffectView alloc] init];
    [effectView2 setLoopback:ZegoSoundEffectManager.shared.enableLoopback];
    [effectView2 setItems:self.effectItems2];
    effectView2.enableLoopbackCallback = ^(BOOL enable) {
        [weakself setLoopbackEnable:enable];
    };
    
    ZegoSoundEffectView *effectView3 = [[ZegoSoundEffectView alloc] init];
    [effectView3 setLoopback:ZegoSoundEffectManager.shared.enableLoopback];
    [effectView3 setItems:self.effectItems3];
    effectView3.enableLoopbackCallback = ^(BOOL enable) {
        [weakself setLoopbackEnable:enable];
    };
    
    [content.pageContainView addSubview:effectView1];
    [content.pageContainView addSubview:effectView2];
    [content.pageContainView addSubview:effectView3];
    
    [effectView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(content.pageContainView);
        make.width.equalTo(content.mas_width);
        make.height.equalTo(content.pageContainView);
    }];
    [effectView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(effectView1.mas_right);
        make.top.bottom.equalTo(content.pageContainView);
        make.width.equalTo(content.mas_width);
    }];
    [effectView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(effectView2.mas_right);
        make.top.bottom.equalTo(content.pageContainView);
        make.width.equalTo(content.mas_width);
        make.right.equalTo(content.pageContainView);
    }];
    
    self.content = content;
    self.effectView1 = effectView1;
    self.effectView2 = effectView2;
    self.effectView3 = effectView3;
    
    [self setContentView:content];
}

- (void)setLoopbackEnable:(BOOL)enable {
    if (!self.isHeadsetPluggedIn) {
        NSString *typeString = [NSString stringWithFormat:@"音效试听需要带上耳机才可使用"];
        [ZegoHudManager showMessage:typeString];
        return;
    }
    ZegoSoundEffectManager.shared.enableLoopback = enable;
    
    if (self.openLoopbackCallback) {
        self.openLoopbackCallback(enable);
    }
}


#pragma mark - Access

- (NSArray <NSDictionary*>*)effectItems1 {
    __weak typeof(self)weakself = self;
    NSDictionary *item1 = @{ZegoKTVSoundEffectItemName:@"无",
                            ZegoKTVSoundEffectItemIcon:@"ktv_sound_none",
                            ZegoKTVSoundEffectItemSelect:@(ZegoSoundEffectManager.shared.voiceChangeValue == 0),
                            ZegoKTVSoundEffectItemAction:[^{
                                ZegoSoundEffectManager.shared.voiceChangeValue = 0;
                                [weakself.effectView1 setItems:weakself.effectItems1];
                            } copy],
                            };
    NSDictionary *item2 = @{ZegoKTVSoundEffectItemName:@"萝莉",
                            ZegoKTVSoundEffectItemIcon:@"ktv_sound_child",
                            ZegoKTVSoundEffectItemSelect:@(ZegoSoundEffectManager.shared.voiceChangeValue == 8.0),
                            ZegoKTVSoundEffectItemAction:[^{
                                ZegoSoundEffectManager.shared.voiceChangeValue = 8.0;
                                [weakself.effectView1 setItems:weakself.effectItems1];
                            } copy],
                            };
    NSDictionary *item3 = @{ZegoKTVSoundEffectItemName:@"大叔",
                            ZegoKTVSoundEffectItemIcon:@"ktv_sound_man",
                            ZegoKTVSoundEffectItemSelect:@(ZegoSoundEffectManager.shared.voiceChangeValue == -3.0),
                            ZegoKTVSoundEffectItemAction:[^{
                                ZegoSoundEffectManager.shared.voiceChangeValue = -3.0;
                                [weakself.effectView1 setItems:weakself.effectItems1];
                            } copy],
                            };
    
    return @[item1,item2,item3];
}

- (NSArray <NSDictionary*>*)effectItems2 {
    __weak typeof(self)weakself = self;
    
    NSDictionary *item1 = @{ZegoKTVSoundEffectItemName:@"无",
                            ZegoKTVSoundEffectItemIcon:@"ktv_sound_none",
                            ZegoKTVSoundEffectItemSelect:@(ZegoSoundEffectManager.shared.angle == 90),
                            ZegoKTVSoundEffectItemAction:[^{
                                ZegoSoundEffectManager.shared.angle = 90;
                                [weakself.effectView2 setItems:weakself.effectItems2];
                            } copy],
                            };
    NSDictionary *item2 = @{ZegoKTVSoundEffectItemName:@"左侧声",
                            ZegoKTVSoundEffectItemIcon:@"ktv_sound_left",
                            ZegoKTVSoundEffectItemSelect:@(ZegoSoundEffectManager.shared.angle == 120),
                            ZegoKTVSoundEffectItemAction:[^{
                                if (weakself.singleAudioChannel) {
                                    [ZegoHudManager showMessage:@"单声道无法使用立体声音效"];
                                    return;
                                }
                            
                                ZegoSoundEffectManager.shared.angle = 120;
                                [weakself.effectView2 setItems:weakself.effectItems2];
                            } copy],
                            };
    NSDictionary *item3 = @{ZegoKTVSoundEffectItemName:@"右侧声",
                            ZegoKTVSoundEffectItemIcon:@"ktv_sound_right",
                            ZegoKTVSoundEffectItemSelect:@(ZegoSoundEffectManager.shared.angle == 60),
                            ZegoKTVSoundEffectItemAction:[^{
                                if (weakself.singleAudioChannel) {
                                    [ZegoHudManager showMessage:@"单声道无法使用立体声音效"];
                                    return;
                                }
                                
                                ZegoSoundEffectManager.shared.angle = 60;
                                [weakself.effectView2 setItems:weakself.effectItems2];
                            } copy],
                            };
    
    return @[item1,item2,item3];
}

- (NSArray <NSDictionary*>*)effectItems3 {
    __weak typeof(self)weakself = self;
    
    NSDictionary *item1 = @{ZegoKTVSoundEffectItemName:@"无",
                            ZegoKTVSoundEffectItemIcon:@"ktv_sound_none",
                            ZegoKTVSoundEffectItemSelect:@(ZegoSoundEffectManager.shared.audioReverbMode == -1),
                            ZegoKTVSoundEffectItemAction:[^{
                                ZegoSoundEffectManager.shared.audioReverbMode = -1;
                                [weakself.effectView3 setItems:weakself.effectItems3];
                            } copy],
                            };
    NSDictionary *item2 = @{ZegoKTVSoundEffectItemName:@"大堂场景",
                            ZegoKTVSoundEffectItemIcon:@"ktv_sound_club",
                            ZegoKTVSoundEffectItemSelect:@(ZegoSoundEffectManager.shared.audioReverbMode == 1),
                            ZegoKTVSoundEffectItemAction:[^{
                                ZegoSoundEffectManager.shared.audioReverbMode = 1;
                                [weakself.effectView3 setItems:weakself.effectItems3];
                            } copy],
                            };
    NSDictionary *item3 = @{ZegoKTVSoundEffectItemName:@"山谷场景",
                            ZegoKTVSoundEffectItemIcon:@"ktv_sound_valley",
                            ZegoKTVSoundEffectItemSelect:@(ZegoSoundEffectManager.shared.audioReverbMode == 3),
                            ZegoKTVSoundEffectItemAction:[^{
                                ZegoSoundEffectManager.shared.audioReverbMode = 3;
                                [weakself.effectView3 setItems:weakself.effectItems3];
                            } copy],
                            };
    
    return @[item1,item2,item3];
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

@end
