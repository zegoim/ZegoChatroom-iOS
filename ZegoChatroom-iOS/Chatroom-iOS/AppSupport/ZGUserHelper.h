//
//  ZGUserHelper.h
//  Chatroom-iOS
//
//  Created by Sky on 2019/2/22.
//  Copyright © 2019 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZegoChatroom/ZegoChatroomUser.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGUserHelper : NSObject

@property (class, strong, nonatomic, readonly) ZegoChatroomUser *user;

@end

NS_ASSUME_NONNULL_END
