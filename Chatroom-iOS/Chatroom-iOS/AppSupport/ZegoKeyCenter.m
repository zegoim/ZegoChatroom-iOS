//
//  ZegoKeyCenter.m
//  Chatroom-iOS
//
//  Created by Sky on 2019/6/10.
//  Copyright © 2019 zego. All rights reserved.
//

#import "ZegoKeyCenter.h"

@implementation ZegoKeyCenter

+ (unsigned int)appID {
    // 从即构主页申请
    return <#Your App ID#>;
}

+ (NSData *)appSignKey {
    // 从即构主页申请
    Byte signkey[] = <#Your App Sign#>;
    
    NSData* sign = [NSData dataWithBytes:signkey length:32];
    return sign;
}

@end
