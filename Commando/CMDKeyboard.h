//
//  CMDConstants.h
//  Commando
//
//  Created by Jonas Budelmann on 30/08/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

// https://github.com/kennytm/iphone-private-frameworks/blob/master/GraphicsServices/GSEvent.h

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, CMDKeyboardModifierKey) {
	CMDKeyboardModifierKeyNone = 0,
	CMDKeyboardModifierKeyShift = 1 << 17,
	CMDKeyboardModifierKeyCtrl = 1 << 20,
	CMDKeyboardModifierKeyAlt = 1 << 19,
	CMDKeyboardModifierKeyCmd = 1 << 16
};

typedef NS_ENUM(NSUInteger, CMDKeyboardKey) {
	CMDKeyboardKeyLeft = 80,
	CMDKeyboardKeyUp = 82,
	CMDKeyboardKeyDown = 81,
	CMDKeyboardKeyRight = 79,

	CMDKeyboardKeyA = 4,
	CMDKeyboardKeyB = 5,
	CMDKeyboardKeyC = 6,
	CMDKeyboardKeyD = 7,
	CMDKeyboardKeyE = 8,
	CMDKeyboardKeyF = 9,
	CMDKeyboardKeyG = 10,
	CMDKeyboardKeyH = 11,
	CMDKeyboardKeyI = 12,
	CMDKeyboardKeyJ = 13,
	CMDKeyboardKeyK = 14,
	CMDKeyboardKeyL = 15,
	CMDKeyboardKeyM = 16,
	CMDKeyboardKeyN = 17,
	CMDKeyboardKeyO = 18,
	CMDKeyboardKeyP = 19,
	CMDKeyboardKeyQ = 20,
	CMDKeyboardKeyR = 21,
	CMDKeyboardKeyS = 22,
	CMDKeyboardKeyT = 23,
	CMDKeyboardKeyU = 24,
	CMDKeyboardKeyV = 25,
	CMDKeyboardKeyW = 26,
	CMDKeyboardKeyX = 27,
	CMDKeyboardKeyY = 28,
	CMDKeyboardKeyZ = 29,

	CMDKeyboardKey0 = 39,
	CMDKeyboardKey1 = 30,
	CMDKeyboardKey2 = 31,
	CMDKeyboardKey3 = 32,
	CMDKeyboardKey4 = 33,
	CMDKeyboardKey5 = 34,
	CMDKeyboardKey6 = 35,
	CMDKeyboardKey7 = 36,
	CMDKeyboardKey8 = 37,
	CMDKeyboardKey9 = 38,

	CMDKeyboardKeyEscape = 41,
	CMDKeyboardKeyBackspace = 42,
	CMDKeyboardKeyDelete = 76,
	CMDKeyboardKeyTab = 43,
	CMDKeyboardKeyEnter = 40,
	CMDKeyboardKeyReturn = 88,
};
