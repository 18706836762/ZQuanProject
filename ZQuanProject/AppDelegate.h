//
//  AppDelegate.h
//  ZQuanProject
//
//  Created by wyy on 2017/12/12.
//  Copyright © 2017年 zquan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"

typedef void(^WBLoginResultBlock)(WBBaseResponse *response);

@interface AppDelegate : UIResponder <UIApplicationDelegate,WeiboSDKDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,strong)WBLoginResultBlock wbLoginResultBlock;

@property (nonatomic,assign)BOOL isFull;

-(void)receiveNotifyPushWebParam:(NSDictionary *)param;

@end

