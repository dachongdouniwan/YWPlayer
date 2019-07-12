//
//  GZPlayerView.m
//  GZEduProject
//
//  Created by GZDongbing on 2019/2/18.
//  Copyright © 2019年 dyw. All rights reserved.
//

#import "GZPlayerView.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "YYKit.h"
#import <MediaPlayer/MPVolumeView.h>
#import "CommonTool.h"
#import "GZPlayerControlToolBar.h"
#import "GZPlayerLayerView.h"
#import "MBProgressHUD+YWHud.h"

#define ScaleH [UIScreen mainScreen].bounds.size.width/414.0
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height


@interface GZPlayerView ()

@property (nonatomic,strong) MPVolumeView *volumeView;

@property (nonatomic,copy) NSString *playerUrl;

@property (nonatomic,strong) UIButton *scaleButton;

@property (nonatomic,assign) CGRect originFrame;

@property (nonatomic,strong) GZPlayerLayerView *playerView;

@property (nonatomic,strong) GZPlayerControlToolBar *controlBar;

@end

@implementation GZPlayerView


- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSString*)url
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.originFrame = frame;
        self.playerUrl = url;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        [self p_setSubviews];
        
        if (self.playerView.player) {
            [MBProgressHUD showHUDAddedTo:self.playerView animated:YES];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self closeClick];
                [MBProgressHUD mb_showAlphaToView:nil title:@"无效的播放链接"];
            });
        }
    }
    return self;
}


-(void)p_setSubviews{
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"";
    [nameLabel sizeToFit];
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UIButton *cancleButton = [[UIButton alloc] init];
    [cancleButton setImage:[YYImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancleButton];
    self.cancleButton = cancleButton;
    
    GZPlayerLayerView *playerView = [[GZPlayerLayerView alloc] initWithFrame:CGRectZero playerUrl:self.playerUrl];
    [self addSubview:playerView];
    self.playerView = playerView;
    
    UIButton *scaleButton = [[UIButton alloc] initWithFrame:CGRectZero];
    scaleButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [scaleButton setBackgroundImage:[UIImage imageNamed:@"gz_player_big"] forState:UIControlStateNormal];
    [scaleButton setBackgroundImage:[UIImage imageNamed:@"gz_player_small"] forState:UIControlStateSelected];
    [scaleButton addTarget:self action:@selector(scaleClick:) forControlEvents:UIControlEventTouchUpInside];
    scaleButton.layer.shadowOpacity = 1.0;
    scaleButton.layer.shadowOffset = CGSizeMake(-3, 0);
    scaleButton.layer.shadowColor = [UIColor blackColor].CGColor;
    [self.playerView addSubview:scaleButton];
    self.scaleButton = scaleButton;
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).with.offset(15*ScaleH);
    }];
    
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-12*ScaleH);
        make.centerY.equalTo(nameLabel);
        make.size.mas_equalTo(CGSizeMake(32*ScaleH, 32*ScaleH));
    }];
    
    
    GZPlayerControlToolBar *controlBar = [[GZPlayerControlToolBar alloc] init];
    [self addSubview:controlBar];
    self.controlBar = controlBar;
    
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(7*ScaleH);
        make.top.equalTo(self).offset(50*ScaleH);
        make.bottom.equalTo(controlBar.mas_top);
        make.right.equalTo(self).offset(-7*ScaleH);
    }];
    
    [controlBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(80*ScaleH);
    }];
    
    [scaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.playerView).offset(-10*ScaleH);
        make.bottom.equalTo(controlBar.mas_top).offset(-10*ScaleH);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self _setPlayerCallBack];
    
}



-(void)_setPlayerCallBack{
    @weakify(self);
    self.controlBar.playProgressBlock = ^(float currentTime) {
        @strongify(self);
        [MBProgressHUD hideHUDForView:self.playerView animated:YES];
        NSString *currentTimeString = [CommonTool switchSecondsToMinute:currentTime];
        !self.playProgressBlock?nil:self.playProgressBlock(currentTime, currentTimeString);
    };
    
    self.controlBar.playComplateBlock = ^(YWAVPlayerComplate type) {
        @strongify(self);
        [MBProgressHUD hideHUDForView:self.playerView animated:YES];
        self.playerView.playerComplatePlay();
        !self.playComplateBlock?:self.playComplateBlock(type);
    };
    
    self.playerView.tapBlock = ^{
        @strongify(self);
        if (!self.controlBar.voiceView.hidden) {
            self.controlBar.voiceView.hidden = YES;
        }
    };
    
    self.playerView.resetPlayBlock = ^{
        @strongify(self);
        [YWAVPlayer shareInstanceWithUrl:self.playerUrl autoPlay:YES];
        [self.controlBar resetPlayer];
    };
    
}


-(void)scaleClick:(UIButton*)button{
    if (!button.selected) {
        self.frame = CGRectMake(0, 0, ScreenW, ScreenH);
    }else{
        self.frame = self.originFrame;
    }
    
    [self.controlBar updateSliderValue];
    button.selected = !button.selected;
}


-(void)closeClick{
    [[YWAVPlayer shareInstance] canclePlayer];
    while ([self.superview respondsToSelector:@selector(updateContentView)]) {
        [self.superview performSelector:@selector(updateContentView) withObject:nil];
    }
    !self.closePlayerBlock?nil:self.closePlayerBlock();
}

@end


@implementation GZSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self p_setSubviews];
    }
    return self;
}


-(void)p_setSubviews{
    
    UIView * progressView = [[UIView alloc] init];
    progressView.backgroundColor = [UIColor colorWithHexString:@"#FFC500"];
    progressView.userInteractionEnabled = NO;
    [self addSubview:progressView];
    self.progressView = progressView;
    
    UIView * cacheProgressView = [[UIView alloc] init];
    cacheProgressView.userInteractionEnabled = NO;
    cacheProgressView.alpha = 0.6;
    cacheProgressView.backgroundColor = [UIColor colorWithHexString:@"#434343"];
    [self addSubview:cacheProgressView];
    self.cacheProgressView = cacheProgressView;
    
    UIImageView *flgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-8,-10, 30, 30)];
    flgImageView.image = [YYImage imageNamed:@"player_oval"];
    
    [self addSubview:flgImageView];
    self.flgImageView = flgImageView;
}


-(void)setCacheProgress:(CGFloat)cacheProgress{
    _cacheProgress = cacheProgress;
    if (cacheProgress>1||cacheProgress<0) {
        return;
    }
    CGFloat width = self.width*cacheProgress;
    self.cacheProgressView.frame = CGRectMake(0, 0, width, self.height);
    [self sendSubviewToBack:self.cacheProgressView];
}


-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    if (progress>1) {
        progress = 1;
    }else if (progress<0){
        progress = 0;
    }
    CGFloat width = (self.width-10)*progress;
    self.progressView.frame = CGRectMake(0, 0, width, self.height);
    self.flgImageView.frame = CGRectMake(width-8, -10, 30, 30);
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat value = point.x/(self.bounds.size.width-10);
    [self bringSubviewToFront:self.progressView];
    [self bringSubviewToFront:self.flgImageView];
    if (value>1||value<0) {
        return;
    }
    self.progress = value;
    !self.progressblock?nil:self.progressblock(value);
    NSLog(@"%f",value);
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat value = point.x/(self.bounds.size.width-10);
    if (value>1||value<0) {
        return;
    }
    self.progress = value;
    !self.progressblock?nil:self.progressblock(value);
    //    NSLog(@"%f",value);
}


- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event{
    //    NSLog(@"%f",point.y);
    if ((point.y>-15&&point.y<0)||(point.y<15&&point.y>0)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}


-(void)layoutSubviews{
    [super layoutSubviews];
}



@end


@implementation GZVoiceSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_setSubviews];
    }
    return self;
}


-(void)p_setSubviews{
    
    UIView *sliderNormaleView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, 5, self.height-10)];
    sliderNormaleView.backgroundColor = [UIColor colorWithHexString:@"#62CBFF"];
    sliderNormaleView.layer.cornerRadius = 2.5;
    [self addSubview:sliderNormaleView];
    
    UIView *sliderSelectlView = [[UIView alloc] init];
    sliderSelectlView.backgroundColor = [UIColor colorWithHexString:@"#5FFD52"];
    [self addSubview:sliderSelectlView];
    self.sliderSelectlView = sliderSelectlView;
    
    UIImageView *flagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.height-20, 15, 15)];
    flagImageView.layer.cornerRadius = 7.5;
    flagImageView.backgroundColor = [UIColor whiteColor];
    [self addSubview:flagImageView];
    self.flagImageView = flagImageView;
}



-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    if (progress>1||progress<0) {
        return;
    }
    
    CGFloat height= self.height-10;
    
    CGFloat y = height*progress;
    
    self.sliderSelectlView.frame = CGRectMake(10, y,5,self.height-height*progress-5);
    self.flagImageView.frame = CGRectMake(5, y>95?95:y, 15, 15);
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.y<5||point.y>self.height-5) {
        return;
    }
    CGFloat value = point.y/(self.bounds.size.height-10);
    [self bringSubviewToFront:self.sliderSelectlView];
    [self bringSubviewToFront:self.flagImageView];
    self.progress = value;
    !self.progressblock?nil:self.progressblock(value);
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (point.y<5||point.y>self.height-5) {
        return;
    }
    CGFloat value = point.y/(self.bounds.size.height-10);
    self.progress = value;
    !self.progressblock?nil:self.progressblock(value);
}

//-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    CGFloat value = point.x/self.bounds.size.width;
//    //    self.value = value;
//    //    self.uploadSliderValue?self.uploadSliderValue(self): nil;
//}



@end








