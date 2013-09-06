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

@interface UIEvent ()
- (int *)_gsEvent;
@end

// We need this to build up to the keyboard event
@interface UIInternalEvent : UIEvent
@end

@interface UIPhysicalButtonsEvent : UIInternalEvent
@end

@interface UIPhysicalKeyboardEvent : UIPhysicalButtonsEvent
@property (nonatomic, readonly) long _keyCode;
@property (nonatomic, assign) int _modifierFlags;
@property (nonatomic, strong) NSString *_unmodifiedInput;
@property (nonatomic, readonly) BOOL _isKeyDown;
@end

@interface UIApplication ()
- (void)handleKeyUIEvent:(UIPhysicalKeyboardEvent *)event;
@end

@implementation CMDCommandoApplication

- (void)handleKeyUIEvent:(UIPhysicalKeyboardEvent *)event {
    [super handleKeyUIEvent:event];

    if (event._isKeyDown) {
        [[CMDShortcutManager sharedManager] handleKeyDown:event._keyCode withModifiers:event._modifierFlags];
    } else {
        [[CMDShortcutManager sharedManager] handleKeyUp:event._keyCode withModifiers:event._modifierFlags];
    }

}

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];

    // Check to see if there was a touch event
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0) {
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan || phase == UITouchPhaseMoved) {
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
    CMDKeyInputCode key = keycode[0];

    [[CMDShortcutManager sharedManager] handleKeyDown:key withModifiers:eventFlags];
}

@end

#endif

