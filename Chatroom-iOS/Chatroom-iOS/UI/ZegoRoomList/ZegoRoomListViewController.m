//
//  ZegoRoomListViewController.m
//  Chatroom-iOS
//
//  Created by Sky on 2019/3/4.
//  Copyright © 2019 zego. All rights reserved.
//

#import "ZegoRoomListViewController.h"
#import <ZegoChatroom/ZegoChatroomLiveConfig.h>
#import "ZegoChatroomInfo+FetchRoomList.h"
#import "UIViewController+TopPresent.h"
#import "ZGUserHelper.h"
#import "ZegoChatroomViewController.h"
#import "ZegoCreateRoomViewController.h"

@interface ZGRoomListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *descLbl;
@end

@implementation ZGRoomListCell

- (void)setTitle:(NSString *)title desc:(NSString *)desc {
    self.titleLbl.text = title;
    self.descLbl.text = desc;
}

@end


@interface ZGRoomListEmptyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@end

@implementation ZGRoomListEmptyCell

- (void)setButtonTitle:(NSString *)title target:(id)target action:(SEL)action {
    [self.titleBtn setTitle:title forState:UIControlStateNormal];
    [self.titleBtn removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    
    if (target) {
        [self.titleBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

@end


typedef NS_ENUM(NSInteger, ZegoStatus) {
    kZegoStatusNone,
    kZegoStatusFetching,
    kZegoStatusFetchSuccess,
    kZegoStatusFetchFail,
};

@interface ZegoRoomListViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSArray <ZegoChatroomInfo*>*roomList;

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (assign, nonatomic) ZegoStatus status;

@end

@implementation ZegoRoomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fetchRoomList];        
    });
}

- (void)setupUI {
    self.navigationController.navigationBarHidden = YES;
    self.welcomeLabel.text = [NSString stringWithFormat:@"欢迎您，%@",ZGUserHelper.user.userName];
    
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    [rc addTarget:self action:@selector(fetchRoomList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    self.tableView.tableHeaderView = rc;
}

- (void)fetchRoomList {
    if (self.status == kZegoStatusFetching) {
        return;
    }
    
    self.status = kZegoStatusFetching;
    
    __weak typeof(self)weakself = self;
    [ZegoChatroomInfo getRoomInfoList:^(NSArray<ZegoChatroomInfo *> * _Nullable roomInfos) {
        __strong typeof(weakself)self = weakself;
        
        self.roomList = roomInfos;
        self.status = roomInfos ? kZegoStatusFetchSuccess:kZegoStatusFetchFail;
        [self.refreshControl endRefreshing];
    }];
}

- (void)enterRoom:(ZegoChatroomInfo *)info {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZegoChatroomViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ZegoChatroomViewController"];
    
    vc.roomInfo = info;
    ZegoChatroomLiveConfig *config = [ZegoChatroomLiveConfig liveConfigOf:kZegoChatroomAudioProfileMusicStandard];
    NSArray<NSString*>* parts = [info.roomName componentsSeparatedByString:@"_"];
    if (parts.count >= 4) {
        int bitrate = parts[parts.count-3].intValue;
        int channel = parts[parts.count-2].intValue;
        int latency = parts[parts.count-1].intValue;
        
        //私有属性
        [config setValue:@(bitrate) forKey:@"bitrate"];
        [config setValue:@(channel) forKey:@"audioChannelCount"];
        [config setValue:@(latency) forKey:@"latencyMode"];
    }
    vc.config = config;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)createRoom {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ZegoCreateRoomViewController"];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.definesPresentationContext = YES;
    
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL showTip = self.roomList.count == 0;
    if (section == 0) {
        return showTip ? 1:0;
    }
    else {
        return showTip ? 0:self.roomList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ZGRoomListEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZGRoomListEmptyCell" forIndexPath:indexPath];
        
        NSString *title = nil;
        switch (self.status) {
            case kZegoStatusNone:
                title = @"";
                break;
            case kZegoStatusFetching:
                title = @"正在获取房间列表";
                break;
            case kZegoStatusFetchSuccess:
                title = @"暂无房间";
                break;
            case kZegoStatusFetchFail:
                title = @"获取房间列表失败，点击重试";
                break;
            default:
                break;
        }
        
        SEL selector = @selector(fetchRoomList);
        [cell setButtonTitle:title target:self action:selector];
        
        return cell;
    }
    else {
        ZegoChatroomInfo *info = self.roomList[indexPath.row];
        ZGRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZGRoomListCell" forIndexPath:indexPath];
        
        cell.titleLbl.text = [NSString stringWithFormat:@"房间号:%@",info.roomID];
        
        NSArray<NSString*>* parts = [info.roomName componentsSeparatedByString:@"_"];
        NSMutableString *name = [NSMutableString string];
        if (parts.count < 4) {
            name = info.roomName.mutableCopy;
        }
        else {
            for (int i = 0; i < parts.count-3; ++i) {
                [name appendString:parts[i]];
                [name appendString:@"_"];
            }
            [name deleteCharactersInRange:NSMakeRange(name.length-1, 1)];
        }
        
        cell.descLbl.text = name;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section != 1) {
        return;
    }
    
    ZegoChatroomInfo *info = self.roomList[indexPath.row];
    [self enterRoom:info];
}

#pragma mark - Access

- (void)setStatus:(ZegoStatus)status {
    _status = status;
    [self.tableView reloadData];
}

- (void)setRoomList:(NSArray<ZegoChatroomInfo *> *)roomList {
    _roomList = roomList;
    [self.tableView reloadData];
}

- (BOOL)isVisable {
    return !self.presentedViewController && [self.navigationController.viewControllers.lastObject isEqual:self] && !self.navigationController.presentedViewController;
}

@end
