//
//  CMDHighlighterView.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 31/08/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CMDHighlighterView.h"
#import "Masonry.h"
#import <QuartzCore/QuartzCore.h>

@interface CMDHighlighterView ()

@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation CMDHighlighterView

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.hintLabel = UILabel.new;
    self.hintLabel.textColor = [UIColor blackColor];
    self.hintLabel.font = [UIFont boldSystemFontOfSize:12];
    [self addSubview:self.hintLabel];

    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
    }];

    return self;
}

- (void)setHint:(NSString *)hint {
    _hint = hint;
    
    self.hintLabel.text = [NSString stringWithFormat:@" %@ ", hint];
    [self setNeedsLayout];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;

    self.hintLabel.backgroundColor = highlightColor;
    self.layer.borderColor = highlightColor.CGColor;
    self.layer.borderWidth = 1;
}

@end
