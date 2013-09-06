//
//  UITouch+CMDAdditions.h
//  CommandoExample
//
//  Created by Jonas Budelmann on 2/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CMDCommando.h"

#if CMD_COMMANDO_ENABLED

@interface UITouch (CMDAdditions)

- (id)initInView:(UIView *)view;
- (id)initAtPoint:(CGPoint)point inView:(UIView *)view;

- (void)cmd_setPhase:(UITouchPhase)phase;
- (void)cmd_setLocationInWindow:(CGPoint)location;
- (UIEvent *)cmd_event;

@end

#endif