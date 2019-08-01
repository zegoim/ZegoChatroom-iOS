//
//  ZegoCreateRoomViewController.m
//  Chatroom-iOS
//
//  Created by Sky on 2019/3/4.
//  Copyright © 2019 zego. All rights reserved.
//

#import "ZegoCreateRoomViewController.h"
#import "ZegoChatroomViewController.h"
#import "ZegoChatroomInfo.h"
#import "ZGUserHelper.h"
#import <ZegoChatroom/ZegoChatroomLiveConfig.h>

@interface ZegoCreateRoomViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTxf;
@property (weak, nonatomic) IBOutlet UITextField *bitrateTxf;
@property (weak, nonatomic) IBOutlet UITextField *audioChannelTxf;
@property (weak, nonatomic) IBOutlet UITextField *latencyTxf;

@end

@implementation ZegoCreateRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.nameTxf.isEditing || self.bitrateTxf.isEditing || self.audioChannelTxf.isEditing || self.latencyTxf.isEditing) {
        [self.view endEditing:YES];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createRoom {
    NSString *roomID = [NSString stringWithFormat:@"%@-%ld", @"#chatroom", (long)NSDate.date.timeIntervalSince1970];
    NSString *roomName = self.nameTxf.text.length ? self.nameTxf.text:ZGUserHelper.user.userName;
    ZegoChatroomInfo *info = [ZegoChatroomInfo new];
    info.roomID = roomID;
    info.roomName = roomName;
    info.user = ZGUserHelper.user;
    ZegoChatroomLiveConfig *config = [ZegoChatroomLiveConfig liveConfigOf:kZegoChatroomAudioProfileMusicStandard];
    
    //私有属性
    [config setValue:@(self.bitrateTxf.text.intValue) forKey:@"bitrate"];
    [config setValue:@(self.audioChannelTxf.text.intValue) forKey:@"audioChannelCount"];
    [config setValue:@(self.latencyTxf.text.intValue) forKey:@"latencyMode"];
    
    UIViewController *presentingViewController = self.presentingViewController;
    
    [self dismissViewControllerAnimated:YES completion:^{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ZegoChatroomViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ZegoChatroomViewController"];
        
        vc.roomInfo = info;
        vc.config = config;
        
        [presentingViewController.navigationController pushViewController:vc animated:YES];
    }];
}

@end
