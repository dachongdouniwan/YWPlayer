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
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *url = [[NSBundle mainBundle] pathForResource:@"朴翔 - 把悲伤留给自己 (Live)" ofType:@"mp3"];
    
    GZPlayerView *playerView = [[GZPlayerView alloc] initWithFrame:CGRectZero withUrl:url];
    [self.view addSubview:playerView];
    
    [playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    
}


@end
