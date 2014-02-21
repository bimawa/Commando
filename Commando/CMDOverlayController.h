//
//  CMDOverlayController.h
//  CommandoExample
//
//  Created by Jonas Budelmann on 21/02/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMDOverlayController : UIViewController

@property (nonatomic, assign) BOOL hidden;

- (void)highlightView:(UIView *)view color:(UIColor *)color hint:(NSString *)hint;
- (void)findViewMatching:(NSString *)searchString completion:(void (^)(UIView *targetView, BOOL hasPartialMatches))completion;

@end
