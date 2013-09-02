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

@property (nonatomic, assign) CMDKeyboardKey findShortcutKey; //defaults to CMDKeyboardKeyF
@property (nonatomic, strong) UIColor *findHighlightColor; //defaults to greenColor

@property (nonatomic, assign) CMDKeyboardKey traverseShortcutKey; //defaults to CMDKeyboardKeyTab
@property (nonatomic, strong) UIColor *traverseHighlightColor; //defaults to blueColor

+ (instancetype)sharedManager;

- (void)handleKey:(CMDKeyboardKey)key withModifiers:(CMDKeyboardModifierKey)modifiers;
- (void)reset;

@end
