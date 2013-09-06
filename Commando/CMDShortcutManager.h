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

@property (nonatomic, assign) CMDKeyInputCode popNavigationItemShortcutKey; //defaults to CMDKeyInputCodeBackspace

@property (nonatomic, assign) CMDKeyInputCode findHitZonesShortcutKey; //defaults to CMDKeyInputCodeF
@property (nonatomic, strong) UIColor *findHitZonesHighlightColor; //defaults to greenColor

+ (instancetype)sharedManager;

- (void)handleKey:(CMDKeyInputCode)key withModifiers:(CMDKeyModifier)modifiers;
- (void)reset;

@end
