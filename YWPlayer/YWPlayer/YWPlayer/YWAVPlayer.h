//
//  YWAVPlayer.h
//  AVPlayerTest
//
//  Created by 杜亚伟 on 2018/3/27.
//  Copyright © 2018年 duyawei. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
@class YWAVPlayer;


typedef enum : NSUInteger {
    YWAVPlayerNormalComplate,
    YWAVPlayerCancleComplate,
    YWAVPlayerErrorComplate,
} YWAVPlayerComplate;


typedef enum : NSUInteger {
    YWAVPlayerOrderPlay,
    YWAVPlayerSinglePlay,
    YWAVPlayerRandom,
} YWAVPlayerPlayType;

typedef void(^YWAVPlayerComplateBlock)(YWAVPlayerComplate);

@protocol YWPlayerDelegate <NSObject>

@optional


/**
 更新播放进度
 
 @param player 当前播放器
 @param time 播放时间
 */
-(void)yw_player:(YWAVPlayer*_Nullable)player time:(CMTime)time;


/**
 正常播放完成
 
 @param player 当前播放器
 */
-(void)yw_playerPlayEnd:(YWAVPlayer*_Nullable)player;


/**
 获取当前播放音视频的信息（缓冲信息，音乐时间总长度等）
 
 @param player 当前播放器
 @param playerItem 当前播放器的playerItem
 */
-(void)yw_player:(YWAVPlayer*_Nullable)player currentPlayerItem:(AVPlayerItem*_Nullable)playerItem;


/**
 播放失败的回调
 
 @param player 当前播放器
 @param playerItem 当前播放器的playerItem
 */
-(void)yw_playerPlayError:(YWAVPlayer*_Nullable)player currentPlayerItem:(AVPlayerItem*_Nullable)playerItem;


/**
 更新缓冲时间
 
 @param player 播放器
 @param totleTime 一共需要缓冲多少时间
 @param currentTime 当前已经缓冲多少时间
 */
-(void)yw_plyaer:(YWAVPlayer *_Nullable)player totleTime:(float)totleTime currentTime:(float)currentTime;


@end



@interface YWAVPlayer : AVPlayer

//播放完成的回调，参数表示完成的方式
@property (nonatomic,copy) YWAVPlayerComplateBlock _Nullable playComplateBlock;

//当前播放进度
@property (nonatomic,copy) void(^ _Nullable playProgressBlock)(CMTime time);

///获取当前播放Url音视频总长度
@property (nonatomic,copy) void(^ _Nullable playTotleTimeBlock)(float totleTime);

//缓冲，总长度block回调
@property (nonatomic,copy) void(^ _Nullable cacheTimeProgressBlock)(float totleTime,float cacheTime);

//播放类型
@property (nonatomic,assign) YWAVPlayerPlayType playerType;

//代理
@property(nonatomic,weak) id<YWPlayerDelegate> _Nullable delegate;

//初始化单例时传入的urlString(每次切换音乐都会更新此属性)
@property (nonatomic,copy) NSString * _Nullable originUrl;

//设置当前播放音频的播放时间
@property (nonatomic,assign) float currentSecond;

//是否开启缓存
@property (nonatomic,assign) BOOL isCache;

//是否重复播放
@property (nonatomic,assign) BOOL isReapt;




#pragma mark ----外部获取实力对象的方法


/**
 用于获取播放器单例对象，不能用来初始化
 
 @return player
 */
+(instancetype _Nullable )shareInstance;



/**
 用于为AVPlayerLayer的初始化提供一个播放的player，指定构造器
 
 @param url 需要播放的url
 @param autoPlay 是否自动播放
 @return 初始化需要的player
 */
+(instancetype _Nullable )shareInstanceWithUrl:(NSString*_Nullable)url autoPlay:(BOOL)autoPlay;




#pragma mark ----播放方法

/**
 判断是否正在播放
 
 @return YES为正在播放，NO为暂停
 */
-(BOOL)isPlaying;



/**
 播放指定url的音视频
 
 @param url url不能为nil
 */
+(void)yw_playerWithUrl:(nonnull NSString*)url;



/**
 播放指定url的音视频
 
 @param url url不能为nil
 @param complateBlock 播放完成回调
 */
+(void)yw_playerWithUrl:(nonnull NSString*)url complateBlock:(YWAVPlayerComplateBlock _Nullable )complateBlock;



/**
 根据指定格式来播放音视频
 
 @param url 播放url
 @param reapt 是否重复播放
 @param autoplay 是否自动播放
 @param complateBlock 播放完成回调
 */
+(void)yw_playerWithUrl:(nonnull NSString*)url isReapt:(BOOL)reapt autoplay:(BOOL)autoplay complateBlock:(YWAVPlayerComplateBlock _Nullable)complateBlock;



/**
 播放一组音视频
 
 @param urlList 播放url数组
 */
+(void)yw_playerList:(nonnull NSArray<NSString*>*)urlList;



/**
 播放一组音视频
 
 @param urlList 播放url数组
 @param playIndex 指定播放的开始位置
 @param type 指定循环类型
 @param autoPlay 是否自动播放
 
 */
+(void)yw_playerList:(nonnull NSArray<NSString*>*)urlList playIndex:(NSInteger)playIndex playType:(YWAVPlayerPlayType)type autoPlay:(BOOL)autoPlay;



/**
 切换下一曲
 */
+(void)yw_switchNextPlayer;



/**
 切换上一曲
 */
+(void)yw_switchLastPlayer;



#pragma mark ----取消播放

/**
 手动取消播放
 */
-(void)canclePlayer;



#pragma mark ---缓存

/**
 缓存播放时间
 
 @param originUrl 以播放的url为key
 */
-(void)p_saveCacheMusicCurrentPlayeTime:(nonnull NSString*)originUrl;


/**
 时间转换
 
 @param seconds 需要转换的时间
 @return 返回转换后的时间
 */
-(NSString*_Nullable)switchSecondsToMinute:(float)seconds;


#pragma mark ----检查URL是否有效

+(BOOL)p_checkUrl:(NSString*_Nonnull)url;

@end
