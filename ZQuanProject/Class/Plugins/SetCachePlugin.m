//
//  SetCachePlugin.m
//  ZQuanProject
//
//  Created by 王园园 on 2018/2/5.
//  Copyright © 2018年 zquan. All rights reserved.
//

#import "SetCachePlugin.h"

@implementation SetCachePlugin

-(void)initMessageJson:(NSDictionary *)message
{
    [super initMessageJson:message];
    
    if(IS_DICTIONARY_CLASS(message[@"param"])){
        
        NSDictionary *param = message[@"param"];
        
        if([param[@"key"] isKindOfClass:[NSArray class]]){
            
            NSArray *keys = [NSArray arrayWithArray:param[@"key"]];
            NSArray *values = [NSArray arrayWithArray:param[@"value"]];
            
            [keys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *key = obj;
                if(values.count>idx){
                    NSString *value = [NSString stringWithFormat:@"%@",values[idx]];
                    if(!IsEmptyStr(value)){
                        
                        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                    }else{
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }else{
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            }];
            
            
        }else if([param[@"key"] isKindOfClass:[NSString class]]){
            NSString *key = param[@"key"];
            
            NSString *value = [NSString stringWithFormat:@"%@",param[@"value"]];
            if(!IsEmptyStr(value)){
                
                [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
            }else{
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            }
        }
        
        NSString *clientId = message[@"clientId"];
        
        NSString *jsStr = [NSString stringWithFormat:@"javascript: ZhuanQuanJSBridge._invokeJS(\"%@\");",clientId];

        [self.web stringByEvaluatingJavaScriptFromString:jsStr];
    }
}



@end
