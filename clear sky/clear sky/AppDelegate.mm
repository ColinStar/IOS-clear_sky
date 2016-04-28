//
//  AppDelegate.m
//  clear sky
//
//  Created by Colin on 16/3/5.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "AppDelegate.h"
#import "MainView.h"
#import "SecondView.h"
#import "ThridView.h"
#import "FourthView.h"
#import "FifthView.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//创建Windows
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
//创建一个tabbar并设置其为根界面
    UITabBarController *tbc = [[UITabBarController alloc]init];
    [_window setRootViewController:tbc];

//为TabBar添加子控制器
    MainView *mv = [[MainView alloc]init];
    //第一个为scrollview时自动分配64点 取消偏移
    mv.automaticallyAdjustsScrollViewInsets = NO;
    UINavigationController* mvna = [[UINavigationController alloc]initWithRootViewController:mv];
    mv.navigationItem.title = @"主页";
    mv.tabBarItem.title = @"主页";
    mv.tabBarItem.image = [UIImage imageNamed:@"ios7-home.png"];
    mv.tabBarItem.selectedImage = [UIImage imageNamed:@"ios-home-outline.png"];
    
    SecondView *sv = [[SecondView alloc]init];
    UINavigationController* svna = [[UINavigationController alloc]initWithRootViewController:sv];
    sv.navigationItem.title = @"晴空社区";
    sv.tabBarItem.title = @"社区";
    sv.tabBarItem.image = [UIImage imageNamed:@"ios7-ionic.png"];
    sv.tabBarItem.selectedImage = [UIImage imageNamed:@"ios-ionic-outline.png"];
    
    ThridView *tv = [[ThridView alloc]init];
    UINavigationController *tvna = [[UINavigationController alloc]initWithRootViewController:tv];
    tv.navigationItem.title = @"投诉";
    tv.tabBarItem.title = @"拍照";
    tv.tabBarItem.image = [UIImage imageNamed:@"ios7-camera-outline.png"];
    tv.tabBarItem.selectedImage = [UIImage imageNamed:@"ios7-camera.png"];
    
    FourthView *fv = [[FourthView alloc]init];
    UINavigationController *fvna = [[UINavigationController alloc]initWithRootViewController:fv];
    fv.navigationItem.title = @"话题";
    fv.tabBarItem.title = @"话题";
    fv.tabBarItem.image = [UIImage imageNamed:@"ios7-chatboxes-outline.png"];
    fv.tabBarItem.selectedImage = [UIImage imageNamed:@"ios7-chatboxes.png"];
    
    FifthView * fiv = [[FifthView alloc]init];
    UINavigationController *fivna = [[UINavigationController alloc]initWithRootViewController:fiv];
    fiv.navigationItem.title = @"个人信息";
    fiv.tabBarItem.title = @"个人";
    fiv.tabBarItem.image = [UIImage imageNamed:@"ios7-person-outline.png"];
    fiv.tabBarItem.image = [UIImage imageNamed:@"ios7-person.png"];
    
//添加到tabber
    tbc.viewControllers=@[mvna,svna,tvna,fvna,fivna];
    
//显示Windows
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
