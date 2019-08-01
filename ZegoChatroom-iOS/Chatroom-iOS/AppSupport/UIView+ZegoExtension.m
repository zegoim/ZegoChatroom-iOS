//
//  UIView+ZegoExtension.m
//  KTV
//
//  Created by Sky on 2018/10/24.
//  Copyright © 2018 zego. All rights reserved.
//

#import "UIView+ZegoExtension.h"

@implementation UIView (ZegoExtension)

+ (instancetype)viewFromXIB {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

@end
