//
//  UIView+CMDAdditions.h
//  CommandoExample
//
//  Created by Jonas Budelmann on 2/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

#if (TARGET_IPHONE_SIMULATOR)

@interface UIView (CMDAdditions)

- (void)cmd_fireTapEvents;

- (NSArray *)cmd_findSubviewsOfClass:(Class)aClass;
- (UIView *)cmd_findSubviewOfClass:(Class)aClass;

@end

#endif