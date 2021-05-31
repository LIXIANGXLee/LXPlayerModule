//
//  LXAVPlayerView.h
//  LXPlayerModule
//
//  Created by Mac on 2020/5/9.
//  Copyright © 2020 李响. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LXAVPlayerViewState) {
    LXAVPlayerViewStateUnknown   = 0,///未知(比如都没有开始播放音乐)
    LXAVPlayerViewStateLoading   = 1,///正在加载()
    LXAVPlayerViewStatePlaying   = 2,///正在播放
    LXAVPlayerViewStateStopped   = 3,///停止
    LXAVPlayerViewStatePause     = 4,/// 暂停
    LXAVPlayerViewStateFailed    = 5,///失败(比如没有网络缓存失败, 地址找不到)
    LXAVPlayerViewStateComplete /// 播放完成
};

///状态block回调
typedef void(^CallBackState)(LXAVPlayerViewState state);

//MARK: - 播放器
@interface LXAVPlayerView : UIView

/** 是否静音 */
@property (nonatomic, assign) BOOL muted;
/** 音量大小 */
@property (nonatomic, assign) float volume;
/** 当前播放速率 */
@property (nonatomic, assign) float rate;
/** 状态回调 */
@property (nonatomic, copy) CallBackState callBackState;

/** 播放状态 */
@property (nonatomic, assign, readonly) LXAVPlayerViewState state;
/** 总时长 */
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
/** 已经播放时长 */
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
/** 播放进度 */
@property (nonatomic, assign, readonly) float progress;
/** 当前播放的url地址 */
@property (nonatomic, strong, readonly) NSURL *url;
/** 加载进度 */
@property (nonatomic, assign, readonly) float loadDataProgress;

/**
 根据一个url地址, 播放音视频资源
 
 @param url url地址
 @param isCache 是否需要缓存
 */
- (void)playWithURL:(NSURL *)url isCache:(BOOL)isCache;

/**
 暂停当前播放的音频资源
 */
- (void)pause;

/**
 继续播放音频资源
 */
- (void)resume;

/**
 停止播放音频资源
 */
- (void)stop;

/**
 * 快进/快退
 * @param timeDiffer 跳跃的时间段
 */
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer completionHandler:(void(^)(BOOL isFinish))completionHandler;
/**
 * 播放指定的进度
 * @param progress 进度信息
 */
- (void)seekWithProgress:(float)progress completionHandler:(void(^)(BOOL isFinish))completionHandler;

@end

NS_ASSUME_NONNULL_END
