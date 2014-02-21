//
//  CMDOverlayWindow.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 21/02/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "CMDOverlayWindow.h"

@implementation CMDOverlayWindow

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.frame = UIScreen.mainScreen.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.opaque = NO;
    self.windowLevel = 3000; //ontop of all the things

    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // should never recieve touch events
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    // should not be first responder
    return NO;
}

@end
