//
//  HTTPCache.m
//  ZQuanProject
//
//  Created by wyy on 2018/3/20.
//  Copyright © 2018年 zquan. All rights reserved.
//

#import "HTTPCache.h"
#import "KTVHTTPCache.h"


@implementation HTTPCache


+ (void)setupHTTPCache
{
    [KTVHTTPCache logSetConsoleLogEnable:NO];
    [HTTPCache startHTTPServer];
    [HTTPCache configurationFilters];
}

+(void)startHTTPServer
{
    NSError * error;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
        NSLog(@"Proxy Start Failure, %@", error);
    } else {
        NSLog(@"Proxy Start Success");
    }
}

+ (void)configurationFilters
{
#if 0
    // URL Filter
    [KTVHTTPCache cacheSetURLFilterForArchive:^NSString *(NSString * originalURLString) {
        NSLog(@"URL Filter reviced URL, %@", originalURLString);
        return originalURLString;
    }];
#endif
    
#if 0
    // Content-Type Filter
    [KTVHTTPCache cacheSetContentTypeFilterForResponseVerify:^BOOL(NSString * URLString,
                                                                   NSString * contentType,
                                                                   NSArray<NSString *> * defaultAcceptContentTypes) {
        NSLog(@"Content-Type Filter reviced Content-Type, %@", contentType);
        if ([defaultAcceptContentTypes containsObject:contentType]) {
            return YES;
        }
        return NO;
    }];
#endif
}



@end
