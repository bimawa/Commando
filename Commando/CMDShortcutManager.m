//
//  CMDShortcutManager.m
//  Commando
//
//  Created by Jonas Budelmann on 30/08/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CMDShortcutManager.h"

#if !(TARGET_IPHONE_SIMULATOR)

//if running on device do nothing
@implementation CMDShortcutManager

+ (instancetype)sharedManager { return nil; }
- (void)handleKey:(CMDKeyboardKey)key withModifiers:(CMDKeyboardModifierKey)modifiers {}
- (void)reset {}

@end

#else

#import "CMDHighlighterView.h"
#import "UITouch+CMDAdditions.h"
#import "UIView+CMDAdditions.h"

static double const kCMDFindCompleteDelay = 0.3;
static NSString* const kCMDFindHintCharacters = @"sadfjklewcmpgh";

typedef NS_ENUM(NSUInteger, CMDShortcutMode) {
	CMDShortcutModeIdle,
    CMDShortcutModeFind
};

@interface CMDShortcutManager ()

@property (nonatomic, assign) CMDShortcutMode mode;
@property (nonatomic, assign) BOOL keyboardVisible;
@property (nonatomic, strong) NSString *findMatch;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) NSMutableArray *highlighterViews;
@property (nonatomic, weak) UIScrollView *currentScrollView;
@property (nonatomic, assign) CGFloat scrollSpeed;

@end

@implementation CMDShortcutManager

+ (instancetype)sharedManager {
	static id instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	return instance;
}

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.overlayView = UIView.new;
    self.overlayView.userInteractionEnabled = NO;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.highlighterViews = NSMutableArray.new;

    //defaults
    self.popNavigationItemShortcutKey = CMDKeyboardKeyBackspace;
    self.findShortcutKey = CMDKeyboardKeyF;
    self.findHighlightColor = UIColor.greenColor;
    self.traverseShortcutKey = CMDKeyboardKeyTab;
    self.traverseHighlightColor = UIColor.blueColor;
    
    // listen for device orientation changes to reset mode
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification {
    self.mode = CMDShortcutModeIdle;
}

#pragma mark - public

- (void)handleKey:(CMDKeyboardKey)key withModifiers:(CMDKeyboardModifierKey)modifiers {
    if ([self isEditingText]) {
        if (key == CMDKeyboardKeyEscape) {
            //allow escape to end editing of textfields etc
            [self.keyWindow endEditing:YES];
        }
        return;
    }
    
    if (key == CMDKeyboardKeyEscape) {
        self.mode = CMDShortcutModeIdle;
        UIView *firstResponder = self.firstResponder;

        //dismiss alertview
        if ([firstResponder isKindOfClass:UIAlertView.class]) {
            UIAlertView *alertView = (id)firstResponder;
            [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
        }
        return;
    }

    NSString *keyString = [self.class stringFromkey:key];
    
    if (self.mode == CMDShortcutModeIdle) {
        if (key == self.findShortcutKey) {
            self.mode = CMDShortcutModeFind;
            self.findMatch = @"";
            [self.keyWindow.subviews.lastObject addSubview:self.overlayView];

            //find all tapable views
            [self highlightSubviewsOfView:self.keyWindow];

            //attach hint strings
            NSArray *hintStrings = [self generateHintStringsForViewCount:self.highlighterViews.count];
            for (CMDHighlighterView *highlighterView in self.highlighterViews) {
                highlighterView.hint = hintStrings[[self.highlighterViews indexOfObject:highlighterView]];
                [highlighterView updateFrame];
            }
        } else if (key == self.popNavigationItemShortcutKey) {
            UINavigationBar *navigationBar = (id)[self findSubviewOfClass:UINavigationBar.class inView:self.keyWindow];

            //cannot call [navigationBar popNavigationItemAnimated:YES] if navigationBar is within a UINavigationController
            UINavigationController *navigationController = [navigationBar.delegate isKindOfClass:UINavigationController.class] ? navigationBar.delegate : nil ;
            if (navigationController) {
                [navigationController popViewControllerAnimated:YES];
            } else {
                [navigationBar popNavigationItemAnimated:YES];
            }
        } else if (key == CMDKeyboardKeyLeft ||
                   key == CMDKeyboardKeyRight ||
                   key == CMDKeyboardKeyUp ||
                   key == CMDKeyboardKeyDown) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reset) object:nil];
            if (!self.currentScrollView) {
                NSArray *scrollViews = [self findSubviewsOfClass:UIScrollView.class inView:self.keyWindow];

                UIScrollView *largestScrollView = [scrollViews lastObject];
                CGFloat currentLargestArea = largestScrollView.bounds.size.width * largestScrollView.bounds.size.height;
                for (UIScrollView *scrollView in scrollViews) {
                    CGFloat area = scrollView.bounds.size.width * scrollView.bounds.size.height;
                    if (area > currentLargestArea) {
                        currentLargestArea = area;
                        largestScrollView = scrollView;
                    }
                }
                self.currentScrollView = largestScrollView;
                if (!self.currentScrollView) return;
            }

            CGPoint contentOffset = self.currentScrollView.contentOffset;
            self.scrollSpeed++;
            if (key == CMDKeyboardKeyDown) {
                contentOffset.y += self.scrollSpeed;
            }
            if (key == CMDKeyboardKeyUp) {
                contentOffset.y -= self.scrollSpeed;
            }
            if (key == CMDKeyboardKeyLeft) {
                contentOffset.x -= self.scrollSpeed;
            }
            if (key == CMDKeyboardKeyRight) {
                contentOffset.x += self.scrollSpeed;
            }
            contentOffset.x = MIN(MAX(0, contentOffset.x), MAX(self.currentScrollView.contentSize.width - CGRectGetWidth(self.currentScrollView.frame), 0));
            contentOffset.y = MIN(MAX(0, contentOffset.y), MAX(self.currentScrollView.contentSize.height - CGRectGetHeight(self.currentScrollView.frame), 0));
            [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.currentScrollView.contentOffset = contentOffset;
            } completion:nil];
            [self performSelector:@selector(reset) withObject:nil afterDelay:0.3];
        }
    } else {
        if (self.mode == CMDShortcutModeFind) {
            if (key == CMDKeyboardKeyBackspace) {
                //deleting text
                if (self.findMatch.length) {
                    self.findMatch = [self.findMatch substringToIndex:self.findMatch.length-1];
                } else {
                    self.mode = CMDShortcutModeIdle;
                    return;
                }
            } else {
                if (keyString) {
                    self.findMatch = [self.findMatch stringByAppendingString:keyString];
                }
            }

            //filter tapable views
            [self filterHighlightedViews];
        }
    }
}

- (void)reset {
    NSLog(@"reset");
    self.mode = CMDShortcutModeIdle;
}

#pragma mark - view hierarchy helpers

- (NSArray *)findSubviewsOfClass:(Class)class inView:(UIView *)view {
    NSMutableArray *views = NSMutableArray.new;
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:class]) {
            [views addObject:subview];
        }

        [views addObjectsFromArray:[self findSubviewsOfClass:class inView:subview]];
    }
    return views;
}

- (UIView *)findSubviewOfClass:(Class)class inView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:class]) return subview;

        id result = [self findSubviewOfClass:class inView:subview];
        if (result) return result;
    }
    return nil;
}

#pragma mark - fake touch events

- (void)performTapOnView:(UIView *)view {
    [view fireTapEvents];
    self.mode = CMDShortcutModeIdle;
}

#pragma mark - highlighting

- (void)filterHighlightedViews {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    BOOL hasMatches = NO;
    for (CMDHighlighterView *highlighterView in self.highlighterViews) {
        BOOL isMatch = [highlighterView highlightMatch:self.findMatch];
        hasMatches = isMatch || hasMatches;
        if ([highlighterView.hint isEqualToString:self.findMatch.uppercaseString]) {
            //simulate click on this view
            [self performSelector:@selector(performTapOnView:) withObject:highlighterView.targetView afterDelay:kCMDFindCompleteDelay];
            return;
        }
    }
    if (!hasMatches) {
        self.mode = CMDShortcutModeIdle;
    }
}

- (NSArray *)generateHintStringsForViewCount:(int)viewCount {
    NSString *hintCharacters = kCMDFindHintCharacters;
    //Determine how many digits the link hints will require in the worst case. Usually we do not need
    //all of these digits for every link single hint, so we can show shorter hints for a few of the links.
    double digitsNeeded = ceil(log(viewCount)/log(hintCharacters.length));
    
    //Short hints are the number of hints we can possibly show which are (digitsNeeded - 1) digits in length.
    double shortHintCount = floor((pow(hintCharacters.length, digitsNeeded) - viewCount) / (double)hintCharacters.length);
    
    double longHintCount = viewCount - shortHintCount;

    NSMutableArray *hintStrings = NSMutableArray.new;

    if (digitsNeeded > 1) {
        for (int i = 0; i < shortHintCount; i++) {
            [hintStrings addObject:[self hintStringFromIndex:i characterSet:hintCharacters]];
        }
    }

    int start = shortHintCount * hintCharacters.length;
    for (int i = start; i < (start + longHintCount); i++) {
        [hintStrings addObject:[self hintStringFromIndex:i characterSet:hintCharacters]];
    }

    return [self shuffleHintStrings:hintStrings characterSetLength:hintCharacters.length];
}

/**
 * Converts a number like "8" into a hint string like "JK".
 * This is used to sequentially generate all of the hint text.
 * The hint string will be "padded with zeroes" to ensure its length is >= numberOfDigits.
 */
- (NSString *)hintStringFromIndex:(int)index characterSet:(NSString *)characterSet {
    int base = characterSet.length;
    NSMutableArray *hintStringComponents = NSMutableArray.new;
    int remainder = 0;
    int number = index;

    do {
        remainder = number % base;
        NSString *str = [NSString stringWithFormat: @"%C", [characterSet characterAtIndex:remainder]];
        [hintStringComponents insertObject:str.uppercaseString atIndex:0];
        number -= remainder;
        number /= floor(base);
    } while (number > 0);

    return [hintStringComponents componentsJoinedByString:@""];
}

/**
 * This shuffles the given set of hints so that they're scattered 
 * hints starting with the same character will be spread evenly throughout the array.
 */
- (NSArray *)shuffleHintStrings:(NSArray *)hints characterSetLength:(int)characterSetLength {
    NSMutableArray *buckets = NSMutableArray.new;
    for (int i = 0; i < characterSetLength; i++) {
        [buckets addObject:NSMutableArray.new];
    }
    int i = 0;
    for (NSString *hint in hints) {
        [buckets[(i % buckets.count)] addObject:hint];
        i++;
    }

    NSMutableArray *result = NSMutableArray.new;
    for (NSArray *bucket in buckets) {
        [result addObjectsFromArray:bucket];
    }
    return result;
}

- (void)resetHighlightedViews {
    [self.overlayView removeFromSuperview];
    for (UIView *view in self.highlighterViews) {
        [view removeFromSuperview];
    }
    [self.highlighterViews removeAllObjects];
}

- (void)highlightSubviewsOfView:(UIView *)view {
	for (UIView *subview in view.subviews) {
        if ([self shouldIgnoreView:subview]) continue;
        
        if ([self shouldHighlightView:subview]) {
            CMDHighlighterView *highlighterView = CMDHighlighterView.new;
            highlighterView.highlightColor = self.findHighlightColor;
            [self.overlayView addSubview:highlighterView];
            highlighterView.targetView = subview;
            [self.highlighterViews addObject:highlighterView];
        }
        
		[self highlightSubviewsOfView:subview];
	}
}

- (BOOL)shouldIgnoreView:(UIView *)view {
    if (view == self.overlayView) return YES;

    return NO;
}

- (BOOL)shouldHighlightView:(UIView *)view {
    if (self.mode == CMDShortcutModeFind) {
        if ([view isKindOfClass:UIControl.class]) return YES;
        if ([view isKindOfClass:UITableViewCell.class]) return YES;
        if ([view isKindOfClass:UICollectionViewCell.class]) return YES;
        if ([view isKindOfClass:NSClassFromString(@"UINavigationItemButtonView")]) return YES;
        for (UIGestureRecognizer *gestureRecognizer in view.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class]) {
                UITapGestureRecognizer *tapGestureRecognizer = (id)gestureRecognizer;
                if (tapGestureRecognizer.numberOfTapsRequired == 1) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

#pragma mark - properties

- (void)setMode:(CMDShortcutMode)mode {
    _mode = mode;

    if (mode == CMDShortcutModeIdle) {
        [self resetHighlightedViews];
        self.currentScrollView = nil;
        self.scrollSpeed = 1;
    }
}

#pragma mark - private helpers

- (UIWindow *)keyWindow {
    return UIApplication.sharedApplication.keyWindow;
}

- (UIView *)firstResponder {
    return [self.keyWindow performSelector:@selector(firstResponder)];
}

- (BOOL)isEditingText {
    // If you're writing text into a textfield, we shouldn't try run commands.
    UIView *firstResponder = self.firstResponder;
    if (firstResponder && [firstResponder conformsToProtocol:@protocol(UITextInput)]) return YES;

    return NO;
}

+ (NSString *)stringFromkey:(CMDKeyboardKey)key {
    //alphabet
    if (key == CMDKeyboardKeyA) return @"a";
    if (key == CMDKeyboardKeyB) return @"b";
    if (key == CMDKeyboardKeyC) return @"c";
    if (key == CMDKeyboardKeyD) return @"d";
    if (key == CMDKeyboardKeyE) return @"e";
    if (key == CMDKeyboardKeyF) return @"f";
    if (key == CMDKeyboardKeyG) return @"g";
    if (key == CMDKeyboardKeyH) return @"h";
    if (key == CMDKeyboardKeyI) return @"i";
    if (key == CMDKeyboardKeyJ) return @"j";
    if (key == CMDKeyboardKeyK) return @"k";
    if (key == CMDKeyboardKeyL) return @"l";
    if (key == CMDKeyboardKeyM) return @"m";
    if (key == CMDKeyboardKeyN) return @"n";
    if (key == CMDKeyboardKeyO) return @"o";
    if (key == CMDKeyboardKeyP) return @"p";
    if (key == CMDKeyboardKeyQ) return @"q";
    if (key == CMDKeyboardKeyR) return @"r";
    if (key == CMDKeyboardKeyS) return @"s";
    if (key == CMDKeyboardKeyT) return @"t";
    if (key == CMDKeyboardKeyU) return @"u";
    if (key == CMDKeyboardKeyW) return @"w";
    if (key == CMDKeyboardKeyX) return @"x";
    if (key == CMDKeyboardKeyY) return @"y";
    if (key == CMDKeyboardKeyZ) return @"z";

    //numeric
    if (key == CMDKeyboardKey1) return @"1";
    if (key == CMDKeyboardKey2) return @"2";
    if (key == CMDKeyboardKey3) return @"3";
    if (key == CMDKeyboardKey4) return @"4";
    if (key == CMDKeyboardKey5) return @"5";
    if (key == CMDKeyboardKey6) return @"6";
    if (key == CMDKeyboardKey7) return @"7";
    if (key == CMDKeyboardKey8) return @"8";
    if (key == CMDKeyboardKey9) return @"9";
    if (key == CMDKeyboardKey0) return @"0";

    return nil;
}

@end

#endif