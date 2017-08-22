//
//  KSPlayer.m
//  KSPlayer
//
//  Created by iMac on 2017/8/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KSPlayer.h"

#import <IJKMediaFramework/IJKMediaPlayer.h>

@interface KSPlayer (){
    
    UIView *_playerView;
    
    NSInteger _currentLoopCount;
    
    
}
@property (nonatomic,strong) IJKFFMoviePlayerController *player;


@property (nonatomic,strong) dispatch_source_t playProgressTimer;


@end

@implementation KSPlayer

+ (void)initialize
{
    
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    
}

- (void)dealloc
{
    [self freePlayer];
}

- (void)freePlayer
{
    
    [self removePlayProgressTimer];
    [self removePlayerObserver];
    [self.player shutdown];
    self.playerView.playerLayer = nil;
    self.player = nil;
}

- (void)createPlayer
{
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setPlayerOptionIntValue:5 forKey:@"framedrop"];
//    [options setPlayerOptionIntValue:1 forKey:@"videotoolbox"];
    //解码参数，画面更清晰
    [options setCodecOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter"];
    
    
    IJKFFMoviePlayerController *player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.URL withOptions:options];
    player.shouldAutoplay = self.autoPlay;
    player.scalingMode = IJKMPMovieScalingModeAspectFit;
    [player prepareToPlay];
    self.playerView.playerLayer = player.view;
    self.player = player;
    [self addPlayerObserver];
    [self addPlayProgressTimer];
}

- (UIView *)playerView
{
    if (!_playerView) {
        _playerView = [KSPlayerView new];
    }
    return _playerView;
}

- (instancetype)init
{
    if (self = [super init]) {
        _autoPlay = YES;
        _loopCount = 1;
    }
    return self;
}

- (void)setURL:(NSURL *)URL
{
    _URL = URL;
    
    [self freePlayer];
    
    if (URL) {
        
        [self createPlayer];
    }
    
}

- (void)seekToTime:(NSTimeInterval)time
{
    
    
    
    self.player.currentPlaybackTime = time;
    
    
}

- (void)removePlayProgressTimer
{
    
    if (self.playProgressTimer) {
        
        dispatch_source_cancel(self.playProgressTimer);
        self.playProgressTimer = nil;
    }
}

- (void)addPlayProgressTimer
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    
    //间隔时间
    uint64_t interval = 0.5 * NSEC_PER_SEC;
    
    dispatch_source_set_timer(timer, start, interval, 0);
    dispatch_source_set_event_handler(timer, ^{
        
        CGFloat progress = weakSelf.player.currentPlaybackTime / weakSelf.player.duration;
        
        !weakSelf.playProgressBlock ? : weakSelf.playProgressBlock(weakSelf, weakSelf.player.currentPlaybackTime, weakSelf.player.duration, progress);
        
        
    });
    dispatch_resume(timer);
    self.playProgressTimer = timer;
}

#pragma mark -KVO
- (void)addPlayerObserver
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerPlaybackDidFinishNotification:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerPlaybackStateDidChangeNotification:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.player];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerLoadStateDidChangeNotification:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:self.player];
}

- (void)removePlayerObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.player];
    
    
}


- (void)playerLoadStateDidChangeNotification:(NSNotification*)notification
{
    IJKMPMovieLoadState loadState = self.player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        
        !self.loadStatusBlock ? : self.loadStatusBlock(self, KSPlayerLoadStatusPlaythroughOK);
        
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        
        !self.loadStatusBlock ? : self.loadStatusBlock(self, KSPlayerLoadStatusStalled);
        
    } else {
        
    }

}

- (void)playerPlaybackStateDidChangeNotification:(NSNotification*)notification
{
    switch (self.player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            
            !self.playStatusBlock ? : self.playStatusBlock(self, KSPlayerPlayStatusStoped);
            
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            !self.playStatusBlock ? : self.playStatusBlock(self, KSPlayerPlayStatusPlaying);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            !self.playStatusBlock ? : self.playStatusBlock(self, KSPlayerPlayStatusPaused);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            
            break;
        }
        default: {
            !self.playStatusBlock ? : self.playStatusBlock(self, KSPlayerPlayStatusUnknow);
            
            break;
        }
    }
}

- (void)playerPlaybackDidFinishNotification:(NSNotification*)notification
{
    
    _currentLoopCount++;
    
    if (_currentLoopCount >= self.loopCount) {
        
        _currentLoopCount = 0;
        
        [self.player stop];
        
    }else {
        
        [self.player play];
        
    }
    
}

@end
