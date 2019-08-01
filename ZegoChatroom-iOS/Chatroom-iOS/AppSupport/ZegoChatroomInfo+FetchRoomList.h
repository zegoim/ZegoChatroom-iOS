//
//  ZegoRoomInfo+FetchRoomList.h
//  Chatroom-iOS
//
//  Created by Sky on 2019/3/4.
//  Copyright © 2019 zego. All rights reserved.
//

#import "ZegoChatroomInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZegoChatroomInfo (FetchRoomList)

+ (void)getRoomInfoList:(void (^)(NSArray<ZegoChatroomInfo*>* _Nullable roomInfos))completion;

@end

NS_ASSUME_NONNULL_END
