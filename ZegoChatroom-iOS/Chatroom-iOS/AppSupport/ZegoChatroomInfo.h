//
//  ZegoChatroomInfo.h
//  Chatroom-iOS
//
//  Created by Sky on 2019/4/10.
//  Copyright © 2019 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZegoChatroom/ZegoChatroomUser.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoChatroomInfo : NSObject

@property (strong, nonatomic) ZegoChatroomUser *user;
@property (copy, nonatomic) NSString *roomID;
@property (copy, nonatomic) NSString *roomName;

@end

NS_ASSUME_NONNULL_END
