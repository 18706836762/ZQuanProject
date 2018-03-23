//
//  ZQUIWebViewController.h
//  ZQuanProject
//
//  Created by 王园园 on 2017/12/24.
//  Copyright © 2017年 zquan. All rights reserved.
//

#import "ViewController.h"
#import "BaseViewController.h"

@interface ZQUIWebViewController : BaseViewController

//网址链接
@property (nonatomic, copy) NSString *URLString;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic,strong)UIRefreshControl *refreshControl;

@property (nonatomic, assign) BOOL isdoFresh;

@property (nonatomic, assign) BOOL refreshState;


-(void)emitWithEvenParam:(NSString *)paramStr;

-(void)startFullScreen;
@end
