//
//  ZegoKeyCenter.h
//  Chatroom-iOS
//
//  Created by Sky on 2019/6/10.
//  Copyright © 2019 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 本示例不提供 ZegoKeyCenter.m 需要用户自行实现，对象提供两个函数，如
 
 @implementation ZegoKeyCenter
 
 + (unsigned int)appID {
    // 从即构主页申请
    return 123456789;
 }
 
 + (NSData *)appSignKey {
     // 从即构主页申请
     Byte signkey[] = {0x00,0x01,0x02,0x03,0xb2,0xf2,0x13,0x70,
                       0x00,0x01,0x02,0x03,0xb2,0xf2,0x13,0x70,
                       0x00,0x01,0x02,0x03,0xb2,0xf2,0x13,0x70,
                       0x00,0x01,0x02,0x03,0xb2,0xf2,0x13,0x70,};
 
     NSData* sign = [NSData dataWithBytes:signkey length:32];
     return sign;
 }
 
 @end
 */

NS_ASSUME_NONNULL_BEGIN

@interface ZegoKeyCenter : NSObject

+ (unsigned int)appID;
+ (NSData *)appSignKey;

@end

NS_ASSUME_NONNULL_END
