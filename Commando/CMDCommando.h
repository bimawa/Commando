//
//  CMDCommando.h
//  CommandoExample
//
//  Created by Javier Soto on 9/6/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#define CMD_COMMANDO_ENABLED DEBUG

#if CMD_COMMANDO_ENABLED

typedef NS_OPTIONS(NSUInteger, CMDKeyModifier) {
	CMDKeyModifierNone = 0,
    CMDKeyModifierAlphaShift     = 1 << 16, //capslock
    CMDKeyModifierShift          = 1 << 17,
    CMDKeyModifierControl        = 1 << 18,
    CMDKeyModifierAlternate      = 1 << 19, //otp
    CMDKeyModifierCommand        = 1 << 20,
    CMDKeyModifierNumericPad     = 1 << 21,
};

typedef NS_ENUM(NSUInteger, CMDKeyInputCode) {
	CMDKeyInputCodeLeft = 80,
	CMDKeyInputCodeUp = 82,
	CMDKeyInputCodeDown = 81,
	CMDKeyInputCodeRight = 79,

	CMDKeyInputCodeA = 4,
	CMDKeyInputCodeB = 5,
	CMDKeyInputCodeC = 6,
	CMDKeyInputCodeD = 7,
	CMDKeyInputCodeE = 8,
	CMDKeyInputCodeF = 9,
	CMDKeyInputCodeG = 10,
	CMDKeyInputCodeH = 11,
	CMDKeyInputCodeI = 12,
	CMDKeyInputCodeJ = 13,
	CMDKeyInputCodeK = 14,
	CMDKeyInputCodeL = 15,
	CMDKeyInputCodeM = 16,
	CMDKeyInputCodeN = 17,
	CMDKeyInputCodeO = 18,
	CMDKeyInputCodeP = 19,
	CMDKeyInputCodeQ = 20,
	CMDKeyInputCodeR = 21,
	CMDKeyInputCodeS = 22,
	CMDKeyInputCodeT = 23,
	CMDKeyInputCodeU = 24,
	CMDKeyInputCodeV = 25,
	CMDKeyInputCodeW = 26,
	CMDKeyInputCodeX = 27,
	CMDKeyInputCodeY = 28,
	CMDKeyInputCodeZ = 29,

	CMDKeyInputCode0 = 39,
	CMDKeyInputCode1 = 30,
	CMDKeyInputCode2 = 31,
	CMDKeyInputCode3 = 32,
	CMDKeyInputCode4 = 33,
	CMDKeyInputCode5 = 34,
	CMDKeyInputCode6 = 35,
	CMDKeyInputCode7 = 36,
	CMDKeyInputCode8 = 37,
	CMDKeyInputCode9 = 38,

	CMDKeyInputCodeEscape = 41,
	CMDKeyInputCodeBackspace = 42,
	CMDKeyInputCodeDelete = 76,
	CMDKeyInputCodeTab = 43,
	CMDKeyInputCodeEnter = 40,
	CMDKeyInputCodeReturn = 88,
};

#endif
