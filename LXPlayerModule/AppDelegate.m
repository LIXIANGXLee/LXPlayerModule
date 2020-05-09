//
//  AppDelegate.m
//  LXPlayerModule
//
//  Created by Mac on 2020/5/9.
//  Copyright © 2020 李响. All rights reserved.
//

#import "AppDelegate.h"
#import "LXPlayVideoViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = [[LXPlayVideoViewController alloc]init];
    
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}

@end
