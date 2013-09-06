//
//  CMDCommandoApplication.m
//  Commando
//
//  Created by Jonas Budelmann on 30/08/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CMDCommando.h"

#if CMD_COMMANDO_ENABLED

#import "CMDShortcutManager.h"
#import <objc/runtime.h>

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

static void __attribute__((constructor)) CMDCommandoApplicationInstall() {
    Class UIApplicationClass = UIApplication.class;

    method_exchangeImplementations(class_getInstanceMethod(UIApplicationClass, @selector(sendEvent:)), class_getInstanceMethod(UIApplicationClass, @selector(cmd_sendEvent:)));
    method_exchangeImplementations(class_getInstanceMethod(UIApplicationClass, @selector(handleKeyUIEvent:)), class_getInstanceMethod(UIApplicationClass, @selector(cmd_handleKeyUIEvent:)));
}

@implementation UIApplication (CMDCommandoApplication)

- (void)cmd_handleKeyUIEvent:(UIPhysicalKeyboardEvent *)event {
    [self cmd_handleKeyUIEvent:event];

    if (event._isKeyDown) {
        [[CMDShortcutManager sharedManager] handleKeyDown:event._keyCode withModifiers:event._modifierFlags];
    } else {
        [[CMDShortcutManager sharedManager] handleKeyUp:event._keyCode withModifiers:event._modifierFlags];
    }
}

- (void)cmd_sendEvent:(UIEvent *)event {
    [self cmd_sendEvent:event];

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

