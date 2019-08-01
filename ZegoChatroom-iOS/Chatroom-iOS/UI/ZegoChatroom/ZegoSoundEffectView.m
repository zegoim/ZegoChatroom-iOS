//
//  ZegoSoundEffectView.m
//  KTV
//
//  Created by Sky on 2018/11/30.
//  Copyright © 2018 zego. All rights reserved.
//

#import "ZegoSoundEffectView.h"
#import "Masonry.h"
#import "UIColor+ZegoExtension.h"


@interface ZegoKTVSoundEffectViewItem : UIControl

@property (copy, nonatomic) void (^onClickCallback)(void);

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;

- (void)setIcon:(NSString *)icon name:(NSString *)name;

@end

@implementation ZegoKTVSoundEffectViewItem

- (instancetype)init {
    if (self = [super init]) {
        _bgView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = ZEGOColorHEX(0xf5f5f5);
            view.layer.cornerRadius = 28.5f;
            view.layer.masksToBounds = YES;
            view.layer.borderColor = UIColor.themeBlue.CGColor;
            view;
        });
        _iconView = [[UIImageView alloc] init];
        _nameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
        
        [self addSubview:_bgView];
        [self addSubview:_iconView];
        [self addSubview:_nameLabel];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(57, 81));
        }];
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(self.mas_width);
        }];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(35, 35));
            make.center.equalTo(self.bgView);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView.mas_bottom).offset(10);
            make.centerX.bottom.equalTo(self);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setIcon:(NSString *)icon name:(NSString *)name {
    self.iconView.image = [UIImage imageNamed:icon];
    self.nameLabel.text = name;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.bgView.layer.borderWidth = selected ? 3:0;
    self.nameLabel.textColor = selected ? UIColor.themeBlue:ZEGOColorHEX(0x333333);
}

- (void)onTap {
    if (self.onClickCallback) {
        self.onClickCallback();
    }
}

@end


NSString *ZegoKTVSoundEffectItemName = @"ZegoKTVSoundEffectItemName";
NSString *ZegoKTVSoundEffectItemIcon = @"ZegoKTVSoundEffectItemIcon";
NSString *ZegoKTVSoundEffectItemSelect = @"ZegoKTVSoundEffectItemSelect";
NSString *ZegoKTVSoundEffectItemAction = @"ZegoKTVSoundEffectItemAction";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@interface ZegoSoundEffectView ()

@property (strong, nonatomic) UIView *loopbackCover;
@property (strong, nonatomic) UIButton *loopbackBtn;
@property (nonatomic, weak) UIView *imgBackView;
@property (strong, nonatomic) UILabel *tipLabel;
@property (strong, nonatomic) UIStackView *stackView;

@property (strong, nonatomic) NSArray <NSDictionary*>*items;

@end

@implementation ZegoSoundEffectView

- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.loopbackCover = ({
        UIView *view = [[UIView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLoopbackBtnTaped:)];
        [view addGestureRecognizer:tap];
        view;
    });
    self.loopbackBtn = ({
        UIButton *btn = [[UIButton alloc] init];
        btn.userInteractionEnabled = NO;
        [btn setTitle:@"  音效试听" forState:UIControlStateNormal];
        [btn setTitleColor:ZEGOColorHEX(0x333333) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setImage:[UIImage imageNamed:@"homepage_icon_mark"] forState:UIControlStateNormal];
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = ZEGOColorHEX(0xfafafa);
        backView.layer.cornerRadius = 9.5f;
        backView.tag = 10;
        self.imgBackView = backView;
        [btn insertSubview:backView belowSubview:btn.imageView];
        btn.imageView.layer.masksToBounds = YES;
        btn.imageView.layer.cornerRadius = 9.5f;
        btn.imageView.layer.borderWidth = 1;
        btn.imageView.layer.borderColor = ZEGOColorHEX(0xe6f0ff).CGColor;
        btn.imageView.alpha = 0;
        [btn.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(19, 19));
        }];
        [btn.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(btn.imageView);
        }];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(btn.imageView);
        }];
        btn;
    });
    self.tipLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"请戴上耳机获得更好的体验";
        label.textColor = ZEGOColorHEX(0x999999);
        label.font = [UIFont systemFontOfSize:12];
        label;
    });
    self.stackView = ({
        UIStackView *stack = [[UIStackView alloc] init];
        stack.spacing = (UIScreen.mainScreen.bounds.size.width-3*57)*114/408;
        stack.distribution = UIStackViewDistributionEqualSpacing;
        stack.alignment = UIStackViewAlignmentCenter;
        stack;
    });
    
    [self addSubview:self.loopbackBtn];
    [self addSubview:self.loopbackCover];
    [self addSubview:self.tipLabel];
    [self addSubview:self.stackView];
    
    [self.loopbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).inset(16.5);
        make.left.equalTo(self).inset(17.5);
    }];
    [self.loopbackCover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.loopbackBtn);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loopbackBtn.mas_right).offset(10);
        make.centerY.equalTo(self.loopbackBtn);
    }];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.loopbackBtn.mas_bottom).offset(30);
    }];
}

- (void)setLoopback:(BOOL)enableLoopback {
    self.loopbackBtn.selected = enableLoopback;
    if (enableLoopback) {
        self.imgBackView.backgroundColor = UIColor.themeBlue;
        self.loopbackBtn.imageView.layer.borderWidth = 0;
        self.loopbackBtn.imageView.alpha = 1;
    }
    else {
        self.imgBackView.backgroundColor = ZEGOColorHEX(0xfafafa);
        self.loopbackBtn.imageView.layer.borderWidth = 1;
        self.loopbackBtn.imageView.alpha = 0;
    }
}

- (void)setItems:(NSArray<NSDictionary *> *)items {
    NSUInteger itemsCount = items.count;
    NSUInteger subViewCount = self.stackView.arrangedSubviews.count;
    if (itemsCount > subViewCount) {
        NSUInteger delta = itemsCount - subViewCount;
        while (delta > 0) {
            ZegoKTVSoundEffectViewItem *itemView = [[ZegoKTVSoundEffectViewItem alloc] init];
            [self.stackView addArrangedSubview:itemView];
            delta--;
        }
    }
    else {
        NSUInteger delta = subViewCount - itemsCount;
        while (delta > 0) {
            [self.stackView removeArrangedSubview:self.stackView.arrangedSubviews.lastObject];
            delta--;
        }
    }
    
    for (int i = 0; i < itemsCount; ++i) {
        NSDictionary *info = items[i];
        NSString *name = info[ZegoKTVSoundEffectItemName];
        NSString *icon = info[ZegoKTVSoundEffectItemIcon];
        BOOL selectd = [info[ZegoKTVSoundEffectItemSelect] boolValue];
        void (^action)(void) = info[ZegoKTVSoundEffectItemAction];
        
        ZegoKTVSoundEffectViewItem *item = self.stackView.arrangedSubviews[i];
        item.selected = selectd;
        [item setIcon:icon name:name];
        item.onClickCallback = action;
    }
}

- (void)onLoopbackBtnTaped:(UIButton *)sender {
    if (self.enableLoopbackCallback) {
        self.enableLoopbackCallback(!self.loopbackBtn.isSelected);
    }
}

@end

#pragma clang diagnostic pop
