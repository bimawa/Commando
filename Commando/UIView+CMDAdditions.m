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

- (NSArray *)cmd_findSubviewsOfClass:(Class)aClass {
    NSMutableArray *views = NSMutableArray.new;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:aClass]) {
            [views addObject:subview];
        }

        [views addObjectsFromArray:[subview cmd_findSubviewsOfClass:aClass]];
    }
    return views;
}

- (UIView *)cmd_findSubviewOfClass:(Class)aClass {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:aClass]) return subview;

        id result = [subview cmd_findSubviewOfClass:aClass];
        if (result) return result;
    }
    return nil;
}

@end

#endif
