//
//  GZPlayerLayerView.h
//  GZEduProject
//
//  Created by GZDongbing on 2019/7/9.
//  Copyright © 2019 dyw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
@class YWAVPlayer,GZPlayerControlToolBar;
NS_ASSUME_NONNULL_BEGIN

@interface GZPlayerLayerView : UIView

@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@property (nonatomic,strong) YWAVPlayer *player;

@property (nonatomic,strong) GZPlayerControlToolBar *controlToolBar;

@property (nonatomic,copy) void(^tapBlock)(void);//单击

@property (nonatomic,copy) void(^resetPlayBlock)(void);//重播

@property (nonatomic,copy) void(^playerComplatePlay)(void);///播放完成回调

- (instancetype)initWithFrame:(CGRect)frame playerUrl:(NSString*)url;



@end

NS_ASSUME_NONNULL_END
