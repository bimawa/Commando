//
//  CMDCommandoApplication.m
//  Commando
//
//  Created by Jonas Budelmann on 30/08/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CMDCommandoApplication.h"

#if !(TARGET_IPHONE_SIMULATOR)

//if running on device do nothing
@implementation CMDCommandoApplication

@end

#else

//following code only runs on simulator

#import "CMDShortcutManager.h"
#define GSEVENT_TYPE 2
#define GSEVENT_FLAGS 12
#define GSEVENT_TYPE_KEYDOWN 10

@interface UIEvent (private)

- (int *)_gsEvent;

@end

@implementation CMDCommandoApplication

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];

    // Check to see if there was a touch event
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0) {
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan) {
            [[CMDShortcutManager sharedManager] reset];
            return;
		}
    }

    if (![event respondsToSelector:@selector(_gsEvent)]) return;

    int *eventMemory = [event _gsEvent];
    if (!eventMemory) return;

    int eventType = eventMemory[GSEVENT_TYPE];
    if (eventType != GSEVENT_TYPE_KEYDOWN) return;

    int eventFlags = eventMemory[GSEVENT_FLAGS];
    int tmp = eventMemory[15];
    UniChar *keycode = (UniChar *)&tmp;
    CMDKeyboardKey key = keycode[0];

    [[CMDShortcutManager sharedManager] handleKey:key withModifiers:eventFlags];
}

@end

#endif

