//
//  LXAVPlayerView.m
//  LXPlayerModule
//
//  Created by Mac on 2020/5/9.
//  Copyright © 2020 李响. All rights reserved.
//

#import "LXAVPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "LXResourceLoaderDelegate.h"
#import "NSURL+LXHttpStream.h"

@interface LXAVPlayerView()
{
    // 标识用户是否进行了手动暂停
    BOOL _isUserPause;
}

/**
 音视频播放器
 */
@property(nonatomic, strong)AVPlayer *player;
@property(nonatomic, strong)AVPlayerLayer * playerLayer;

/**
 资源加载代理
 */
@property (nonatomic, strong)LXResourceLoaderDelegate *resourceLoaderDelegate;

@end

@implementation LXAVPlayerView

+(void)initialize{
    NSError *categoryError = nil;
    NSError *error;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&categoryError];
    NSError *activeError = nil;
    success = [[AVAudioSession sharedInstance] setActive:YES error:&activeError];
}

#pragma mark - 懒加载
-(LXResourceLoaderDelegate *)resourceLoaderDelegate{
    if (!_resourceLoaderDelegate) {
        _resourceLoaderDelegate = [[LXResourceLoaderDelegate alloc]init];
    }
    return _resourceLoaderDelegate;
}

#pragma mark - public
/**
  根据一个url地址, 播放音视频资源

  @param url url地址
  @param isCache 是否需要缓存
*/
- (void)playWithURL:(NSURL *)url isCache:(BOOL)isCache{
    
    NSURL *currentURL = [(AVURLAsset *)self.player.currentItem.asset URL];
    if ([url isEqual:currentURL] || [[url streamingURL] isEqual:currentURL]) {
        //当前播放任务已经存在
        [self resume];
        return;
    }
    
    //移除原来的播放
    if (self.player.currentItem) {
        [self removeObserver];
    }
    _url = url;
    if (isCache) {
        url = [url streamingURL];
    }
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    // 关于网络音视频的请求, 是通过这个对象, 调用代理的相关方法, 进行加载的
    // 拦截加载的请求, 只需要重新修改它的代理方法就可以
    [asset.resourceLoader setDelegate:self.resourceLoaderDelegate queue:dispatch_get_main_queue()];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    //添加状态监听
    [self addObserver:item];

    //创建播放器
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer =[AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;;
    [self.layer addSublayer:self.playerLayer];
    
}

///继续播放
- (void)resume {
    [self.player play];
    _isUserPause = NO;
    // 就是代表,当前播放器存在, 并且, 数据组织者里面的数据准备, 已经足够播放了
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        self.state = LXAVPlayerViewStatePlaying;
    }
}

///暂停播放
- (void)pause {
    [self.player pause];
    _isUserPause = YES;
    if (self.player) {
        self.state = LXAVPlayerViewStatePause;
    }
}

///停止播放
- (void)stop {
    if (self.player) {
        self.state = LXAVPlayerViewStateStopped;
        [self.player pause];
        self.player = nil;
    }
}

///指定进度播放 progress 进度
- (void)seekWithProgress:(float)progress {
    if (progress < 0 || progress > 1) {
        return;
    }

    // 当前音视频资源的总时长
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalSec = CMTimeGetSeconds(totalTime);
    NSTimeInterval playTimeSec = totalSec * progress;
    CMTime currentTime = CMTimeMake(playTimeSec, 1);
    
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            //确定加载这个时间点的音视频资源
        }else {
            //取消加载这个时间点的音视频资源
        }
    }];
}

///指定时间差播放 timeDiffer 时间差 快进
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer {
    NSTimeInterval totalTimeSec = [self totalTime];
    NSTimeInterval playTimeSec = [self currentTime];
    playTimeSec += timeDiffer;
    
    [self seekWithProgress:playTimeSec / totalTimeSec];
    
}

#pragma mark - pravite
///播放完成
- (void)playEnd {
    self.state = LXAVPlayerViewStateComplete;
    self.player = nil;
}

///被打断 播放
- (void)playInterupt {
    // 来电话, 资源加载跟不上
    self.state = LXAVPlayerViewStatePause;
}

///移除监听者, 通知
- (void)removeObserver {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

///添加监听者, 通知
- (void)addObserver:(AVPlayerItem *)item{
    // 当资源的组织者, 告诉我们资源准备好了之后, 我们再播放
    // AVPlayerItemStatus status
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            //资源准备好了, 这时候播放就没有问题
            [self resume];
        }else {
            //状态未知
            self.state = LXAVPlayerViewStateFailed;
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL ptk = [change[NSKeyValueChangeNewKey] boolValue];
        if (ptk) {
            //当前的资源, 准备的已经足够播放了
            // 用户的手动暂停的优先级最高
            if (!_isUserPause) {
                [self resume];
            }
        }else {
            //资源还不够, 正在加载过程当中
            self.state = LXAVPlayerViewStateLoading;
        }
    }
}

#pragma mark - 数据/事件
///播放速率rate 速率, 0.5 -- 2.0
- (void)setRate:(float)rate {
    [self.player setRate:rate];
}

///获取速率 速率
- (float)rate {
    return self.player.rate;
}

///设置静音 muted 静音
- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

///是否静音 是否静音
- (BOOL)muted {
    return self.player.muted;
}

///声音大小 volume 音量
- (void)setVolume:(float)volume {
    
    if (volume < 0 || volume > 1) {
        return;
    }
    if (volume > 0) {
        [self setMuted:NO];
    }
    
    self.player.volume = volume;
}

///声音大小 音量
- (float)volume {
    return self.player.volume;
}

///当前音视频资源总时长 总时长
-(NSTimeInterval)totalTime {
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalTimeSec = CMTimeGetSeconds(totalTime);
    if (isnan(totalTimeSec)) {
        return 0;
    }
    return totalTimeSec;
}

///当前音视频资源播放时长 播放时长
- (NSTimeInterval)currentTime {
    CMTime playTime = self.player.currentItem.currentTime;
    NSTimeInterval playTimeSec = CMTimeGetSeconds(playTime);
    if (isnan(playTimeSec)) {
        return 0;
    }
    return playTimeSec;
}

///当前播放进度 播放进度
- (float)progress {
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime / self.totalTime;
}

///资源加载进度 加载进度
- (float)loadDataProgress {
    
    if (self.totalTime == 0) {
        return 0;
    }
    
    CMTimeRange timeRange = [[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
    CMTime loadTime = CMTimeAdd(timeRange.start, timeRange.duration);
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadTime);
    return loadTimeSec / self.totalTime;
    
}

///监听状态改变
-(void)setState:(LXAVPlayerViewState)state{
    _state = state;
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.callBackState) {
          self.callBackState(state);
      }
    });
}

///销毁时调用
-(void)dealloc{
    [self removeObserver];
}

@end
