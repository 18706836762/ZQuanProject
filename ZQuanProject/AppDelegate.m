//
//  AppDelegate.m
//  ZQuanProject
//
//  Created by wyy on 2017/12/12.
//  Copyright © 2017年 zquan. All rights reserved.
//

#import "AppDelegate.h"
#import "ZQLaunchViewController.h"
#import "ZQUIWebViewController.h"
#import "JZNetObserver.h"
#import "WebNSURLProtocol.h"
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>
#import <UMMobClick/MobClick.h>
#import "EBBannerView.h"
#import <Bugly/Bugly.h>
#import "PushWindowPlugin.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    _window.rootViewController = [[ZQLaunchViewController alloc] init];
    [_window makeKeyAndVisible];
    
    [NSURLProtocol registerClass:[WebNSURLProtocol class]];
    
    [self modifyWebViewUserAgent];
    
    //监测网络
    [[JZNetObserver shared] observeNetStatus];
    
    //注册通知
    [self registNotify];
    
    //友盟
    [self initUMMob];
    
    //BUGLY
    [self initBugly];
    
    //sina
    [self registSina];
    
    return YES;
}


-(void)modifyWebViewUserAgent
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    NSString *str = [NSString stringWithFormat:@" app/ZhuanQuan/%@",IOSVersion];
    NSString *newAgent = [oldAgent stringByAppendingString:str];
    NSLog(@"new agent :%@", newAgent);

    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}


-(void)registNotify
{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //请求获取通知权限
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"同意开启通知");
            }
        }];
    } else {
        // Fallback on earlier versions
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types!= UIUserNotificationTypeNone) {
            NSLog(@"同意开启通知");
        }else{
            [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customTopBannerDidClick:) name:EBBannerViewDidClickNotification object:nil];
}


-(void)initUMMob
{
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion: XcodeAppVersion];
    UMConfigInstance.appKey = UMENG_APPKEY;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];
}

-(void)initBugly
{
    [Bugly startWithAppId:BUGLY_APPID];
}

-(void)registSina
{
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:SINA_APPKEY];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter] postNotificationName:KObserveAPPActiveNotify object:@(NO)];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:KObserveAPPActiveNotify object:@(YES)];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];//进入前台取消应用消息图标
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WeiboSDK handleOpenURL:url delegate:self ];
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if(_wbLoginResultBlock){
            _wbLoginResultBlock(response);
        }
    }
}


- (void)didReceiveWeiboRequest:(WBBaseRequest *)request { 
    
}



#pragma mark 调用过用户注册通知方法之后执行（也就是调用完registerUserNotificationSettings:方法之后执行）
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
}



/**
 * 当用户点击本地通知进入app的时候调用
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [self receiveNotifyPushWebParam:userInfo];
}
-(void)customTopBannerDidClick:(NSNotification *)notify
{
    NSDictionary *notifyInfo = [notify object];
    [self receiveNotifyPushWebParam:notifyInfo];
}


-(void)receiveNotifyPushWebParam:(NSDictionary *)param
{
    if(param==nil || param[@"data"]==nil) return;
    if(!IsEmptyStr(param[@"data"][@"url"])){
        if([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[UINavigationController class]]){
            NSMutableDictionary *newParam = [NSMutableDictionary dictionaryWithDictionary:param];
            [newParam setObject:param[@"data"][@"url"] forKey:@"url"];
            NSDictionary *message = @{@"param":newParam};
            PushWindowPlugin *pushPlugin = [[PushWindowPlugin alloc] init];
            [pushPlugin initMessageJson:message];
        }else{
            //当前启动页  进入首页后跳转
            [[NSUserDefaults standardUserDefaults] setObject:param forKey:K_ReceiveNotifyURL];
        }
    }
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if(_isFull){
        return UIInterfaceOrientationMaskAll;
    }else
    return UIInterfaceOrientationMaskPortrait;
}

@end
