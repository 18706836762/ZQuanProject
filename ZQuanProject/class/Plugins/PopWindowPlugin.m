//
//  PopWindowPlugin.m
//  ZQuanProject
//
//  Created by 王园园 on 2017/12/18.
//  Copyright © 2017年 zquan. All rights reserved.
//

#import "PopWindowPlugin.h"

@implementation PopWindowPlugin

-(void)initMessageJson:(NSDictionary *)message
{
    [super initMessageJson:message];
    
    //NSString *clientId = message[@"clientId"];
    
    NSString *param = [NSString stringWithFormat:@"%@",message[@"param"]];
    if(IsEmptyStr(param)){
        param = nil;
    }
    
    if(self.webVC.navigationController.viewControllers.count>1){
        NSInteger index = [self.webVC.navigationController.viewControllers indexOfObject:self.webVC];
        ZQUIWebViewController *preWebVC = [self.webVC.navigationController.viewControllers objectAtIndex:index-1];
        [preWebVC emitWithEvenParam:param];
    }
    
    [self.webVC.navigationController popViewControllerAnimated:YES];
}

@end
