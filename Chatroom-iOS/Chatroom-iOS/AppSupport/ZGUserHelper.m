//
//  ZGUserHelper.m
//  Chatroom-iOS
//
//  Created by Sky on 2019/2/22.
//  Copyright © 2019 zego. All rights reserved.
//

#import "ZGUserHelper.h"
#import <UIKit/UIKit.h>

const BOOL isTestEnv = YES;
NSString* kZGUserIDKey = @"user_id";
NSString* kZGUserNameKey = @"user_name";

@interface ZGUserHelper ()

@property (class, strong, nonatomic) ZegoChatroomUser *user;
@property (strong, nonatomic) NSMutableArray <NSString*>*logMsgs;

@end

static ZegoChatroomUser *_user = nil;

@implementation ZGUserHelper

+ (NSUserDefaults *)myUserDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:@"group.chatroom-ios"];
}

+ (ZegoChatroomUser *)user {
    if (!_user) {
        NSUserDefaults *ud = [self myUserDefaults];
        NSString *userID = [ud stringForKey:kZGUserIDKey];
        NSString *userName = [ud stringForKey:kZGUserNameKey];
        if (userID.length > 0 && userName.length > 0) {
            ZegoChatroomUser *user = [[ZegoChatroomUser alloc] init];
            user.userID = userID;
            user.userName = userName;
            _user = user;
        }
        else {
            _user = [self generateUser];
        }
    }
    
    return _user;
}

+ (void)setUser:(ZegoChatroomUser *)user {
    _user = user;
}

+ (ZegoChatroomUser *)generateUser {
    NSString *userID = @((long)(NSDate.date.timeIntervalSince1970*1000)).stringValue;
    NSString *deviceName = UIDevice.currentDevice.name ?:@"";
    NSString *userName = [deviceName stringByAppendingString:[NSString stringWithFormat:@"-%d",rand()%100]];
    
    NSUserDefaults *ud = [self myUserDefaults];
    [ud setObject:userID forKey:kZGUserIDKey];
    [ud setObject:userName forKey:kZGUserNameKey];
    [ud synchronize];
    
    ZegoChatroomUser *user = [[ZegoChatroomUser alloc] init];
    user.userID = userID;
    user.userName = userName;
    return user;
}

@end
