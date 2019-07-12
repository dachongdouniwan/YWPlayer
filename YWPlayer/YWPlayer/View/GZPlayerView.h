//
//  GZPlayerView.h
//  GZEduProject
//
//  Created by GZDongbing on 2019/2/18.
//  Copyright © 2019年 dyw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWAVPlayer.h"
NS_ASSUME_NONNULL_BEGIN

@interface GZPlayerView : UIView

- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSString*)url;

@property (nonatomic,copy) void(^closePlayerBlock)(void);

@property (nonatomic,copy) void(^playProgressBlock)(CGFloat currentTime,NSString*currentTimeString);//播放进度回调

@property (nonatomic,copy) void(^playComplateBlock)(YWAVPlayerComplate type);//播放完成回调

@property (nonatomic,assign) CGFloat totleTime;//视频总长度

@property (nonatomic,copy) NSString *totleTimeString;//视频总长度

@property (nonatomic,assign) CGFloat currentTime;//当前视频播放长度

@property (nonatomic,copy) NSString *currentTimeString;//当前视频播放长度

@property (nonatomic,weak) UIButton *cancleButton;

@property (nonatomic,weak) UILabel *nameLabel;/// 视频标题




@end

@interface GZSlider : UIView

@property (nonatomic,weak) UIView *progressView;

@property (nonatomic,weak) UIView *cacheProgressView;

@property (nonatomic,assign) CGFloat progress;

@property (nonatomic,assign) CGFloat cacheProgress;

@property (nonatomic,weak) UIImageView *flgImageView;

@property (nonatomic,copy) void(^progressblock)(CGFloat progress);

@end


@interface GZVoiceSlider : UIView

@property (nonatomic,assign) CGFloat progress;

@property (nonatomic,weak) UIView *sliderSelectlView;

@property (nonatomic,weak) UIImageView *flagImageView;

@property (nonatomic,copy) void(^progressblock)(CGFloat progress);


@end

NS_ASSUME_NONNULL_END
