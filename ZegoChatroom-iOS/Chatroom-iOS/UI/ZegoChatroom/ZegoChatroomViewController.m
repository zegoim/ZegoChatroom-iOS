//
//  ZegoChatroomViewController.m
//  Chatroom-iOS
//
//  Created by Sky on 2019/3/4.
//  Copyright © 2019 zego. All rights reserved.
//

#import "ZegoChatroomViewController.h"
#import <ZegoChatroom/ZegoChatroom.h>
#import "ZGUserHelper.h"
#import "ZegoChatroomInfo.h"
#import "ZegoHudManager.h"
#import "ZegoMsgInputView.h"
#import "UIView+ZegoExtension.h"
#import "ZegoSoundEffectViewController.h"
#import "ZegoMusicPlayViewController.h"
#import "ZegoSoundEffectManager.h"
#import "ZGAppDefine.h"
#import "ZegoKeyCenter.h"

@interface ZegoChatroomSeatCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *stateLbl;
@property (weak, nonatomic) IBOutlet UILabel *delayLbl;
@property (weak, nonatomic) IBOutlet UILabel *liveStatusLbl;
@property (weak, nonatomic) IBOutlet UILabel *soundLevel;
@end

@implementation ZegoChatroomSeatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.borderColor = UIColor.blackColor.CGColor;
    self.contentView.layer.borderWidth = 1;
}

@end


@interface ZegoChatroomViewController () <UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource, ZegoChatroomDelegate,ZegoChatroomIMDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *seatView;
@property (weak, nonatomic) IBOutlet UITableView *msgView;
@property (weak, nonatomic) IBOutlet UIButton *micBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *netBtn;
@property (weak, nonatomic) IBOutlet UIButton *soundBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *bgBtn;

@property (strong, nonatomic) ZegoMsgInputView *msgInputView;

@property (strong, nonatomic) NSMutableSet *roomUsers;
@property (strong, nonatomic) NSMutableArray<NSString*>* msgs;

@end

@implementation ZegoChatroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomUsers = [NSMutableSet set];
    self.msgs = [NSMutableArray array];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.seatView.collectionViewLayout;
    layout.minimumLineSpacing = 4;
    layout.minimumInteritemSpacing = 2;
    layout.itemSize = CGSizeMake(120, 120);
    layout.headerReferenceSize = CGSizeMake(100, 4);
    
    BOOL isManager = [self.roomInfo.user.userID isEqualToString:ZGUserHelper.user.userID];
    self.bgBtn.hidden = !isManager;
    
    [ZegoChatroom setUseTestEnv:IS_TEST_ENV];
    [ZegoChatroom setAppID:ZegoKeyCenter.appID appSignature:ZegoKeyCenter.appSignKey user:ZGUserHelper.user];
    [ZegoChatroom.shared addDelegate:self];
    [ZegoChatroom.shared addIMDelegate:self];
    ZegoChatroom.shared.autoReconnectTimeout = 0;
    
    [self setupChatroom];
    
    if (isManager) {
        NSUInteger count = 9;
        NSMutableArray<ZegoChatroomSeat*>*seats = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < count; ++i) {
            [seats addObject:[ZegoChatroomSeat emptySeat]];
        }
        seats[0].status = kZegoChatroomSeatStatusUsed;
        seats[0].user = self.roomInfo.user;
        
        unsigned long bitrate = [[self.config valueForKey:@"bitrate"] unsignedLongValue];
        unsigned long audioChannelCount = [[self.config valueForKey:@"audioChannelCount"] unsignedLongValue];
        unsigned long latencyMode = [[self.config valueForKey:@"latencyMode"] unsignedLongValue];
        
        NSString *configString = [NSString stringWithFormat:@"%@_%lu_%lu_%lu",self.roomInfo.roomName, bitrate, audioChannelCount, latencyMode];
        
        [ZegoChatroom.shared createRoomWithRoomID:self.roomInfo.roomID
                                                 roomName:configString
                                             initialSeats:seats
                                               liveConfig:self.config];
    }
    else {
        [ZegoChatroom.shared joinRoom:self.roomInfo.roomID liveConfig:self.config];
    }
    
    [self setupInputBar];
    [self setupNotifications];
}

- (void)setupInputBar {
    ZegoMsgInputView *inputView = [ZegoMsgInputView viewFromXIB];
    
    __weak typeof(self)weakself = self;
    inputView.msgCallback = ^(NSString * _Nonnull msg) {
        __strong typeof(weakself)self = weakself;
        
        [self.msgInputView endEditing:YES];
        
        if (msg.length == 0) {
            return;
        }
        
        __weak typeof(self)weakself = self;
        [ZegoChatroom.shared sendChatroomMessage:msg type:0 completion:^(ZegoChatroomMessage * _Nullable message, NSError * _Nullable error) {
            __strong typeof(weakself)self = weakself;
            
            if (error) {
                [ZegoHudManager showMessage:error.description];
                return;
            }
            
            NSString *msgContent = [NSString stringWithFormat:@"%@:%@", ZGUserHelper.user.userName, message.content];
            [self addMsg:msgContent];
        }];
    };
    
    self.msgInputView = inputView;
    [self.view addSubview:inputView];
    
    CGRect scr = UIScreen.mainScreen.bounds;
    CGRect frame = CGRectMake(0, scr.size.height, scr.size.width, 44);
    self.msgInputView.frame = frame;
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)addMsg:(NSString *)msg {
    [self.msgs addObject:msg];
    [self.msgView reloadData];
    NSInteger msgCount = self.msgs.count;
    NSIndexPath *bottomIndex = [NSIndexPath indexPathForRow:msgCount-1 inSection:0];
    [self.msgView scrollToRowAtIndexPath:bottomIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)setupChatroom {
    [ZegoChatroom.shared muteMic:NO];
    [ZegoChatroom.shared muteSpeaker:NO];
    [ZegoChatroom.shared setChatroomEnableUserStateUpdate:YES];
}

#pragma mark - Actions

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.msgInputView endEditing:YES];
}

- (IBAction)exitRoom {
    [ZegoSoundEffectManager.shared reset];
    [ZegoChatroom.shared.musicPlayer stop];
    
    BOOL shouldLeaveSeat = [self seatIndexOfUser:nil] != -1;
    if (shouldLeaveSeat) {
        [ZegoHudManager showNetworkLoading];
        [ZegoChatroom.shared leaveSeatWithCompletion:^(NSError * _Nullable error) {
            [ZegoHudManager hideNetworkLoading];
            
            if (error) {
                [ZegoHudManager showMessage:@"下麦失败"];
            }
            
            [ZegoChatroom.shared leaveRoom];
            [ZegoChatroom.shared removeDelegate:self];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        return;
    }
    
    [ZegoChatroom.shared leaveRoom];
    [ZegoChatroom.shared removeDelegate:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeMicState {
    NSString *title = [self.micBtn titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"Mic关"]) {
        [ZegoChatroom.shared muteMic:NO];
        [self.micBtn setTitle:@"Mic开" forState:UIControlStateNormal];
    }
    else {
        [ZegoChatroom.shared muteMic:YES];
        [self.micBtn setTitle:@"Mic关" forState:UIControlStateNormal];
    }
}

- (IBAction)muteAll {
    NSString *title = [self.muteBtn titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"静音关"]) {
        [ZegoChatroom.shared muteSpeaker:YES];
        [self.muteBtn setTitle:@"静音开" forState:UIControlStateNormal];
    }
    else {
        [ZegoChatroom.shared muteSpeaker:NO];
        [self.muteBtn setTitle:@"静音关" forState:UIControlStateNormal];
    }
}

- (IBAction)playBackgroundMusic {
    BOOL isOwner = [self.roomInfo.user.userID isEqualToString:ZGUserHelper.user.userID];
    if (!isOwner) {
        [ZegoHudManager showMessage:@"房主才可播放背景音乐"];
        return;
    }

    BOOL canPlayBgMusic = ZegoChatroom.shared.liveStatus == kZegoChatroomUserLiveStatusLive;

    if (canPlayBgMusic) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ZegoMusicPlayViewController"];
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.definesPresentationContext = YES;
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        [ZegoHudManager showMessage:@"请先上麦再播放音乐"];
    }
}

- (IBAction)showNetState {
    
}

- (IBAction)showSoundEffect {
    __weak typeof(self)weakself = self;
    
    ZegoSoundEffectViewController *vc = [[ZegoSoundEffectViewController alloc] init];
    unsigned long audioChannelCount = [[self.config valueForKey:@"audioChannelCount"] unsignedLongValue];
    vc.singleAudioChannel = audioChannelCount == 1;
    vc.openLoopbackCallback = ^(BOOL open) {
        __strong typeof(weakself)self = weakself;
        if (!open) {
            [self onDisableLoopbackTip];
        }
    };
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.definesPresentationContext = YES;
    [self presentViewController:vc animated:NO completion:^{
        [vc show];
        NSLog(@"%s", __func__);
    }];
}

- (void)onDisableLoopbackTip {
    [ZegoHudManager showMessage:@"已关闭自己的音效试听，对方仍可听到"];
}

- (IBAction)sendMsg:(id)sender {
    [self.msgInputView startInput];
}

- (void)showOpMenu:(NSUInteger)index {
    ZegoChatroomSeat *seat = ZegoChatroom.shared.seats[index];
    BOOL isManager = [ZGUserHelper.user.userID isEqualToString:self.roomInfo.user.userID];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (seat.status == kZegoChatroomSeatStatusEmpty && ![self seatOfUser:nil]) {
        [controller addAction:[UIAlertAction actionWithTitle:@"上麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ZegoHudManager showNetworkLoading];
            [ZegoChatroom.shared takeSeatAtIndex:index completion:^(NSError * _Nullable error) {
                [ZegoHudManager hideNetworkLoading];
                if (error) {
                    [ZegoHudManager showMessage:error.description];
                }
            }];
        }]];
    }
    
    if (seat.status == kZegoChatroomSeatStatusUsed && [seat.user.userID isEqualToString:ZGUserHelper.user.userID]) {
        [controller addAction:[UIAlertAction actionWithTitle:@"下麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ZegoHudManager showNetworkLoading];
            [ZegoChatroom.shared leaveSeatWithCompletion:^(NSError * _Nullable error) {
                [ZegoHudManager hideNetworkLoading];
                
                [ZegoChatroom.shared.musicPlayer stop];
                
                if (error) {
                    [ZegoHudManager showMessage:error.description];
                }
            }];
        }]];
    }
    
    if ([self seatOfUser:nil] && seat.status == kZegoChatroomSeatStatusEmpty) {
        [controller addAction:[UIAlertAction actionWithTitle:@"换麦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ZegoHudManager showNetworkLoading];
            [ZegoChatroom.shared changeSeatTo:index completion:^(NSError * _Nullable error) {
                [ZegoHudManager hideNetworkLoading];
                if (error) {
                    [ZegoHudManager showMessage:error.description];
                }
            }];
        }]];
    }
    
    if (isManager) {
        if (seat.status == kZegoChatroomSeatStatusEmpty) {
            [controller addAction:[UIAlertAction actionWithTitle:@"抱上" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self selectUser:^(ZegoChatroomUser *user) {
                    if (!user) {
                        return;
                    }
                    [ZegoHudManager showNetworkLoading];
                    [ZegoChatroom.shared pickUp:user atIndex:index completion:^(NSError * _Nullable error) {
                        [ZegoHudManager hideNetworkLoading];
                        if (error) {
                            [ZegoHudManager showMessage:error.description];
                        }
                    }];
                }];
            }]];
        }
        else {
            if (![seat.user.userID isEqualToString:ZGUserHelper.user.userID]) {
                [controller addAction:[UIAlertAction actionWithTitle:@"抱下" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [ZegoHudManager showNetworkLoading];
                    [ZegoChatroom.shared kickOut:seat.user completion:^(NSError * _Nullable error) {
                        [ZegoHudManager hideNetworkLoading];
                        if (error) {
                            [ZegoHudManager showMessage:error.description];
                        }
                    }];
                }]];
            }
        }
        
        BOOL mute = !seat.isMute;
        [controller addAction:[UIAlertAction actionWithTitle:mute ? @"禁麦":@"解禁" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ZegoHudManager showNetworkLoading];
            [ZegoChatroom.shared muteSeat:mute atIndex:index completion:^(NSError * _Nullable error) {
                [ZegoHudManager hideNetworkLoading];
                if (error) {
                    [ZegoHudManager showMessage:error.description];
                }
            }];
        }]];
        
        BOOL close = seat.status != kZegoChatroomSeatStatusClosed;
        [controller addAction:[UIAlertAction actionWithTitle:close ? @"封麦":@"解封" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ZegoHudManager showNetworkLoading];
            [ZegoChatroom.shared closeSeat:close atIndex:index completion:^(NSError * _Nullable error) {
                [ZegoHudManager hideNetworkLoading];
                if (error) {
                    [ZegoHudManager showMessage:error.description];
                }
            }];
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"群体禁麦1-8" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ZegoHudManager showNetworkLoading];
            [ZegoChatroom.shared runSeatOperationGroup:^{
                [ZegoChatroom.shared muteSeat:YES atIndex:1 completion:nil];
                [ZegoChatroom.shared muteSeat:YES atIndex:2 completion:nil];
                [ZegoChatroom.shared muteSeat:YES atIndex:3 completion:nil];
                [ZegoChatroom.shared muteSeat:YES atIndex:4 completion:nil];
                [ZegoChatroom.shared muteSeat:YES atIndex:5 completion:nil];
                [ZegoChatroom.shared muteSeat:YES atIndex:6 completion:nil];
                [ZegoChatroom.shared muteSeat:YES atIndex:7 completion:nil];
                [ZegoChatroom.shared muteSeat:YES atIndex:8 completion:nil];
            } completion:^(NSError * _Nullable error) {
                [ZegoHudManager hideNetworkLoading];
                if (error) {
                    [ZegoHudManager showMessage:error.description];
                }
            }];
        }]];
    }
    
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)selectUser:(void(^)(ZegoChatroomUser *user))callback {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"选择user" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *pickUpUsers = [self usersCanPickUp];
    for (ZegoChatroomUser *user in pickUpUsers) {
        NSString *title = [NSString stringWithFormat:@"%@-%@",user.userID, user.userName];
        [controller addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            callback(user);
        }]];
    }
    
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        callback(nil);
    }]];
    
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Noti

- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.msgInputView.isEditing) {
        double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        CGFloat keyboardY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
        CGFloat scrH = UIScreen.mainScreen.bounds.size.height;
        CGFloat inputH = self.msgInputView.bounds.size.height;
        CGFloat ty = keyboardY - scrH - inputH;
        
        [UIView animateWithDuration:duration animations:^{
            self.msgInputView.transform = CGAffineTransformMakeTranslation(0, ty);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.msgInputView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (ZegoChatroom.shared.seats.count == 0) {
        return 0;
    }

    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZegoChatroomSeatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZegoChatroomSeatCell" forIndexPath:indexPath];
    
    ZegoChatroomSeat *seat = ZegoChatroom.shared.seats[indexPath.row];
    
    cell.nameLbl.text = seat.user ? seat.user.userName:@"none";
    NSString *stateText = [NSString stringWithFormat:@"%@,%@",[self seatStateStringWithSeatStatusEnum:seat.status],seat.isMute ? @"禁":@""];
    cell.stateLbl.text = stateText;
    
    if (!seat.user) {
        cell.delayLbl.text = @"delay";
        cell.soundLevel.text = @"soundLevel";
        cell.liveStatusLbl.text = @"待连接";
    }
    
    switch (seat.status) {
        case kZegoChatroomSeatStatusUsed:
            cell.contentView.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.3];
            break;
        case kZegoChatroomSeatStatusEmpty:
            cell.contentView.backgroundColor = UIColor.whiteColor;
            break;
        case kZegoChatroomSeatStatusClosed:
            cell.contentView.backgroundColor = UIColor.lightGrayColor;
            break;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self showOpMenu:indexPath.row];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    NSString *msg = self.msgs[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = msg;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    return cell;
}

#pragma mark - ChatroomDelegate

- (void)chatroom:(ZegoChatroom *)chatroom didLoginEventOccur:(ZegoChatroomLoginEvent)event loginStatus:(ZegoChatroomLoginStatus)status error:(NSError *)error {
    if (status == kZegoChatroomLoginStatusStartLogin) {
        [ZegoHudManager showNetworkLoading];
    }
    else {
        [ZegoHudManager hideNetworkLoading];
    }
    
    NSString *logStr = [NSString stringWithFormat:@"系统:didLoginEventOccur:%@,loginStatus:%@,error:%@", [self loginEventStringWithLoginEventEnum:event], [self loginStateStringWithLoginStatusEnum:status], error];
    NSLog(@"%@",logStr);
    [self addMsg:logStr];
}

- (void)chatroom:(ZegoChatroom *)chatroom didAutoReconnectRoomStop:(ZegoChatroomReconnectStopReason)reason {
    NSString *logStr = [NSString stringWithFormat:@"系统:didAutoReconnectRoomStop:%@", [self loginStopReasonStringWithReasonEnum:reason]];
    NSLog(@"%@",logStr);
    [self addMsg:logStr];
    
    [ZegoHudManager hideNetworkLoading];
    [ZegoHudManager showMessage:[self loginStopReasonStringWithReasonEnum:reason]];
}

- (void)chatroom:(ZegoChatroom *)chatroom didSeatsUpdate:(NSArray<ZegoChatroomSeat *> *)seats {
    [self.seatView reloadData];
}

- (void)chatroom:(ZegoChatroom *)chatroom didUserTakeSeat:(ZegoChatroomUser *)user atIndex:(NSUInteger)index {
    [self addMsg:[NSString stringWithFormat:@"user:%@,上麦，位置:%ld",user.userName, (long)index]];
}

- (void)chatroom:(ZegoChatroom *)chatroom didUserLeaveSeat:(ZegoChatroomUser *)user atIndex:(NSUInteger)index {
    [self addMsg:[NSString stringWithFormat:@"user:%@,下麦，位置：%ld",user.userName, (long)index]];
}

- (void)chatroom:(ZegoChatroom *)chatroom didUserChangeSeat:(ZegoChatroomUser *)user from:(NSUInteger)fromIndex to:(NSUInteger)toIndex {
    [self addMsg:[NSString stringWithFormat:@"user:%@,换麦，从:%ld->%ld",user.userName, (long)fromIndex, (long)toIndex]];
}

- (void)chatroom:(ZegoChatroom *)chatroom didUser:(ZegoChatroomUser *)user pickUpUser:(ZegoChatroomUser *)toUser atIndex:(NSUInteger)index {
    [self addMsg:[NSString stringWithFormat:@"user:%@,将user:%@，抱上麦，位置：%ld",user.userName,toUser.userName, (long)index]];
    
    if ([toUser.userID isEqualToString:ZGUserHelper.user.userID]) {
        BOOL shouldMute = [[self.micBtn titleForState:UIControlStateNormal] isEqualToString:@"Mic开"];
        if (shouldMute) {
            [self changeMicState];
        }
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"你被抱上麦" message:@"快打开麦克风聊天吧！" preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"下麦" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [ZegoChatroom.shared leaveSeatWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    [ZegoHudManager showMessage:@"下麦失败"];
                }
            }];
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (shouldMute) {
                [self changeMicState];
            }
        }]];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)chatroom:(ZegoChatroom *)chatroom didUser:(ZegoChatroomUser *)user kickOutUser:(ZegoChatroomUser *)toUser atIndex:(NSUInteger)index {
    [self addMsg:[NSString stringWithFormat:@"user:%@,将user:%@，抱下麦，位置：%ld",user.userName,toUser.userName, (long)index]];
}

- (void)chatroom:(ZegoChatroom *)chatroom didUser:(ZegoChatroomUser *)user muteSeat:(BOOL)mute atIndex:(NSUInteger)index {
    [self addMsg:[NSString stringWithFormat:@"user:%@,%@麦位，位置：%ld",user.userName,mute ? @"禁":@"解禁", (long)index]];
}

- (void)chatroom:(ZegoChatroom *)chatroom didUser:(ZegoChatroomUser *)user closeSeat:(BOOL)close atIndex:(NSUInteger)index {
    [self addMsg:[NSString stringWithFormat:@"user:%@,%@麦位，位置：%ld",user.userName,close ? @"封":@"解封", (long)index]];
}

- (void)chatroom:(ZegoChatroom *)chatroom didLiveStatusUpdate:(ZegoChatroomUserLiveStatus)liveStatus user:(ZegoChatroomUser *)user {
    NSUInteger index = [self seatIndexOfUser:user];
    
    if (index == -1) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        ZegoChatroomSeatCell *cell = (ZegoChatroomSeatCell *)[self.seatView cellForItemAtIndexPath:indexPath];
        cell.liveStatusLbl.text = [self userLiveStateStringWithLiveStatusEnum:liveStatus];
    });
}

- (void)chatroom:(ZegoChatroom *)chatroom didLiveQualityUpdate:(ZegoUserLiveQuality *)quality user:(ZegoChatroomUser *)user {
    NSUInteger index = [self seatIndexOfUser:user];
    
    if (index == -1) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        ZegoChatroomSeatCell *cell = (ZegoChatroomSeatCell *)[self.seatView cellForItemAtIndexPath:indexPath];
        cell.delayLbl.text = [@(quality.audioDelay).stringValue stringByAppendingString:@"ms"];
    });
}

- (void)chatroom:(ZegoChatroom *)chatroom didSoundLevelUpdate:(float)soundLevel user:(ZegoChatroomUser *)user {
    NSUInteger index = [self seatIndexOfUser:user];
    
    if (index == -1) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        ZegoChatroomSeatCell *cell = (ZegoChatroomSeatCell *)[self.seatView cellForItemAtIndexPath:indexPath];
        cell.soundLevel.text = @(soundLevel).stringValue;
    });
}

- (void)chatroom:(ZegoChatroom *)chatroom didLiveExtraInfoUpdate:(NSString *)extraInfo user:(ZegoChatroomUser *)user {
    if (extraInfo.length == 0) {
        return;
    }
    
    [self addMsg:[NSString stringWithFormat:@"%@:%@",user.userName, extraInfo]];
}

#pragma mark - ZegoChatroomIMDelegate

- (void)chatroom:(ZegoChatroom *)chatroom didUserJoin:(NSArray<ZegoChatroomUser *> *)userList {
    [self.roomUsers addObjectsFromArray:userList];
}

- (void)chatroom:(ZegoChatroom *)chatroom didUserLeave:(NSArray<ZegoChatroomUser *> *)userList {
    for (ZegoChatroomUser *user in userList) {
        [self.roomUsers removeObject:user];
    }
}

- (void)chatroom:(ZegoChatroom *)chatroom didRecvChatroomMessage:(NSArray<ZegoChatroomMessage *> *)messageList {
    for (ZegoChatroomMessage *msg in messageList) {
        NSString *msgContent = [NSString stringWithFormat:@"%@:%@", msg.fromUser.userName, msg.content];
        [self addMsg:msgContent];
    }
}


#pragma mark - Helper Methods

- (ZegoChatroomSeat *)seatOfUser:(ZegoChatroomUser *)user {
    user = user ?:ZGUserHelper.user;
    
    for (ZegoChatroomSeat *seat in ZegoChatroom.shared.seats) {
        if ([user.userID isEqualToString:seat.user.userID]) {
            return seat;
        }
    }
    
    return nil;
}

- (NSUInteger)seatIndexOfUser:(ZegoChatroomUser *)user {
    user = user ?:ZGUserHelper.user;
    
    for (int i = 0; i < ZegoChatroom.shared.seats.count; ++i) {
        if ([user.userID isEqualToString:ZegoChatroom.shared.seats[i].user.userID]) {
            return i;
        }
    }
    
    return -1;
}

- (NSArray <ZegoChatroomUser*>*)usersCanPickUp {
    NSMutableSet<ZegoChatroomUser *>* allUsers = [NSMutableSet setWithSet:self.roomUsers];
    NSMutableSet<ZegoChatroomUser *>* usersOnMic = [NSMutableSet set];
    
    for (ZegoChatroomSeat *seat in ZegoChatroom.shared.seats) {
        if (seat.user) {
            [usersOnMic addObject:seat.user];
        }
    }
    
    [allUsers minusSet:usersOnMic];
    
    return allUsers.allObjects;
}

- (NSString *)loginEventStringWithLoginEventEnum:(ZegoChatroomLoginEvent)event {
    switch (event) {
        case kZegoChatroomLoginEventLogin:return @"login event";
        case kZegoChatroomLoginEventLogout:return @"logout event";
        case kZegoChatroomLoginEventKickOut:return @"kickout event";
        case kZegoChatroomLoginEventReconnect:return @"reconnect event";
        case kZegoChatroomLoginEventTempBroke:return @"tempbroke event";
        case kZegoChatroomLoginEventDisconnect:return @"disconnect event";
        case kZegoChatroomLoginEventLoginFailed:return @"login fail event";
        case kZegoChatroomLoginEventLoginSuccess:return @"login success event";
    }
}

- (NSString *)loginStopReasonStringWithReasonEnum:(ZegoChatroomReconnectStopReason)reason {
    switch (reason) {
        case kZegoChatroomReconnectStopReasonParam:return @"invalid param or roomconfig audience can't create room";
        case kZegoChatroomReconnectStopReasonLogout:return @"logout";
        case kZegoChatroomReconnectStopReasonKickout:return @"kick out";
        case kZegoChatroomReconnectStopReasonTimeout:return @"login time out";
        case kZegoChatroomReconnectStopReasonSyncError:return @"sync error";
    }
}

- (NSString *)loginStateStringWithLoginStatusEnum:(ZegoChatroomLoginStatus)status {
    switch (status) {
        case kZegoChatroomLoginStatusLogout:return @"logout";
        case kZegoChatroomLoginStatusStartLogin:return @"start login";
        case kZegoChatroomLoginStatusLogin:return @"login";
        case kZegoChatroomLoginStatusTempBroken:return @"temp broken";
    }
}

- (NSString *)seatStateStringWithSeatStatusEnum:(ZegoChatroomSeatStatus)status {
    switch (status) {
        case kZegoChatroomSeatStatusEmpty:return @"空";
        case kZegoChatroomSeatStatusUsed:return @"占";
        case kZegoChatroomSeatStatusClosed:return @"封";
    }
}

- (NSString *)userLiveStateStringWithLiveStatusEnum:(ZegoChatroomUserLiveStatus)status {
    switch (status) {
        case kZegoChatroomUserLiveStatusWaitConnect:return @"待连接";
        case kZegoChatroomUserLiveStatusConnecting:return @"连接中";
        case kZegoChatroomUserLiveStatusLive:return @"已连接";
    }
}


@end
