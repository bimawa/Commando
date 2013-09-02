//
//  UIView+CMDAdditions.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 2/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UIView+CMDAdditions.h"
#import "UITouch+CMDAdditions.h"

#if (TARGET_IPHONE_SIMULATOR)

@implementation UIView (CMDAdditions)

- (void)fireTapEvents {
    UITouch *touch = [[UITouch alloc] initInView:self];
    UIEvent *event = [touch event];

    [[UIApplication sharedApplication] sendEvent:event];
    [touch setPhase:UITouchPhaseEnded];
    [[UIApplication sharedApplication] sendEvent:event];

    // Dispatching the event doesn't actually update the first responder, so fake it
    if ([self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }
}

@end

#endif
