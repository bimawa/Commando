//
//  CMDShortcutManager.m
//  Commando
//
//  Created by Jonas Budelmann on 30/08/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CMDShortcutManager.h"

#if CMD_COMMANDO_ENABLED

#import "CMDOverlayController.h"
#import "UITouch+CMDAdditions.h"
#import "UIView+CMDAdditions.h"

static double const kCMDFindCompleteDelay = 0.3;
static NSString* const kCMDFindHintCharacters = @"sadfjklewcmpgh";

NSUInteger CMDKeyDeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

typedef NS_ENUM(NSUInteger, CMDShortcutMode) {
	CMDShortcutModeIdle,
    CMDShortcutModeFindHitZones
};

@interface CMDShortcutManager ()

@property (nonatomic, assign) CMDShortcutMode mode;
@property (nonatomic, assign) CMDKeyInputCode currentKeyDown;
@property (nonatomic, assign) CMDKeyModifier currentKeyModifiers;
@property (nonatomic, strong) NSString *findSearchString;
@property (nonatomic, weak) UIScrollView *currentScrollView;
@property (nonatomic, assign) CGFloat scrollSpeed;
@property (nonatomic, strong) NSTimer *scrollTimer;
@property (nonatomic, strong) CMDOverlayController *overlayController;

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

    self.currentKeyDown = NSNotFound;
    self.currentKeyModifiers = CMDKeyModifierNone;
    self.overlayController = CMDOverlayController.new;

    //defaults
    self.popNavigationItemShortcutKey = CMDKeyInputCodeBackspace;
    self.findHitZonesShortcutKey = CMDKeyInputCodeF;
    self.findHitZonesHighlightColor = UIColor.greenColor;
    
    // listen for device orientation changes to reset mode
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - notifications

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification {
    self.mode = CMDShortcutModeIdle;
}

#pragma mark - public

- (void)handleKeyDown:(CMDKeyInputCode)key withModifiers:(CMDKeyModifier)modifiers {
    BOOL newKey = self.currentKeyDown != key;
    self.currentKeyDown = key;
    self.currentKeyModifiers = modifiers;
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;

    BOOL isEditingText = [self isEditingText];
    if (key == CMDKeyInputCodeEscape) {
        [self escape];
    }

    //exit early if was editing text
    if (isEditingText) return;
    
    if (self.mode == CMDShortcutModeIdle) {
        if (key == self.findHitZonesShortcutKey) {
            [self activateFindHitZones];
        } else if (key == self.popNavigationItemShortcutKey) {
            [self popNavigationItem];
        } else if ([self isScrollKey:key]) {
            if (newKey) {
                self.scrollSpeed = 1;
            }
            [self scrollWithKey:key];
            if (CMDKeyDeviceSystemMajorVersion() > 6) {
                self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(repeatKey) userInfo:nil repeats:YES];
            }
        }
    } else {
        if (self.mode == CMDShortcutModeFindHitZones) {
            //filter tapable views
            [self filterHighlightedViewsWithKey:key];
        }
    }
}

- (void)handleKeyUp:(CMDKeyInputCode)key withModifiers:(CMDKeyModifier)modifiers {
    self.currentKeyDown = NSNotFound;
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
}

- (void)repeatKey {
    if ([self isScrollKey:self.currentKeyDown]) {
        [self scrollWithKey:self.currentKeyDown];
    }
}

- (void)reset {
    self.mode = CMDShortcutModeIdle;
}

- (void)escape {
    if ([self isEditingText]) {
        //allow escape to end editing of textfields etc
        [self.keyWindow endEditing:YES];
    }

    if (self.mode == CMDShortcutModeIdle) {
        UIView *firstResponder = self.firstResponder;

        //in iOS7 alertviews are no longer keyWindow
        firstResponder = firstResponder ?: [NSClassFromString(@"_UIAlertManager") performSelector:@selector(visibleAlert)];

        if ([firstResponder isKindOfClass:UIAlertView.class]) {
            //dismiss alertview
            UIAlertView *alertView = (id)firstResponder;
            [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
        } else if ([firstResponder isKindOfClass:UIActionSheet.class]) {
            //dismiss actionsheet
            UIActionSheet *actionSheet = (id)firstResponder;
            [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
        }
    }
    self.mode = CMDShortcutModeIdle;
}

- (void)popNavigationItem {
    UINavigationBar *navigationBar = (id)[self.keyWindow cmd_findSubviewMatching:^BOOL(UIView *subview) {
        return [subview isKindOfClass:UINavigationBar.class];
    }];

    //cannot call [navigationBar popNavigationItemAnimated:YES] if navigationBar is within a UINavigationController
    UINavigationController *navigationController = [navigationBar.delegate isKindOfClass:UINavigationController.class] ? navigationBar.delegate : nil ;
    if (navigationController) {
        [navigationController popViewControllerAnimated:YES];
    } else {
        [navigationBar popNavigationItemAnimated:YES];
    }
}

- (void)activateFindHitZones {
    [self resetHighlightedViews];
    self.mode = CMDShortcutModeFindHitZones;
    self.findSearchString = @"";

    self.overlayController.hidden = NO;

    //find all tapable views
    NSMutableArray *tapableViews = NSMutableArray.new;
    NSArray *windows = (self.currentKeyModifiers & CMDKeyModifierShift) ? UIApplication.sharedApplication.windows : @[UIApplication.sharedApplication.keyWindow];

    for (UIWindow *window in windows) {
        [tapableViews addObjectsFromArray:[window cmd_findSubviewsMatching:^BOOL(UIView *view) {
            if ([view isKindOfClass:UIWindow.class]) return NO;
            if (view == self.overlayController.view) return NO;
            if (![view cmd_isVisible]) return NO;
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
            return NO;
        }]];
    }

    NSArray *hintStrings = [self generateHintStringsForViewCount:tapableViews.count];

    int i = 0;
    for (UIView *view in tapableViews) {
        [self.overlayController highlightView:view color:self.findHitZonesHighlightColor hint:hintStrings[i]];
        i++;
	}
}

- (BOOL)isScrollKey:(CMDKeyInputCode)key {
    return (key == CMDKeyInputCodeLeft ||
            key == CMDKeyInputCodeRight ||
            key == CMDKeyInputCodeUp ||
            key == CMDKeyInputCodeDown);
}

- (void)scrollWithKey:(CMDKeyInputCode)key {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reset) object:nil];
    if (!self.currentScrollView) {
        NSMutableArray *scrollViews = NSMutableArray.new;

        NSArray *windows = (self.currentKeyModifiers & CMDKeyModifierShift) ? UIApplication.sharedApplication.windows : @[UIApplication.sharedApplication.keyWindow];
        for (UIWindow *window in windows) {
            [scrollViews addObjectsFromArray:[window cmd_findSubviewsMatching:^BOOL(UIView *subview) {
                return [subview isKindOfClass:UIScrollView.class];
            }]];
        }

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
    if (key == CMDKeyInputCodeDown) {
        contentOffset.y += self.scrollSpeed;
    }
    if (key == CMDKeyInputCodeUp) {
        contentOffset.y -= self.scrollSpeed;
    }
    if (key == CMDKeyInputCodeLeft) {
        contentOffset.x -= self.scrollSpeed;
    }
    if (key == CMDKeyInputCodeRight) {
        contentOffset.x += self.scrollSpeed;
    }
    contentOffset.x = MIN(MAX(0, contentOffset.x), MAX(self.currentScrollView.contentSize.width - CGRectGetWidth(self.currentScrollView.frame), 0));
    contentOffset.y = MIN(MAX(0, contentOffset.y), MAX(self.currentScrollView.contentSize.height - CGRectGetHeight(self.currentScrollView.frame), 0));
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.currentScrollView.contentOffset = contentOffset;
    } completion:nil];
    [self performSelector:@selector(reset) withObject:nil afterDelay:0.3];
}

#pragma mark - fake touch events

- (void)performTapOnView:(UIView *)view {
    [view cmd_fireTapEvents];
    self.mode = CMDShortcutModeIdle;
}

#pragma mark - highlighting

- (void)filterHighlightedViewsWithKey:(CMDKeyInputCode)key {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (key == CMDKeyInputCodeBackspace) {
        //deleting text
        if (self.findSearchString.length) {
            self.findSearchString = [self.findSearchString substringToIndex:self.findSearchString.length-1];
        } else {
            self.mode = CMDShortcutModeIdle;
            return;
        }
    } else {
        NSString *keyString = [self.class stringFromkey:key];
        if (keyString) {
            self.findSearchString = [self.findSearchString stringByAppendingString:keyString];
        }
    }

    [self.overlayController findViewMatching:self.findSearchString completion:^(UIView *targetView, BOOL hasPartialMatches){
        //simulate click on this view
        if (targetView) {
            [self performSelector:@selector(performTapOnView:) withObject:targetView afterDelay:kCMDFindCompleteDelay];
        }
        if (!hasPartialMatches) {
            self.mode = CMDShortcutModeIdle;
        }
    }];
}

- (void)resetHighlightedViews {
    self.overlayController.hidden = YES;
}

#pragma mark - hint code generation

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

+ (NSString *)stringFromkey:(CMDKeyInputCode)key {
    //alphabet
    if (key == CMDKeyInputCodeA) return @"a";
    if (key == CMDKeyInputCodeB) return @"b";
    if (key == CMDKeyInputCodeC) return @"c";
    if (key == CMDKeyInputCodeD) return @"d";
    if (key == CMDKeyInputCodeE) return @"e";
    if (key == CMDKeyInputCodeF) return @"f";
    if (key == CMDKeyInputCodeG) return @"g";
    if (key == CMDKeyInputCodeH) return @"h";
    if (key == CMDKeyInputCodeI) return @"i";
    if (key == CMDKeyInputCodeJ) return @"j";
    if (key == CMDKeyInputCodeK) return @"k";
    if (key == CMDKeyInputCodeL) return @"l";
    if (key == CMDKeyInputCodeM) return @"m";
    if (key == CMDKeyInputCodeN) return @"n";
    if (key == CMDKeyInputCodeO) return @"o";
    if (key == CMDKeyInputCodeP) return @"p";
    if (key == CMDKeyInputCodeQ) return @"q";
    if (key == CMDKeyInputCodeR) return @"r";
    if (key == CMDKeyInputCodeS) return @"s";
    if (key == CMDKeyInputCodeT) return @"t";
    if (key == CMDKeyInputCodeU) return @"u";
    if (key == CMDKeyInputCodeW) return @"w";
    if (key == CMDKeyInputCodeX) return @"x";
    if (key == CMDKeyInputCodeY) return @"y";
    if (key == CMDKeyInputCodeZ) return @"z";

    //numeric
    if (key == CMDKeyInputCode1) return @"1";
    if (key == CMDKeyInputCode2) return @"2";
    if (key == CMDKeyInputCode3) return @"3";
    if (key == CMDKeyInputCode4) return @"4";
    if (key == CMDKeyInputCode5) return @"5";
    if (key == CMDKeyInputCode6) return @"6";
    if (key == CMDKeyInputCode7) return @"7";
    if (key == CMDKeyInputCode8) return @"8";
    if (key == CMDKeyInputCode9) return @"9";
    if (key == CMDKeyInputCode0) return @"0";

    return nil;
}

@end

#endif
