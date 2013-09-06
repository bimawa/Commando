//
//  UIView+CMDAdditions.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 2/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UIView+CMDAdditions.h"
#import "UITouch+CMDAdditions.h"

#if CMD_COMMANDO_ENABLED

@implementation UIView (CMDAdditions)

- (void)cmd_fireTapEvents {
    UITouch *touch = [[UITouch alloc] initInView:self];
    UIEvent *event = [touch cmd_event];

    [[UIApplication sharedApplication] sendEvent:event];
    [touch cmd_setPhase:UITouchPhaseEnded];
    [[UIApplication sharedApplication] sendEvent:event];

    // Dispatching the event doesn't actually update the first responder, so fake it
    if ([self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }
}

#pragma mark - view hierarchy helpers

- (CGRect)cmd_boundsInWindowCoordinateSystem {
    return [self.superview convertRect:self.frame toView:self.window];
}

- (BOOL)cmd_withinScreenBounds {
    return CGRectIntersectsRect(self.cmd_boundsInWindowCoordinateSystem, self.window.bounds);
}

- (BOOL)cmd_isVisible {
    return (!self.hidden && [self cmd_withinScreenBounds] && !CGSizeEqualToSize(self.bounds.size, CGSizeZero));
}

- (NSArray *)cmd_visibleSubviews {
    NSMutableArray *subviews = NSMutableArray.new;
    for (UIView *subview in self.subviews) {
        if ([subview cmd_isVisible]) {
            [subviews addObject:subview];
        }
    }
    return subviews;
}

- (NSArray *)cmd_findSubviewsMatching:(BOOL(^)(UIView *subview))matching {
    NSParameterAssert(matching);

    NSMutableArray *views = NSMutableArray.new;
    for (UIView *subview in self.cmd_visibleSubviews) {
        if (matching(subview)) {
            [views addObject:subview];
        }

        [views addObjectsFromArray:[subview cmd_findSubviewsMatching:matching]];
    }
    return views;
}

- (UIView *)cmd_findSubviewMatching:(BOOL(^)(UIView *subview))matching {
    NSParameterAssert(matching);

    for (UIView *subview in self.cmd_visibleSubviews) {
        if (matching(subview)) return subview;

        id result = [subview cmd_findSubviewMatching:matching];
        if (result) return result;
    }
    return nil;
}

@end

#endif
