//
//  CMDHighlighterView.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 31/08/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CMDHighlighterView.h"
#import <QuartzCore/QuartzCore.h>

@interface CMDHighlighterView ()

@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation CMDHighlighterView

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.hintLabel = UILabel.new;
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.textColor = [UIColor blackColor];
    self.hintLabel.font = [UIFont boldSystemFontOfSize:12];
    [self addSubview:self.hintLabel];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.hintLabel sizeToFit];
    CGRect frame = self.hintLabel.frame;
    frame.size.width += 6;
    self.hintLabel.frame = frame;
}

#pragma mark - public

- (void)updateFrame {
    self.frame = [self.targetView.superview convertRect:self.targetView.frame toView:self];
}

- (BOOL)highlightMatch:(NSString *)matchString {
    if (matchString.length && ![self.hint hasPrefix:matchString.uppercaseString]) {
        self.alpha = 0;
        return NO;
    }

    self.alpha = 1;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.hint];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0 alpha:0.5] range:NSMakeRange(0, matchString.length)];
    self.hintLabel.attributedText = str;
    [self setNeedsLayout];
    return YES;
}

#pragma mark - properties

- (void)setHint:(NSString *)hint {
    _hint = hint;
    
    self.hintLabel.text = hint;
    [self setNeedsLayout];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;

    self.hintLabel.backgroundColor = highlightColor;
    self.layer.borderColor = highlightColor.CGColor;
    self.layer.borderWidth = 1;
}

@end
