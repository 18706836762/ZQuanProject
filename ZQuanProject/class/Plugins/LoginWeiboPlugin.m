//
//  LoginWeiboPlugin.m
//  ZQuanProject
//
//  Created by 王园园 on 2017/12/18.
//  Copyright © 2017年 zquan. All rights reserved.
//

#import "LoginWeiboPlugin.h"
#import "WeiboSDK.h"
#import "AppDelegate.h"
@implementation LoginWeiboPlugin

-(void)initMessageJson:(NSDictionary *)message
{
    [super initMessageJson:message];
    
    NSString *clientId = message[@"clientId"];
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = SINA_REDIRECTURL;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
    
    __block BOOL success = NO;
    __block NSString *token = @"";
    __block NSString *openID = @"";
    __block NSInteger type = NO;
    __block NSString *r_message = @"";
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //WEAKSELF(weakSelf);
    app.wbLoginResultBlock = ^(WBBaseResponse *response) {
        
        if(response.statusCode==WeiboSDKResponseStatusCodeSuccess){
            //成功
            success = YES;
            token = [(WBAuthorizeResponse *)response accessToken];
            openID = [(WBAuthorizeResponse *)response userID];
            NSDictionary *dict = @{@"success":@(success),@"token":token,@"openID":openID};
            [self jsHandlerData:dict ClientId:clientId];
            
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:K_sinaWBLoginData];
            
        }else if(response.statusCode==WeiboSDKResponseStatusCodeUserCancel){
            //取消
            success = NO;
            type = 0;
            r_message = @"取消授权";
            NSDictionary *dict = @{@"success":@(success),@"type":@(type),@"message":r_message};
            [self jsHandlerData:dict ClientId:clientId];
        }else {
            //失败
            success = NO;
            type = 1;
            r_message = [self statusDescript:response.statusCode];
            NSDictionary *dict = @{@"success":@(success),@"type":@(type),@"message":r_message};
            [self jsHandlerData:dict ClientId:clientId];
        }
    };
}

-(void)jsHandlerData:(NSDictionary *)data ClientId:(NSString *)clientId
{
    NSString *DatajsonStr = [Helper covertStringWithJson:data];
    
    NSString *jsStr = [NSString stringWithFormat:@"javascript: ZhuanQuanJSBridge._invokeJS(\"%@\",%@);",clientId,DatajsonStr];
    [self.web stringByEvaluatingJavaScriptFromString:jsStr];
}

-(NSString *)statusDescript:(int)statusCode
{
    switch (statusCode) {
        case WeiboSDKResponseStatusCodeSuccess:
            return @"登录成功";
            break;
        case WeiboSDKResponseStatusCodeUserCancel:
            return @"用户取消发送";
            break;
        case WeiboSDKResponseStatusCodeSentFail:
            return @"发送失败";
            break;
        case WeiboSDKResponseStatusCodeAuthDeny:
            return @"授权失败";
            break;
        case WeiboSDKResponseStatusCodeUserCancelInstall:
            return @"用户取消安装微博客户端";
            break;
        default:
            return @"登录失败";
            break;
    }
}
@end
