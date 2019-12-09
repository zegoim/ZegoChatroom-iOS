//
//  ZegoMsgInputView.m
//  KTV
//
//  Created by Sky on 2018/10/26.
//  Copyright © 2018 zego. All rights reserved.
//

#import "ZegoMsgInputView.h"
#import "UIColor+ZegoExtension.h"

@interface ZegoMsgInputView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIView *tfContentView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ZegoMsgInputView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tfContentView.layer.masksToBounds = YES;
    self.tfContentView.layer.cornerRadius = 16.f;
    self.tfContentView.layer.borderWidth = 1.f;
    self.tfContentView.layer.borderColor = ZEGOColorHEX(0xcdcdcd).CGColor;
    
    self.textField.delegate = self;
}

- (IBAction)onClickSend:(id)sender {
    if (self.msgCallback) {
        self.msgCallback(self.textField.text);
    }
    //发送后清空信息
    self.textField.text = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onClickSend:nil];
    return NO;
}

- (void)startInput {
    self.textField.returnKeyType = UIReturnKeySend;
    [self.textField becomeFirstResponder];
}

- (BOOL)isEditing {
    return self.textField.isEditing;
}

@end
