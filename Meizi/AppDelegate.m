//
//  AppDelegate.m
//  Meizi
//
//  Created by Sunnyyoung on 15/4/4.
//  Copyright (c) 2015年 Sunnyyoung. All rights reserved.
//

#import "AppDelegate.h"
#import "SYNetwork.h"
@import GoogleMobileAds;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Set Network
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //Set SVProgressHUD
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-7366328858638561~3346265539"];
    
    return YES;
}

@end
