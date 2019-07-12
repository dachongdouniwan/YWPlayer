//
//  GZPlayerControlToolBar.m
//  GZEduProject
//
//  Created by GZDongbing on 2019/7/9.
//  Copyright © 2019 dyw. All rights reserved.
//

#import "GZPlayerControlToolBar.h"
#import "YYKit.h"
#import "GZPlayerView.h"
#import <MediaPlayer/MPVolumeView.h>
#import "Masonry.h"
#import "CommonTool.h"

#define ScaleH [UIScreen mainScreen].bounds.size.width/414.0
#define ScreenW [UIScreen mainScreen].bounds.size.width

@interface GZPlayerControlToolBar()

@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong) MPVolumeView *volumeView;

@property (nonatomic,weak) UISlider *volumeSlider;

@property (nonatomic,assign) CGFloat totleTime;//视频总长度

@property (nonatomic,copy) NSString *totleTimeString;//视频总长度

@property (nonatomic,assign) CGFloat currentTime;//当前视频播放长度

@property (nonatomic,copy) NSString *currentTimeString;//当前视频播放长度

@end

@implementation GZPlayerControlToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setSubviews];
        [self addSubview:self.volumeView];
    }
    return self;
}


-(void)_setSubviews{
    
    GZSlider *slider = [[GZSlider alloc]init];
    [self addSubview:slider];
    self.slider = slider;
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = @"00:00/00:00";
    [timeLabel sizeToFit];
    [self addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    UIButton *startButton = [[UIButton alloc] init];
    startButton.tag = 101;
    [startButton addTarget:self action:@selector(buttonClcik:) forControlEvents:UIControlEventTouchUpInside];
    [startButton setImage:[YYImage imageNamed:@"gz_player_start"] forState:UIControlStateNormal];
    [startButton setImage:[YYImage imageNamed:@"gz_player_pause"] forState:UIControlStateSelected];
    startButton.selected = YES;
    [self addSubview:startButton];
    self.startButton = startButton;
    
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
    

    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(10);
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(20*ScaleH);
        make.centerY.equalTo(startButton.mas_centerY);
    }];
    
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).with.offset(-10*ScaleH);
        make.size.mas_equalTo(CGSizeMake(50*ScaleH, 50*ScaleH));
    }];
    
    [voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-80*ScaleH);
        make.centerY.equalTo(startButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(25*ScaleH, 25*ScaleH));
    }];
    
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(startButton.mas_centerY);
        make.right.equalTo(startButton.mas_left).with.offset(-30*ScaleH);
        make.size.mas_equalTo(CGSizeMake(30*ScaleH, 30*ScaleH));
    }];
    
    [forwordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(startButton.mas_centerY);
        make.left.equalTo(startButton.mas_right).with.offset(30*ScaleH);
        make.size.mas_equalTo(CGSizeMake(30*ScaleH, 30*ScaleH));
    }];
    
    [voiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(voiceButton.mas_top).with.offset(-10*ScaleH);
        make.size.mas_equalTo(CGSizeMake(25*ScaleH, 120*ScaleH));
        make.centerX.equalTo(voiceButton);
    }];
    
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
                self.startButton.selected = YES;
            }
        }];
    };
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    GZVoiceSlider *voiceSlider = [[GZVoiceSlider alloc] initWithFrame:voiceView.bounds];
    voiceSlider.progress = (1.0-[AVAudioSession sharedInstance].outputVolume);
    [voiceView addSubview:voiceSlider];
    voiceSlider.progressblock = ^(CGFloat progress) {
        @strongify(self);
        self.volumeSlider.value = (1-progress);
    };
    [self _setPlayerCallBack];
    
}


-(void)updateSliderValue{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.slider.progress = self.currentTime/self.totleTime;
}


-(void)resetPlayer{
    [self _setPlayerCallBack];
}



/**
 音量的 view
 把系统的音量的 view 的 frame 设置到根本看不见的地方，这样就不会覆盖自定义的 提示 view
 */
- (MPVolumeView *)volumeView {
    
    if (_volumeView == nil) {
        // 如果要显示音量的 view  可在这里设置，默认只调整音量，没有显示View
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-ScreenW, -20, 10, 10)];
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



-(void)_setPlayerCallBack{
    @weakify(self);
    [YWAVPlayer shareInstance].playProgressBlock = ^(CMTime time) {
        @strongify(self);
        if (self.totleTime>0) {
            CGFloat currentTime = CMTimeGetSeconds(time);
            NSString *currentTimeString = [CommonTool switchSecondsToMinute:currentTime];
            self.currentTime = currentTime;
            self.currentTimeString = currentTimeString;
            self.slider.progress = currentTime/self.totleTime;
            self.timeLabel.attributedText = [CommonTool gz_stirngWith:currentTimeString two:[NSString stringWithFormat:@" / %@",[CommonTool switchSecondsToMinute:self.totleTime]] oneColor:[UIColor colorWithHexString:@"#FFC500"] twoColor:[UIColor blackColor] oneFont:[UIFont systemFontOfSize:18] twoFont:[UIFont systemFontOfSize:18]];
            !self.playProgressBlock?nil:self.playProgressBlock(currentTime);
        }
    };
    
    [YWAVPlayer shareInstance].cacheTimeProgressBlock = ^(float totleTime, float cacheTime) {
        @strongify(self);
        NSString *totleTimeString = [CommonTool switchSecondsToMinute:totleTime];
        self.totleTimeString = totleTimeString;
        self.totleTime = totleTime;
        self.slider.cacheProgress = cacheTime/totleTime;
        if ([self.timeLabel.text isEqualToString:@"00:00/00:00"]) {
            self.timeLabel.text = [NSString stringWithFormat:@"00:00/%@",totleTimeString];
        }
    };
    
    
    [YWAVPlayer shareInstance].playComplateBlock = ^(YWAVPlayerComplate type) {
        @strongify(self);
        self.startButton.selected = NO;
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


-(void)forwadPlayer:(BOOL)isForward{
    @weakify(self);
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
        @strongify(self);
        if (finished) {
            [[YWAVPlayer shareInstance] play];
            self.startButton.selected = YES;
        }
    }];
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    NSLog(@"%f---==%f--==%f----==%f",point.x,point.y,self.voiceView.frame.origin.x,self.voiceView.frame.origin.y);
    CGFloat left = self.voiceView.frame.origin.x-20;
    CGFloat right = CGRectGetMaxX(self.voiceView.frame)+20;
    CGFloat top = self.voiceView.frame.origin.y-self.voiceView.bounds.size.height-20;
    if ((point.x>left&&point.x<right)&&(point.y<0*ScaleH&&point.y>top)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

@end
