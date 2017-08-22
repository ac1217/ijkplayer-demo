//
//  ViewController.m
//  KSPlayer
//
//  Created by iMac on 2017/8/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "ViewController.h"
#import <IJKMediaFramework/IJKMediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "KSPlayer.h"

@interface ViewController ()

@property (nonatomic,strong) KSPlayer *player;

@end

@implementation ViewController

- (KSPlayer *)player
{
    if (!_player) {
        _player = [KSPlayer new];
        _player.loopCount = NSIntegerMax;
    }
    return _player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.player.playerView];
    
    self.player.playerView.frame = self.view.bounds;
    
    NSString *URLString = @"http://fs.mcoolshot.kugou.com/201708221549/30818fb6c979358e61af76c08ca3bf68/G107/M0B/10/17/C4cBAFma1UuAODHRACT_b2ljILU599.mp4";
    
    self.player.URL = [NSURL URLWithString:URLString];
    
    self.player.playProgressBlock = ^(KSPlayer *player, float time, float duration, float progress) {
        
    };
    
    /*
    AVPlayer *avplayer = [AVPlayer playerWithURL:[NSURL URLWithString:URLString]];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:avplayer];
    layer.backgroundColor = [UIColor orangeColor].CGColor;
    layer.frame = CGRectMake(0, 300, self.view.bounds.size.width, 250);
    
    [self.view.layer addSublayer:layer];*/
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
        
    NSString *URLString = @"http://fs.mcoolshot.kugou.com/201708221549/30818fb6c979358e61af76c08ca3bf68/G107/M0B/10/17/C4cBAFma1UuAODHRACT_b2ljILU599.mp4";
    
    self.player.URL = [NSURL URLWithString:URLString];
    
}


@end
