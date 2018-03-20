//
//  MediaManager.m
//  ZQuanProject
//
//  Created by wyy on 2018/3/16.
//  Copyright © 2018年 zquan. All rights reserved.
//

#import "MediaManager.h"
#import "HTTPCache.h"
#import "KTVHTTPCache.h"
#import <AVFoundation/AVFoundation.h>
#import "ZQWebVCSingleton.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MediaManager()

@property(nonatomic,strong) AVPlayer *player;
@property(nonatomic,strong) id timeObserve;

@end


@implementation MediaManager

static MediaManager *mediaManager;


+(instancetype)shared;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediaManager = [[MediaManager alloc] init]; //初始化播放管理类单例
        [HTTPCache setupHTTPCache];
    });
    return mediaManager;
}


-(void)infoValue:(NSDictionary*)value ClientId:(NSString*)clientId;
{
    NSString *valueId = [NSString stringWithFormat:@"%@",value[@"id"]];
    if(_prePlayerId!=nil && [_prePlayerId isEqualToString:valueId])
        return;
    _prePlayerId = valueId;
    NSString *valueUrl = [NSString stringWithFormat:@"%@",value[@"url"]];
    
    NSString * proxyURLString = [KTVHTTPCache proxyURLStringWithOriginalURLString:valueUrl];

    [self setupPlayer:proxyURLString];
}


-(void)playerWithClientId:(NSString*)clientId;
{
    //继续播放当前歌曲
    [_player play];
    [self configNowPlayingCenter];
    
    if(!IsEmptyStr(clientId)&&[ZQWebVCSingleton shareInstance].webVC.webView!=nil){
        NSDictionary *dict = @{@"id":_prePlayerId};
        NSString *jsStr = [NSString stringWithFormat:@"javascript: ZhuanQuanJSBridge._invokeJS(\"%@\",%@);",clientId,[Helper covertStringWithJson:dict]];
        [[ZQWebVCSingleton shareInstance].webVC.webView stringByEvaluatingJavaScriptFromString:jsStr];
    }
}


-(void)pauseWithClientId:(NSString*)clientId;
{
    [_player pause];
    
    if(!IsEmptyStr(clientId)&&[ZQWebVCSingleton shareInstance].webVC.webView!=nil){
        NSDictionary *dict = @{@"id":_prePlayerId};
        NSString *jsStr = [NSString stringWithFormat:@"javascript: ZhuanQuanJSBridge._invokeJS(\"%@\",%@);",clientId,[Helper covertStringWithJson:dict]];
        [[ZQWebVCSingleton shareInstance].webVC.webView stringByEvaluatingJavaScriptFromString:jsStr];
    }
}


-(void)stopWithClientId:(NSString*)clientId;
{
    [_player seekToTime:kCMTimeZero];
    [_player pause];
    
    if(!IsEmptyStr(clientId)&&[ZQWebVCSingleton shareInstance].webVC.webView!=nil){
        NSDictionary *dict = @{@"id":_prePlayerId};
        NSString *jsStr = [NSString stringWithFormat:@"javascript: ZhuanQuanJSBridge._invokeJS(\"%@\",%@);",clientId,[Helper covertStringWithJson:dict]];
        [[ZQWebVCSingleton shareInstance].webVC.webView stringByEvaluatingJavaScriptFromString:jsStr];
    }
}


-(void)releaseWithClientId:(NSString*)clientId;
{
    _prePlayerId = nil;
    [_player cancelPendingPrerolls];
    [_player replaceCurrentItemWithPlayerItem:nil];
    _player = nil;
    
    if(!IsEmptyStr(clientId)&&[ZQWebVCSingleton shareInstance].webVC.webView!=nil){
        NSDictionary *dict = @{@"id":_prePlayerId};
        NSString *jsStr = [NSString stringWithFormat:@"javascript: ZhuanQuanJSBridge._invokeJS(\"%@\",%@);",clientId,[Helper covertStringWithJson:dict]];
        [[ZQWebVCSingleton shareInstance].webVC.webView stringByEvaluatingJavaScriptFromString:jsStr];
    }
}


-(void)seekValue:(NSDictionary*)value ClientId:(NSString*)clientId;
{
    long time = [value[@"time"] longValue];
    CMTime cmtime = _player.currentTime;
    cmtime.value = time;
    
    [_player seekToTime:cmtime completionHandler:^(BOOL finished) {
        if(!IsEmptyStr(clientId)&&[ZQWebVCSingleton shareInstance].webVC.webView!=nil){
            NSDictionary *dict = @{@"id":_prePlayerId};
            NSString *jsStr = [NSString stringWithFormat:@"javascript: ZhuanQuanJSBridge._invokeJS(\"%@\",%@);",clientId,[Helper covertStringWithJson:dict]];
            [[ZQWebVCSingleton shareInstance].webVC.webView stringByEvaluatingJavaScriptFromString:jsStr];
        }
    }];
}




-(void)setupPlayer:(NSString *)proxyURLString
{
    AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:proxyURLString]];
    
    if(!_player && _player.currentItem==nil){
        
        _player = [[AVPlayer alloc]initWithPlayerItem:songItem];
        
    }else{
        
        [self playNextBeforOperate]; //切换下一首之前 释放掉通知及监听
        [_player replaceCurrentItemWithPlayerItem:songItem];
    }
    
    //添加播放器状态监听
    [songItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [songItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:songItem];
    
    //添加播放进度监听
    __weak MediaManager *weakSelf = self;
    id timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float duration = CMTimeGetSeconds(songItem.duration);
        if (current) {
            float percent = current / duration;
            if(!IsEmptyStr(weakSelf.prePlayerId)&&[ZQWebVCSingleton shareInstance].webVC.webView!=nil){
                NSDictionary *dict = @{@"id":weakSelf.prePlayerId,@"currentTime":@(current),@"duration":@(duration),@"percent":@(percent)};
                NSLog(@"播放长度：%.2f, 总长度：%.2f, 百分比：%.2f",current,duration,percent);
                
                NSString *jsonStr = [Helper covertStringWithJson:dict];
                NSString *jsStr = [NSString stringWithFormat:@"ZhuanQuanJSBridge.emit('mediaTimeupdate',%@);",jsonStr];
                [[ZQWebVCSingleton shareInstance].webVC.webView stringByEvaluatingJavaScriptFromString:jsStr];
            }
            
        }
    }];
    _timeObserve = timeObserve;
}


//改播放器状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"KVO：未知状态，此时不能播放");
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"KVO：准备完毕，可以播放");
                float duration = CMTimeGetSeconds(_player.currentItem.duration);
                NSDictionary *dict = @{@"id":_prePlayerId,@"duration":@(duration)};
                NSString *jsonStr = [Helper covertStringWithJson:dict];
                NSString *jsStr = [NSString stringWithFormat:@"ZhuanQuanJSBridge.emit('mediaPrepared',%@);",jsonStr];
                [[ZQWebVCSingleton shareInstance].webVC.webView stringByEvaluatingJavaScriptFromString:jsStr];
                [self configNowPlayingCenter];
            }
                break;
            case AVPlayerStatusFailed:
            {
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
            }
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        AVPlayerItem * songItem = object;
        NSArray * array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        float duration = CMTimeGetSeconds(songItem.duration);
        float percent = totalBuffer / duration;
        NSLog(@"缓冲长度：%.2f, 总长度：%.2f, 百分比：%.2f",totalBuffer,duration,percent);
        NSDictionary *dict = @{@"id":_prePlayerId,@"position":@(totalBuffer),@"duration":@(duration),@"percent":@(percent)};
        NSString *jsonStr = [Helper covertStringWithJson:dict];
        NSString *jsStr = [NSString stringWithFormat:@"ZhuanQuanJSBridge.emit('mediaPrepared',%@);",jsonStr];
        [[ZQWebVCSingleton shareInstance].webVC.webView stringByEvaluatingJavaScriptFromString:jsStr];
    }
}


//播放完成
- (void)playbackFinished:(NSNotification *)notice {
    NSLog(@"播放完成");

    CMTime cmtime = _player.currentTime;
    cmtime.value = 0;
    [_player seekToTime:cmtime];
    
    NSDictionary *dict = @{@"id":_prePlayerId};
    NSString *jsonStr = [Helper covertStringWithJson:dict];
    NSString *jsStr = [NSString stringWithFormat:@"ZhuanQuanJSBridge.emit('mediaEnd',%@);",jsonStr];
    [[ZQWebVCSingleton shareInstance].webVC.webView stringByEvaluatingJavaScriptFromString:jsStr];
}



//播放下一首前，移除这个item的观察者等
-(void)playNextBeforOperate
{
    if(_player){
        
        [_player.currentItem removeObserver:self forKeyPath:@"status"];
        
        [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        
        if (_timeObserve) {
            [_player removeTimeObserver:_timeObserve];
            _timeObserve = nil;
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


- (void)configNowPlayingCenter {
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    //音乐的标题
    [info setObject:@"转圈" forKey:MPMediaItemPropertyTitle];
    //音乐的艺术家
    [info setObject:@"未知" forKey:MPMediaItemPropertyArtist];
    //音乐的播放时间
    [info setObject:@(CMTimeGetSeconds(_player.currentTime)) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    //音乐的总时间
    [info setObject:@(CMTimeGetSeconds(_player.currentItem.duration)) forKey:MPMediaItemPropertyPlaybackDuration];
    //音乐的播放速度
    [info setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    //音乐的封面
    MPMediaItemArtwork * artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"AppIcon"]];
    [info setObject:artwork forKey:MPMediaItemPropertyArtwork];
    //设置锁屏状态下屏幕显示音乐信息
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}

                                        
@end