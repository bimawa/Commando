//
//  UITouch+CMDAdditions.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 2/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "UITouch+CMDAdditions.h"

#if CMD_COMMANDO_ENABLED

typedef struct __GSEvent * GSEventRef;

//
// GSEvent is an undeclared object. We don't need to use it ourselves but some
// Apple APIs (UIScrollView in particular) require the x and y fields to be present.
//
@interface KIFEventProxy : NSObject
{
@public
	unsigned int flags;
	unsigned int type;
	unsigned int ignored1;
	float x1;
	float y1;
	float x2;
	float y2;
	unsigned int ignored2[10];
	unsigned int ignored3[7];
	float sizeX;
	float sizeY;
	float x3;
	float y3;
	unsigned int ignored4[3];
}

@end

@implementation KIFEventProxy
@end

@interface UITouch () {
    NSTimeInterval  _timestamp;
    UITouchPhase    _phase;
    UITouchPhase    _savedPhase;
    NSUInteger      _tapCount;

    UIWindow        *_window;
    UIView          *_view;
    UIView          *_warpedIntoView;
    NSMutableArray  *_gestureRecognizers;
    NSMutableArray  *_forwardingRecord;

    CGPoint         _locationInWindow;
    CGPoint         _previousLocationInWindow;
    UInt8           _pathIndex;
    UInt8           _pathIdentity;
    float           _pathMajorRadius;
    struct {
        unsigned int _firstTouchForView:1;
        unsigned int _isTap:1;
        unsigned int _isDelayed:1;
        unsigned int _sentTouchesEnded:1;
        unsigned int _abandonForwardingRecord:1;
    } _touchFlags;
}
- (void)setGestureView:(UIView *)view;
@end

@interface UIEvent (CMDAdditionsPrivate)

- (void)_addTouch:(id)arg1 forDelayedDelivery:(BOOL)arg2;
- (void)_clearTouches;
- (void)_setGSEvent:(GSEventRef)event;

@end

@implementation UITouch (CMDAdditions)

- (id)initInView:(UIView *)view {
    CGRect frame = view.frame;
    CGPoint centerPoint = CGPointMake(frame.size.width * 0.5f, frame.size.height * 0.5f);
    return [self initAtPoint:centerPoint inView:view];
}

- (id)initAtPoint:(CGPoint)point inWindow:(UIWindow *)window {
	self = [super init];
	if (self == nil) {
        return nil;
    }

    // Create a fake tap touch
    _tapCount = 1;
    _locationInWindow =	point;
	_previousLocationInWindow = _locationInWindow;

	UIView *hitTestView = [window hitTest:_locationInWindow withEvent:nil];

    _window = window;
    _view = hitTestView;
    if ([self respondsToSelector:@selector(setGestureView:)]) {
        [self setGestureView:hitTestView];
    }
    _phase = UITouchPhaseBegan;
    _touchFlags._firstTouchForView = 1;
    _touchFlags._isTap = 1;
    _timestamp = [[NSProcessInfo processInfo] systemUptime];

	return self;
}

- (id)initAtPoint:(CGPoint)point inView:(UIView *)view {
    return [self initAtPoint:[view.window convertPoint:point fromView:view] inWindow:view.window];
}

- (void)cmd_setPhase:(UITouchPhase)phase {
	_phase = phase;
	_timestamp = [[NSProcessInfo processInfo] systemUptime];
}

- (void)cmd_setLocationInWindow:(CGPoint)location {
	_previousLocationInWindow = _locationInWindow;
	_locationInWindow = location;
	_timestamp = [[NSProcessInfo processInfo] systemUptime];
}

- (UIEvent *)cmd_event {
    UIEvent *event = [[UIApplication sharedApplication] performSelector:@selector(_touchesEvent)];

    CGPoint location = [self locationInView:self.window];
    KIFEventProxy *eventProxy = [[KIFEventProxy alloc] init];
    eventProxy->x1 = location.x;
    eventProxy->y1 = location.y;
    eventProxy->x2 = location.x;
    eventProxy->y2 = location.y;
    eventProxy->x3 = location.x;
    eventProxy->y3 = location.y;
    eventProxy->sizeX = 1.0;
    eventProxy->sizeY = 1.0;
    eventProxy->flags = ([self phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
    eventProxy->type = 3001;

    [event _clearTouches];
    [event _setGSEvent:(struct __GSEvent *)eventProxy];
    [event _addTouch:self forDelayedDelivery:NO];
    
    return event;
}

@end

#endif
