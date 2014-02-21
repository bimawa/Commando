//
//  CMDOverlayController.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 21/02/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "CMDOverlayController.h"
#import "CMDOverlayWindow.h"
#import "CMDHighlighterView.h"

@interface CMDOverlayController ()

@property (nonatomic, strong) CMDOverlayWindow *window;
@property (nonatomic, strong) NSMutableArray *highlighterViews;

@end

@implementation CMDOverlayController

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.highlighterViews = NSMutableArray.new;
    self.window = CMDOverlayWindow.new;
    //use navigation controller handles all rotation for us
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    navigationController.navigationBarHidden = YES;

    self.window.rootViewController = navigationController;
    self.window.hidden = YES;

    return self;
}

- (BOOL)hidden {
    return self.window.hidden;
}

- (void)setHidden:(BOOL)hidden {
    self.window.hidden = hidden;

    // ensure window is ontop of everything else
    CGFloat maxWindowLevel = 0;
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        maxWindowLevel = MAX(window.windowLevel, maxWindowLevel);
    }
    self.window.windowLevel = maxWindowLevel + 1;

    // if hiding window remove all highlighter views
    if (!hidden) return;
    for (UIView *view in self.highlighterViews) {
        [view removeFromSuperview];
    }
    [self.highlighterViews removeAllObjects];
}

- (void)highlightView:(UIView *)view color:(UIColor *)color hint:(NSString *)hint {
    CMDHighlighterView *highlighterView = CMDHighlighterView.new;
    highlighterView.highlightColor = color;
    [self.view addSubview:highlighterView];
    highlighterView.targetView = view;
    [self.highlighterViews addObject:highlighterView];

    //attach hint strings
    highlighterView.hint = hint;

    //calculate frame
    [highlighterView updateFrame];
}

- (void)findViewMatching:(NSString *)searchString completion:(void (^)(UIView *targetView, BOOL hasPartialMatches))completion {
    BOOL hasPartialMatches = NO;
    for (CMDHighlighterView *highlighterView in self.highlighterViews) {
        BOOL isMatch = [highlighterView highlightIfMatches:searchString];
        hasPartialMatches = isMatch || hasPartialMatches;
        if ([highlighterView.hint isEqualToString:searchString.uppercaseString]) {
            completion(highlighterView.targetView, NO);
            return;
        }
    }
    completion(nil, hasPartialMatches);
}


@end
