//
//  CMDHighlighterView.h
//  CommandoExample
//
//  Created by Jonas Budelmann on 31/08/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMDHighlighterView : UIView

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, strong) NSString *hint;

- (void)updateFrame;
- (BOOL)highlightIfMatches:(NSString *)match;

@end