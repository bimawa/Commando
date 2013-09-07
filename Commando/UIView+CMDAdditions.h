//
//  UIView+CMDAdditions.h
//  CommandoExample
//
//  Created by Jonas Budelmann on 2/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CMDCommando.h"

#if CMD_COMMANDO_ENABLED

@interface UIView (CMDAdditions)

- (void)cmd_fireTapEvents;

- (BOOL)cmd_isVisible;

- (NSArray *)cmd_findSubviewsMatching:(BOOL(^)(UIView *subview))matching;
- (UIView *)cmd_findSubviewMatching:(BOOL(^)(UIView *subview))matching;

@end

#endif