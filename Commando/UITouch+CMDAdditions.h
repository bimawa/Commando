//
//  UITouch+CMDAdditions.h
//  CommandoExample
//
//  Created by Jonas Budelmann on 2/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

#if (TARGET_IPHONE_SIMULATOR)

@interface UITouch (CMDAdditions)

- (id)initInView:(UIView *)view;
- (id)initAtPoint:(CGPoint)point inView:(UIView *)view;

- (void)setPhase:(UITouchPhase)phase;
- (void)setLocationInWindow:(CGPoint)location;

- (UIEvent *)event;

@end

#endif