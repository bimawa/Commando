//
//  CMDCommandoApplication.h
//  Commando
//
//  Created by Jonas Budelmann on 30/08/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMDKeyboard.h"

@interface CMDShortcutManager : NSObject

@property (nonatomic, assign) CMDKeyboardKey popNavigationItemShortcutKey; //defaults to CMDKeyboardKeyBackspace

@property (nonatomic, assign) CMDKeyboardKey findHitZonesShortcutKey; //defaults to CMDKeyboardKeyF
@property (nonatomic, strong) UIColor *findHitZonesHighlightColor; //defaults to greenColor

+ (instancetype)sharedManager;

- (void)handleKey:(CMDKeyboardKey)key withModifiers:(CMDKeyboardModifierKey)modifiers;
- (void)reset;

@end
