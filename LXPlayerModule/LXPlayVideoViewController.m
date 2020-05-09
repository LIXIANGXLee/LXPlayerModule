//
//  LXPlayVideoViewController.m
//  LXProjectDemo
//
//  Created by LIXIANG on 2019/7/4.
//  Copyright © 2019 LIXIANG. All rights reserved.
//

#import "LXPlayVideoViewController.h"

#import <LXAVPlayerView.h>
#define VideoURL @"https://img.coffeesss.com/image/6836e0f6e55bd80314c1ab70e5d9f132.mp4"
@interface LXPlayVideoViewController ()
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIProgressView *progrss;
@property (weak, nonatomic) IBOutlet UILabel *start;
@property (weak, nonatomic) IBOutlet UILabel *end;
@property (strong, nonatomic)LXAVPlayerView * p;
@end

@implementation LXPlayVideoViewController
- (IBAction)sliderClick:(UISlider *)sender {
    
    [_p seekWithProgress:sender.value];
}
- (IBAction)pause:(id)sender {
    [_p pause];
}
- (IBAction)play:(id)sender {
    [_p playWithURL:[NSURL URLWithString:VideoURL] isCache:YES];

}
- (IBAction)resume:(id)sender {
    [_p resume];
}
- (IBAction)mute:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    
    [_p setMuted:sender.selected];
}
- (IBAction)NoMute:(id)sender {
    
     [_p setMuted:NO];
}
    
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.navigationItem.title = @"视频播放";
    
    _p = [[LXAVPlayerView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 400)];
    
    [_p playWithURL:[NSURL URLWithString:VideoURL] isCache:YES];

    [self.view addSubview:_p];
    __weak __typeof(self)weakSelf = self;

    _p.callBackState = ^(LXAVPlayerViewState state) {
        NSLog(@"======%ld",(long)state);
        if (state == LXAVPlayerViewStateComplete) {
            
            [_p playWithURL:[NSURL URLWithString:VideoURL] isCache:YES];

        }
    };
  
    [NSTimer scheduledTimerWithTimeInterval:0.001 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
           weakSelf.start.text = [weakSelf getTimeFormatted:(int)weakSelf.p.currentTime];
            weakSelf.end.text = [weakSelf getTimeFormatted:(int)weakSelf.p.totalTime];

           weakSelf.progrss.progress = weakSelf.p.progress;
           weakSelf.slider.value = weakSelf.p.progress;
       });

    }];
    
}

    //获取时间格式
- (NSString *)getTimeFormatted:(int)totalSeconds{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%2d:%02d:%02d",hours, minutes, seconds];
    }else{
        return [NSString stringWithFormat:@"%2d:%02d", minutes, seconds];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
