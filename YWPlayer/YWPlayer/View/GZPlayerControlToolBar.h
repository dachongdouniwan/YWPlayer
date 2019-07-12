//
//  GZPlayerControlToolBar.h
//  GZEduProject
//
//  Created by GZDongbing on 2019/7/9.
//  Copyright © 2019 dyw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWAVPlayer.h"

@class GZSlider;
NS_ASSUME_NONNULL_BEGIN

@interface GZPlayerControlToolBar : UIView

@property (nonatomic,strong) UIButton *startButton;

@property (nonatomic,weak) UIView *voiceView;

@property (nonatomic,weak) GZSlider *slider;

@property (nonatomic,copy) void(^playProgressBlock)(float currentTime);

@property (nonatomic,copy) void(^playComplateBlock)(YWAVPlayerComplate type);


-(void)updateSliderValue;

-(void)resetPlayer;


@end

NS_ASSUME_NONNULL_END
