//
//  ZegoRoomInfo+FetchRoomList.m
//  Chatroom-iOS
//
//  Created by Sky on 2019/3/4.
//  Copyright © 2019 zego. All rights reserved.
//

#import "ZegoChatroomInfo+FetchRoomList.h"
#import "ZGAppDefine.h"
#import "ZegoKeyCenter.h"

@implementation ZegoChatroomInfo (FetchRoomList)

+ (void)getRoomInfoList:(void (^)(NSArray<ZegoChatroomInfo*>* _Nullable roomInfos))completion {
    NSString *mainDomain = @"zego.im";
    
    unsigned int appID = ZegoKeyCenter.appID;
    NSString *baseUrl = nil;
    if (IS_TEST_ENV) {
        baseUrl = @"https://test2-liveroom-api.zego.im";
    }
    else {
        baseUrl = [NSString stringWithFormat:@"https://liveroom%u-api.%@", appID, mainDomain];
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/demo/roomlist?appid=%u", baseUrl, appID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSLog(@"URL %@", URL.absoluteString);
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 10;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    __weak typeof(self)weakself = self;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself onRequestComplete:data resp:response err:error completion:completion];
        });
    }];
    
    [task resume];
}

+ (void)onRequestComplete:(NSData *)data resp:(NSURLResponse *)response err:(NSError *)error completion:(void (^)(NSArray<ZegoChatroomInfo *> *roomInfos))completion {
    if (error) {
        NSLog(@"get live room error: %@", error);
        completion(nil);
        return;
    }
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSError *jsonError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"parsing json error");
            completion(nil);
            return;
        }
        else {
            NSUInteger code = [jsonResponse[@"code"] integerValue];
            if (code != 0) {
                return;
            }
            
            NSArray *roomList = jsonResponse[@"data"][@"room_list"];
            NSMutableArray *roomInfoList = [NSMutableArray array];
            
            for (int idx = 0; idx < roomList.count; idx++) {
                ZegoChatroomInfo *info = [ZegoChatroomInfo new];
                NSDictionary *infoDict = roomList[idx];
                info.roomID = infoDict[@"room_id"];
                
                if (info.roomID.length == 0 || ![info.roomID hasPrefix:@"#chatroom-"]) {
                    continue;
                }
                
                info.roomName = infoDict[@"room_name"];
                
                ZegoChatroomUser *user = [ZegoChatroomUser new];
                user.userID = infoDict[@"anchor_id_name"];
                user.userName = infoDict[@"anchor_nick_name"];
                info.user = user;
                
                [roomInfoList addObject:info];
            }
            
            completion(roomInfoList);
        }
    }
}

@end
