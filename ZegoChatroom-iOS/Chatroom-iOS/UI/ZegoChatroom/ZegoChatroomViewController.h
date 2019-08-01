//
//  ZegoChatroomViewController.h
//  Chatroom-iOS
//
//  Created by Sky on 2019/3/4.
//  Copyright © 2019 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZegoChatroomInfo,ZegoChatroomLiveConfig;

NS_ASSUME_NONNULL_BEGIN

@interface ZegoChatroomViewController : UIViewController

@property (strong, nonatomic) ZegoChatroomInfo *roomInfo;
@property (strong, nonatomic) ZegoChatroomLiveConfig *config;

@end

NS_ASSUME_NONNULL_END
