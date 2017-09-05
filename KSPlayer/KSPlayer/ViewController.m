//
//  ViewController.m
//  KSPlayer
//
//  Created by iMac on 2017/8/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "ViewController.h"
#import <IJKMediaFramework/IJKMediaPlayer.h>
#import "KSPlayer.h"

@interface ViewController ()

@property (nonatomic,strong) KSPlayer *player;
    
    @property (nonatomic,assign) NSInteger index;

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
    
    NSString *URLString = @"http://fs.mcoolshot.kugou.com/201708231750/a6005e3475a70f161e3a52325d278fa2/G113/M0B/02/17/UZQEAFmanEqAS77DADkAZjAZDF4208.mp4";
    
    NSURL *url = [NSURL URLWithString:URLString];
    self.player.URL = url;
    [self.view addSubview:self.player.playerView];
    
    self.player.playerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 250);
    
    /*
    AVPlayer *avplayer = [AVPlayer playerWithURL:[NSURL URLWithString:URLString]];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:avplayer];
    layer.backgroundColor = [UIColor orangeColor].CGColor;
    layer.frame = CGRectMake(0, 300, self.view.bounds.size.width, 250);
    
    [self.view.layer addSublayer:layer];*/
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    NSString *URLString = @"";
    if (_index == 0) {
        URLString = @"http://fs.mcoolshot.kugou.com/201708231750/e520eca7ab9d63388eeaa280b9809914/G111/M05/0A/07/rw0DAFmazJWAOIhhACU00DovI-s069.mp4";
        _index = 1;
    }else {
        
        URLString = @"http://fs.mcoolshot.kugou.com/201708231750/a6005e3475a70f161e3a52325d278fa2/G113/M0B/02/17/UZQEAFmanEqAS77DADkAZjAZDF4208.mp4";
        _index = 0;
    }
    
    self.player.URL = [NSURL URLWithString:URLString];
    
}


@end
