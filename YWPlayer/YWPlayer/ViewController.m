//
//  ViewController.m
//  YWPlayer
//
//  Created by GZDongbing on 2019/5/28.
//  Copyright © 2019 dyw. All rights reserved.
//

#import "ViewController.h"
#import "GZPlayerView.h"
#import "Masonry.h"
#import "YWPlayer/YWMusicPlayer.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    NSLog(@"ssss");


    
}


-(void)test{
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString *url = [[NSBundle mainBundle] pathForResource:@"朴翔 - 把悲伤留给自己 (Live)" ofType:@"mp3"];
    
    GZPlayerView *playerView = [[GZPlayerView alloc] initWithFrame:CGRectZero withUrl:url];
    [self.view addSubview:playerView];
    
    [playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(400);
    }];
    
    UIButton *musicButton = [[UIButton alloc] init];
    [musicButton setTitle:@"测试" forState:UIControlStateNormal];
    musicButton.backgroundColor = [UIColor redColor];
    [musicButton addTarget:self action:@selector(musicClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:musicButton];
    
    [musicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(playerView.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
}


-(void)musicClick:(UIButton*)button{
    NSString *url = [[NSBundle mainBundle] pathForResource:@"徐歌阳 - 一万次悲伤 (Live)" ofType:@"mp3"];
    [YWMusicPlayer shareInstanceWithUrl:url autoPlay:YES];
    NSLog(@"---====");
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
}

@end
