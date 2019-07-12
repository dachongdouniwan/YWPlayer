//
//  GZPlayerLayerView.m
//  GZEduProject
//
//  Created by GZDongbing on 2019/7/9.
//  Copyright © 2019 dyw. All rights reserved.
//

#import "GZPlayerLayerView.h"
#import "YWAVPlayer.h"
#import "GZPlayerControlToolBar.h"
#import "Masonry.h"
#import "YYKit.h"


#define ScaleH [UIScreen mainScreen].bounds.size.width/414.0


@interface GZPlayerLayerView ()

@property (nonatomic,strong) UIButton *pauseButton;

@property (nonatomic,strong) UIButton *resetPlayButton;

@end

@implementation GZPlayerLayerView

- (instancetype)initWithFrame:(CGRect)frame playerUrl:(NSString*)url
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self _setSubviewsWithUrl:url];
        [self _addGestureEvent];
    }
    return self;
}


-(void)_setSubviewsWithUrl:(NSString*)url{
    YWAVPlayer *player = [YWAVPlayer shareInstanceWithUrl:url autoPlay:YES];
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//视频填充模式
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.layer addSublayer:playerLayer];
    self.playerLayer = playerLayer;
    self.player = player;
    
    
    GZPlayerControlToolBar *controlToolBar = [[GZPlayerControlToolBar alloc] initWithFrame:CGRectZero];
    controlToolBar.backgroundColor = [UIColor redColor];
    controlToolBar.alpha = 0.0;
    controlToolBar.hidden = YES;
    [self addSubview:controlToolBar];
    self.controlToolBar = controlToolBar;
    
    
    UIButton *pauseButton = [[UIButton alloc] init];
    pauseButton.hidden = YES;
    [pauseButton addTarget:self action:@selector(pauseClick:) forControlEvents:UIControlEventTouchUpInside];
    [pauseButton setImage:[YYImage imageNamed:@"makecenter_pause"] forState:UIControlStateNormal];
    pauseButton.layer.shadowOpacity = 1.0;
    pauseButton.layer.shadowOffset = CGSizeMake(-3, 0);
    pauseButton.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    [self addSubview:pauseButton];
    self.pauseButton = pauseButton;
    
    [controlToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(80*ScaleH);
    }];
    
    [pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    
    UIButton *resetPlayButton = [[UIButton alloc] init];
    [resetPlayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resetPlayButton setTitle:@"重播" forState:UIControlStateNormal];
    [resetPlayButton addTarget:self action:@selector(resetClick:) forControlEvents:UIControlEventTouchUpInside];
    resetPlayButton.titleLabel.font = [UIFont systemFontOfSize:16];
    resetPlayButton.hidden = YES;
    [self addSubview:resetPlayButton];
    self.resetPlayButton = resetPlayButton;
    
    [resetPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    
    @weakify(self);
    self.playerComplatePlay = ^{
        @strongify(self);
        self.resetPlayButton.hidden = NO;
    };
    
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}


-(void)_addGestureEvent{
    @weakify(self);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self);
        [self _showControlBarTool];
        !self.tapBlock?nil:self.tapBlock();
    }];
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self);
        [[YWAVPlayer shareInstance] pause];
        self.pauseButton.hidden = NO;
    }];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [tap requireGestureRecognizerToFail:doubleTap];
}


-(void)pauseClick:(UIButton*)button{
    self.pauseButton.hidden = YES;
    [[YWAVPlayer shareInstance] play];
}


-(void)resetClick:(UIButton*)button{
    self.resetPlayButton.hidden = YES;
    !self.resetPlayBlock?nil:self.resetPlayBlock();
}


-(void)_showControlBarTool{
    
    if (self.controlToolBar.alpha>0.1) {
        [UIView animateWithDuration:0.25 animations:^{
            self.controlToolBar.alpha = 0.0;
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.controlToolBar.alpha = 1;
        }];
    }
    

}

@end
