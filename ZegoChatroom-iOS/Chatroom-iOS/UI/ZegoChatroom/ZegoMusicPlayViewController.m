//
//  ZegoMusicPlayViewController.m
//  Chatroom-iOS
//
//  Created by Sky on 2019/3/20.
//  Copyright © 2019 zego. All rights reserved.
//

#import "ZegoMusicPlayViewController.h"
#import <ZegoChatroom/ZegoChatroom.h>

@interface ZegoChatroomMusicResource : NSObject <ZegoMusicResource>
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *url;
@end

@implementation ZegoChatroomMusicResource

- (NSString *)description {
    return _name;
}

@end


@interface ZegoMusicPlayViewController () <ZegoMusicPlayDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *preBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

@property (strong, nonatomic) NSTimer *durationTimer;
@property (assign, nonatomic) BOOL isDraging;
@property (assign, nonatomic) NSTimeInterval seekTime;

@end

@implementation ZegoMusicPlayViewController

- (void)dealloc {
    [ZegoChatroom.shared.musicPlayer removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ZegoChatroom.shared.musicPlayer addDelegate:self];
    
    ZegoChatroomMusicResource *res = [ZegoChatroomMusicResource new];
    res.name = @"捉泥鳅";
    res.url = [NSBundle.mainBundle pathForResource:@"zhuoniqiu" ofType:@"mp3"];
    
    ZegoChatroomMusicResource *res1 = [ZegoChatroomMusicResource new];
    res1.name = @"世上只有妈妈好";
    res1.url = [NSBundle.mainBundle pathForResource:@"shishangzhiyoumamahao" ofType:@"mp3"];
    
    ZegoChatroomMusicResource *res2 = [ZegoChatroomMusicResource new];
    res2.name = @"海阔天空";
    res2.url = [NSBundle.mainBundle pathForResource:@"haikuotiankong" ofType:@"mp3"];
    
    ZegoChatroomMusicResource *res3 = [ZegoChatroomMusicResource new];
    res3.name = @"假如-网络资源";
    res3.url = @"http://www.ytmp3.cn/down/59249.mp3";
    
    [ZegoChatroom.shared.musicPlayer setPlaylist:@[res, res1, res2, res3]];
    
    
    //UI
    ZegoMusicPlayer *player = ZegoChatroom.shared.musicPlayer;
    if (ZegoChatroom.shared.musicPlayer.currentResource) {
        [self player:player didMusicPlayStateChange:player.currentResource state:player.currentState error:nil];
    }
    self.segment.selectedSegmentIndex = player.playMode;
    self.activityIndicator.hidden = !player.isBuffering;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)play:(id)sender {
    if (ZegoChatroom.shared.musicPlayer.currentState == kZegoMusicPlayStatePlaying) {
        [ZegoChatroom.shared.musicPlayer pause];
    }
    else {
        [ZegoChatroom.shared.musicPlayer play];
    }
}

- (IBAction)stop:(id)sender {
    [ZegoChatroom.shared.musicPlayer stop];
}

- (IBAction)preSong:(id)sender {
    [ZegoChatroom.shared.musicPlayer playPreviousMusic];
}

- (IBAction)nextSong:(id)sender {
    [ZegoChatroom.shared.musicPlayer playNextMusic];
}

- (IBAction)soundEffect:(id)sender {
    ZegoChatroomMusicResource *sound = [ZegoChatroomMusicResource new];
    sound.url = [NSBundle.mainBundle pathForResource:@"laugth" ofType:@"wav"];
    [ZegoChatroom.shared.musicPlayer playSoundEffect:sound];
}

- (IBAction)startSeek:(id)sender {
    self.isDraging = YES;
}

- (IBAction)endSeek:(id)sender {
    self.isDraging = NO;
    [ZegoChatroom.shared.musicPlayer seekToTime:self.seekTime];
}

- (IBAction)seek:(id)sender {
    self.seekTime = self.slider.value;
}

- (IBAction)playModeChanged:(UISegmentedControl *)sender {
    ZegoChatroom.shared.musicPlayer.playMode = sender.selectedSegmentIndex;
}


- (void)startTimer {
    if (self.durationTimer) {
        return;
    }
    
    NSTimeInterval getInterval = 0.5;
    NSTimer *timer = [NSTimer timerWithTimeInterval:getInterval target:self selector:@selector(getCurrentDuration) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    self.durationTimer = timer;
}

- (void)endTimer {
    if (self.durationTimer) {
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
}

- (void)getCurrentDuration {
    if (self.isDraging) {
        return;
    }
    
    NSTimeInterval currentTime = ZegoChatroom.shared.musicPlayer.currentTime;
    if (currentTime >= 0) {
        self.slider.value = currentTime;
    }
}

#pragma mark - Music Play

- (BOOL)player:(ZegoMusicPlayer *)player shouldPlayMusicResource:(id<ZegoMusicResource>)resource {
    [self player:player didMusicPlayStateChange:resource state:kZegoMusicPlayStatePlaying error:nil];//想要一开始就显示播放的歌曲，不等加载时间
    return YES;
}

- (void)player:(ZegoMusicPlayer *)player didMusicPlayStateChange:(id<ZegoMusicResource>)resource state:(ZegoMusicPlayState)state error:(NSError *)error {
    ZegoChatroomMusicResource *res = (ZegoChatroomMusicResource *)resource;
    
    NSString *msg = nil;
    switch (state) {
        case kZegoMusicPlayStatePlaying:
            msg = [NSString stringWithFormat:@"开始播放-%@",res.name];
            break;
        case kZegoMusicPlayStatePaused:
            msg = [NSString stringWithFormat:@"暂停播放-%@",res.name];
            break;
        case kZegoMusicPlayStateStopped:
            msg = [NSString stringWithFormat:@"停止播放-%@",res.name];
            break;
    }
    
    [ZegoChatroom.shared setLiveExtraInfo:msg];
    
    if (state == kZegoMusicPlayStateStopped) {
        self.nameLbl.text = nil;
    }
    else {
        self.nameLbl.text = msg;
    }
    
    if (state == kZegoMusicPlayStatePlaying) {
        [self.playBtn setTitle:@"暂停" forState:UIControlStateNormal];
        self.slider.maximumValue = ZegoChatroom.shared.musicPlayer.totalDuration;
        [self startTimer];
    }
    else {
        [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
        [self endTimer];
    }
    
    [self.tableView reloadData];
}

- (void)player:(ZegoMusicPlayer *)player didMusicBufferStateChange:(BOOL)buffering {
    self.activityIndicator.hidden = !buffering;
    buffering ? [self.activityIndicator startAnimating]:[self.activityIndicator stopAnimating];
}

- (void)player:(ZegoMusicPlayer *)player didMusicSeekTo:(NSTimeInterval)time {
    self.slider.value = time;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ZegoChatroom.shared.musicPlayer.playlist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    ZegoChatroomMusicResource *res = ZegoChatroom.shared.musicPlayer.playlist[indexPath.row];
    cell.textLabel.text = res.name;
    
    if ([ZegoChatroom.shared.musicPlayer.currentResource.url isEqualToString:res.url]) {
        cell.contentView.backgroundColor = UIColor.lightGrayColor;
    }
    else {
        cell.contentView.backgroundColor = UIColor.whiteColor;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [ZegoChatroom.shared.musicPlayer playMusicFromIndex:indexPath.row];
}

@end
