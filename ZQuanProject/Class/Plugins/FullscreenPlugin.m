//
//  FullscreenPlugin.m
//  ZQuanProject
//
//  Created by wyy on 2018/3/23.
//  Copyright © 2018年 zquan. All rights reserved.
//

#import "FullscreenPlugin.h"

@implementation FullscreenPlugin

-(void)initMessageJson:(NSDictionary *)message
{
    [super initMessageJson:message];
    [self.webVC startFullScreen];
}
@end
