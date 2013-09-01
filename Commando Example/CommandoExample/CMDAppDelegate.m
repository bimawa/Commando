//
//  CMDAppDelegate.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 30/08/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CMDAppDelegate.h"
#import "CMDRootViewController.h"

@implementation CMDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    // Override point for customization after application launch.
    self.window.backgroundColor = UIColor.whiteColor;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:CMDRootViewController.new];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
