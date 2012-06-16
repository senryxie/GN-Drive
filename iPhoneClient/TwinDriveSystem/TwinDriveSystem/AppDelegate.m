//
//  AppDelegate.m
//  TwinDriveSystem
//
//  Created by 钟 声 on 12-2-12.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "AppDelegate.h"
#import "GNViewController.h"
#import "TDSLoggerView.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize reachabilityObj;

- (void)dealloc
{
    self.reachabilityObj = nil;
    self.window = nil;
    self.viewController = nil;
    [super dealloc];
}

- (void)reachabilityChanged:(NSNotification *)note {
    
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    switch (status) 
    {
        case NotReachable:
            NSLog(@"网络不可用，请打开蜂窝数据或者WIFI.");
            [[TDSHudView getInstance] showHudOnWindow:@"网络不可用，\n请打开蜂窝数据或者WIFI."
                                                image:nil
                                            acitivity:NO
                                         autoHideTime:1.5f];    
            [[NSNotificationCenter defaultCenter] postNotificationName:TDSNetStatueChangedNotication 
                                                                object:self.reachabilityObj];
            break;
        case ReachableViaWiFi:
            NSLog(@"正在使用WIFI.");
            [[NSNotificationCenter defaultCenter] postNotificationName:TDSNetStatueChangedNotication 
                                                                object:self.reachabilityObj];
            break;
        case ReachableViaWWAN:
            NSLog(@"正在使用WWAN.");
            [[NSNotificationCenter defaultCenter] postNotificationName:TDSNetStatueChangedNotication 
                                                                object:self.reachabilityObj];            
            break;
        default:
            break;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[GNViewController alloc] init] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
//    [TDSLoggerView getInstance];
    
    // 监听网络
    self.reachabilityObj = [Reachability reachabilityWithHostName:@"sae.sina.com.cn"];
    [self.reachabilityObj startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    
    
    // weixin SDK 注册本app 的 URL Scheme
    [WXApi registerApp:@"icePhone-TDS"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WXApi handleOpenURL:url delegate:self];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}



@end
