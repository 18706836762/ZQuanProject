//
//  MediaPlugin.m
//  ZQuanProject
//
//  Created by wyy on 2018/3/13.
//  Copyright © 2018年 zquan. All rights reserved.
//

#import "MediaPlugin.h"
#import "MediaManager.h"

@implementation MediaPlugin

-(void)initMessageJson:(NSDictionary *)message
{
    [super initMessageJson:message];
    
    NSString *clientId = message[@"clientId"];
    
    if(IS_DICTIONARY_CLASS(message[@"param"])){
        
        NSDictionary *param = message[@"param"];
        NSString *key = param[@"key"];
        NSDictionary *value = [param.allKeys containsObject:@"value"]? param[@"value"]:nil;
        
        if([key isEqualToString:@"info"]){
            
            [[MediaManager shared] infoValue:value ClientId:clientId];
            
        }else if([key isEqualToString:@"play"]){
            
            if(value==nil){
                [[MediaManager shared] playerWithClientId:clientId];
            }else{
                [[MediaManager shared] infoValue:value ClientId:clientId];
            }
            
        }else if([key isEqualToString:@"pause"]){
            
            [[MediaManager shared] pauseWithClientId:clientId];
            
        }else if([key isEqualToString:@"stop"]){
            
            [[MediaManager shared] stopWithClientId:clientId];
            
        }else if([key isEqualToString:@"release"]){
            
            [[MediaManager shared] releaseWithClientId:clientId];
            
        }else if([key isEqualToString:@"seek"]){
            
            if(value){
                [[MediaManager shared] seekValue:value ClientId:clientId];
            }
        }
    }
}

@end

