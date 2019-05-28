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
#import "MBProgressHUD.h"

#define ScaleH  1

@interface GZPlayerView ()

@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@property (nonatomic,weak) UIView *containerView;

@property (nonatomic,weak) GZSlider *slider;

@property (nonatomic,weak) UIView *voiceView;

@property (nonatomic,strong) MPVolumeView *volumeView;

@property (nonatomic,weak) UISlider *volumeSlider;

@property (nonatomic,copy) NSString *playerUrl;

@end

@implementation GZPlayerView


- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSString*)url
{
    self = [super initWithFrame:frame];
    if (self) {
        self.playerUrl = url;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        [self p_setSubviews];
        if (self.playerLayer.player) {
            [MBProgressHUD showHUDAddedTo:self animated:YES];
        }else{
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
    
    YWAVPlayer *player = [YWAVPlayer shareInstanceWithUrl:self.playerUrl autoPlay:YES];
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//视频填充模式
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.layer addSublayer:playerLayer];
    self.playerLayer = playerLayer;
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).with.offset(15*ScaleH);
    }];
    
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-12*ScaleH);
        make.centerY.equalTo(nameLabel);
        make.size.mas_equalTo(CGSizeMake(32*ScaleH, 32*ScaleH));
    }];
    
    
    GZSlider *slider = [[GZSlider alloc]init];
    [self addSubview:slider];
    self.slider = slider;
    
    @weakify(self);
    slider.progressblock = ^(CGFloat progress) {
        @strongify(self);
        [[YWAVPlayer shareInstance] pause];
        CGFloat currentSeconds = progress*self.totleTime;
        CMTime time = [YWAVPlayer shareInstance].currentItem.currentTime;
        time.value = currentSeconds* time.timescale;
        [[YWAVPlayer shareInstance] seekToTime:time completionHandler:^(BOOL finished) {
            if (finished) {
                [[YWAVPlayer shareInstance] play];
            }
        }];
    };
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = @"00:00/00:00";
    [timeLabel sizeToFit];
    [self addSubview:timeLabel];
    
    UIButton *startButton = [[UIButton alloc] init];
    startButton.tag = 101;
    [startButton addTarget:self action:@selector(buttonClcik:) forControlEvents:UIControlEventTouchUpInside];
    [startButton setImage:[YYImage imageNamed:@"gz_player_start"] forState:UIControlStateNormal];
    [startButton setImage:[YYImage imageNamed:@"gz_player_pause"] forState:UIControlStateSelected];
    startButton.selected = YES;
    [self addSubview:startButton];
    
    UIButton *voiceButton = [[UIButton alloc] init];
    voiceButton.tag = 102;
    [voiceButton setImage:[YYImage imageNamed:@"player_icon_voice"] forState:UIControlStateNormal];
    [voiceButton addTarget:self action:@selector(buttonClcik:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:voiceButton];
    
    UIButton *forwordButton = [[UIButton alloc] init];
    forwordButton.tag = 103;
    [forwordButton setImage:[YYImage imageNamed:@"player_forword"] forState:UIControlStateNormal];
    [forwordButton addTarget:self action:@selector(buttonClcik:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:forwordButton];
    
    UIButton *backButton = [[UIButton alloc] init];
    backButton.tag = 104;
    [backButton setImage:[YYImage imageNamed:@"player_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(buttonClcik:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    UIView *voiceView = [[UIView alloc] init];
    voiceView.backgroundColor = [UIColor colorWithHexString:@"#37C2FF"];
    voiceView.layer.cornerRadius = 5;
    voiceView.hidden = YES;
    [self addSubview:voiceView];
    self.voiceView = voiceView;
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(5*ScaleH);
        make.centerY.equalTo(startButton.mas_centerY);
    }];
    
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(slider.mas_bottom).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-30);
        make.centerY.equalTo(startButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(startButton.mas_centerY);
        make.right.equalTo(startButton.mas_left).with.offset(-30);
        make.size.mas_equalTo(CGSizeMake(30*ScaleH, 30*ScaleH));
    }];
    
    [forwordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(startButton.mas_centerY);
        make.left.equalTo(startButton.mas_right).with.offset(30*ScaleH);
        make.size.mas_equalTo(CGSizeMake(30*ScaleH, 30*ScaleH));
    }];
    
    [voiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(voiceButton.mas_top).with.offset(-10);
        make.size.mas_equalTo(CGSizeMake(25, 120));
        make.centerX.equalTo(voiceButton);
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    GZVoiceSlider *voiceSlider = [[GZVoiceSlider alloc] initWithFrame:voiceView.bounds];
    voiceSlider.progress = (1.0-[AVAudioSession sharedInstance].outputVolume);
    [voiceView addSubview:voiceSlider];
   
    voiceSlider.progressblock = ^(CGFloat progress) {
        @strongify(self);
        self.volumeSlider.value = (1-progress);
    };

    
    [YWAVPlayer shareInstance].playProgressBlock = ^(CMTime time) {
        @strongify(self);
        if (self.totleTime>0) {
            [MBProgressHUD hideHUDForView:self animated:YES];
            CGFloat currentTime = CMTimeGetSeconds(time);
            NSString *currentTimeString = [CommonTool switchSecondsToMinute:currentTime];
            self.currentTime = currentTime;
            self.currentTimeString = currentTimeString;
            self.slider.progress = currentTime/self.totleTime;
            timeLabel.attributedText = [CommonTool gz_stirngWith:currentTimeString two:[NSString stringWithFormat:@" / %@",[CommonTool switchSecondsToMinute:self.totleTime]] oneColor:[UIColor colorWithHexString:@"#FFC500"] twoColor:[UIColor blackColor] oneFont:[UIFont systemFontOfSize:13] twoFont:[UIFont systemFontOfSize:13]];
            !self.playProgressBlock?nil:self.playProgressBlock(currentTime,currentTimeString);
        }
    };
    
    [YWAVPlayer shareInstance].cacheTimeProgressBlock = ^(float totleTime, float cacheTime) {
        @strongify(self);
        NSString *totleTimeString = [CommonTool switchSecondsToMinute:totleTime];
        self.totleTimeString = totleTimeString;
        self.totleTime = totleTime;
        self.slider.cacheProgress = cacheTime/totleTime;
        if ([timeLabel.text isEqualToString:@"00:00/00:00"]) {
            timeLabel.text = [NSString stringWithFormat:@"00:00/%@",totleTimeString];
        }
    };
    
    [YWAVPlayer shareInstance].playComplateBlock = ^(YWAVPlayerComplate type) {
        @strongify(self);
        [MBProgressHUD hideHUDForView:self animated:YES];
        startButton.selected = NO;
        !self.playComplateBlock?:self.playComplateBlock(type);
    };
}


-(void)buttonClcik:(UIButton*)button{
    switch (button.tag) {
        case 101:
        {
            //开始暂停
            button.selected = !button.selected;
            if (button.selected) {
                [[YWAVPlayer shareInstance] play];
            }else{
                [[YWAVPlayer shareInstance] pause];
            }
        }
            break;
        case 102:
        {
            //声音
            self.voiceView.hidden = !self.voiceView.hidden;
        }
            break;
        case 103:
        {
            //向前
            [self forwadPlayer:YES];
        }
            break;
        case 104:
        {
            //向后
            [self forwadPlayer:NO];
        }
            break;
        default:
            break;
    }
}


-(void)closeClick{
    [[YWAVPlayer shareInstance] canclePlayer];
    while ([self.superview respondsToSelector:@selector(updateContentView)]) {
        [self.superview performSelector:@selector(updateContentView) withObject:nil];
    }
    !self.closePlayerBlock?nil:self.closePlayerBlock();
}


-(void)forwadPlayer:(BOOL)isForward{
    [[YWAVPlayer shareInstance] pause];
    CGFloat currentSeconds;
    if (isForward) {
        currentSeconds = [YWAVPlayer shareInstance].currentSecond+10;
    }else{
        currentSeconds = [YWAVPlayer shareInstance].currentSecond-10;
    }
    
    CMTime time = [YWAVPlayer shareInstance].currentItem.currentTime;
    time.value = currentSeconds* time.timescale;
    [[YWAVPlayer shareInstance] seekToTime:time completionHandler:^(BOOL finished) {
        if (finished) {
            [[YWAVPlayer shareInstance] play];
        }
    }];
}



/**
 音量的 view
 把系统的音量的 view 的 frame 设置到根本看不见的地方，这样就不会覆盖自定义的 提示 view
 */
- (MPVolumeView *)volumeView {
    
    if (_volumeView == nil) {
        // 如果要显示音量的 view  可在这里设置，默认只调整音量，没有显示View
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-[UIScreen mainScreen].bounds.size.width, -20, 10, 10)];
        _volumeView.hidden = NO;
        [self addSubview:_volumeView];
    }
    return _volumeView;
}

/**
 音量 slider
 
 @return slider
 */
- (UISlider *)volumeSlider {
    if (_volumeSlider== nil) {
        for (UIView  *subView in [self.volumeView subviews]) {
            if ([subView.class.description isEqualToString:@"MPVolumeSlider"]) {
                _volumeSlider = (UISlider*)subView;
                break;
            }
        }
    }
    return _volumeSlider;
}



-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = CGRectMake(7*ScaleH, 50*ScaleH, self.width-14*ScaleH, 372*ScaleH);
    self.slider.layer.frame = CGRectMake(7*ScaleH, self.playerLayer.bottom, self.playerLayer.width, 10);
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
    if (progress>1||progress<0) {
        return;
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
    NSLog(@"%f",value);
}


- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event{
    NSLog(@"%f",point.y);
    if ((point.y>-15&&point.y<0)||(point.y<15&&point.y>0)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
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








