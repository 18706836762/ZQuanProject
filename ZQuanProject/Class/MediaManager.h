//
//  MediaManager.h
//  ZQuanProject
//
//  Created by wyy on 2018/3/16.
//  Copyright © 2018年 zquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaManager : NSObject

+(instancetype)shared;

@property(nonatomic,strong)NSString *prePlayerId;

-(void)infoValue:(NSDictionary*)value ClientId:(NSString*)clientId;

-(void)playerWithClientId:(NSString*)clientId;

-(void)pauseWithClientId:(NSString*)clientId;

-(void)stopWithClientId:(NSString*)clientId;

-(void)releaseWithClientId:(NSString*)clientId;

-(void)seekValue:(NSDictionary*)value ClientId:(NSString*)clientId;


@end
