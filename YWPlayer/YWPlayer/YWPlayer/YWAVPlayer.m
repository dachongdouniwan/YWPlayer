//
//  YWAVPlayer.m
//  AVPlayerTest
//
//  Created by 杜亚伟 on 2018/3/27.
//  Copyright © 2018年 duyawei. All rights reserved.
//

#import "YWAVPlayer.h"
#import "YWCache.h"
//#import "SVProgressHUD+YWSVPHud.h"

@interface YWAVPlayer()

@property(nonatomic,strong) id  obeserObject;

@property (nonatomic,assign) BOOL isDidObser;//是否已经添加通知和观察

@property (nonatomic,strong) NSArray *urlList;//播放队列

@property (nonatomic,assign) NSInteger playIndex;//当前播放音视频的索引


@end

@implementation YWAVPlayer

#pragma mark ---设置单例

static YWAVPlayer *player = nil;

+(instancetype)shareInstance{
    NSAssert(player!=nil, @"播放器必须通过url进行初始化");
    return player;
}


+(instancetype)shareInstanceWithUrl:(NSString*)url autoPlay:(BOOL)autoPlay{
    if ([self p_checkUrl:url]) {
        if (player) {
            [player p_switchPlayerItem:[self p_handleUrl:url] autoplay:autoPlay];
            player.isReapt = NO;
            player.isCache = NO;
            player.urlList = nil;
            return player;
        }else{
            YWAVPlayer *ywPlayer = [[self alloc] initWithURL:[self p_handleUrl:url]];
            [ywPlayer p_switchPlayerItem:[self p_handleUrl:url] autoplay:autoPlay];
            ywPlayer.isReapt = NO;
            ywPlayer.isCache = NO;
            ywPlayer.urlList = nil;
            return ywPlayer;
        }
    }else{
        //断言url不能用
        NSAssert(NO, @"url不可用");
//        [SVProgressHUD yw_showErrorMessage:@"播放失败，播放链接无效"];
    }
    return nil;
}


+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [super allocWithZone:zone];
        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
    });
    return  player;
}


-(id)copyWithZone:(NSZone *)zone{
    return player;
}


-(id)mutableCopyWithZone:(NSZone *)zone{
    return player;
}

#pragma mark ----播放，暂停方法

//重写play方法
-(void)play{
    [super play];
}


//重写pause方法监听暂停状态
- (void)pause{
    [super pause];
}


///判断是否正在播放
-(BOOL)isPlaying{
    if (self.rate==1) {
        return YES;
    }else{
        return NO;
    }
}


#pragma mark ----缓存播放时间

-(void)p_saveCacheMusicCurrentPlayeTime:(NSString*)originUrl{
    
    float currentTime = self.currentSecond;
    
    if (currentTime<5) {
        return;
    }
    
    float duration = CMTimeGetSeconds(self.currentItem.duration);
    if ((duration-currentTime)<5) {
        return;
    }
    [[YWCache shareInstance] saveValue:@(currentTime) withKey:self.originUrl];
}


//播放结束时重置部分属性
-(void)p_resetPlayerProperty{
    self.playComplateBlock = nil;
    self.playProgressBlock = nil;
    self.cacheTimeProgressBlock = nil;
}



#pragma mark ---核心方法，切换音视频

/**
 切换音视频
 
 @param newUrl 新的播放路径
 @param autoPlay 是否自动播放
 */
-(void)p_switchPlayerItem:(NSURL*)newUrl autoplay:(BOOL)autoPlay{
    
    //需要判断一下是否已经移除了观察者
    if (self.isDidObser) {
        //canclePlayer如果将originUrl = nil重新赋值
        NSString *url = [self.originUrl copy];
        [self canclePlayer];
        self.originUrl = url;
    }
    
    //初始化新的playerItem
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:newUrl];
    
    ///调用此方法切换播放源
    [self replaceCurrentItemWithPlayerItem:item];
    
    
    if (self.isCache&&[[YWCache shareInstance] fetchValueWithKey:self.originUrl]) {
        float second = [[[YWCache shareInstance] fetchValueWithKey:self.originUrl] floatValue];
        ///取出当前音频上次播放时间，没有播放货播放完成则默认为0
        if (second) {
            ///设置播放当前播放时间为上次播放的时间
            float currentSeconds = second;
            CMTime time = self.currentItem.currentTime;
            time.value = currentSeconds* time.timescale;
            [self seekToTime:time];
        }
    }
    
    //重新添加通知和观察者监听进度
    [self addNotificationAndObserver];
    
    //是否需要自动播放
    if (!self.isPlaying&&autoPlay) {
        [self play];
    }
}



#pragma mark ----手动切换

//切换到下一个音视频只适用urllist形式
+(void)yw_switchNextPlayer{
    if (player&&(player.urlList.count>1&&player.playIndex!=player.urlList.count-1)) {
        player.playIndex ++ ;
        [player p_switchPlayerItem:[self p_handleUrl:player.urlList[player.playIndex]] autoplay:YES];
    }else{
        //提示不能切换下一曲
        NSLog(@"没有下一曲");
    }
}


//切换到上一个音视频只适用urllist形式
+(void)yw_switchLastPlayer{
    if (player&&(player.urlList.count>1&&player.playIndex!=0)) {
        player.playIndex -- ;
        [player p_switchPlayerItem:[self p_handleUrl:player.urlList[player.playIndex]] autoplay:YES];
    }else{
        //提示不能切换上一曲
        NSLog(@"没有上一曲");
    }
}



#pragma mark ----时间转换
///时间转换
-(NSString*)switchSecondsToMinute:(float)seconds{
    
    NSString *minuteStr;
    NSString *secondStr;
    
    seconds = floor(seconds);
    NSInteger minute = seconds/60;
    NSInteger second = (int)seconds%60;
    
    if (second>9) {
        secondStr = [NSString stringWithFormat:@"%ld",second];
    }else{
        secondStr = [NSString stringWithFormat:@"0%ld",second];
    }
    
    if (minute>9.0) {
        minuteStr = [NSString stringWithFormat:@"%ld:%@",minute,secondStr];
    }else{
        minuteStr = [NSString stringWithFormat:@"0%ld:%@",minute,secondStr];
    }
    return minuteStr;
}



#pragma mark ----url处理

+(NSURL*)p_handleUrl:(NSString*)url{

    if (![self p_checkUrl:url]) {
        return nil;
    }
    
    NSURL *requestUrl ;
    if ([url hasPrefix:@"http"]) {
        requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",url]];
    }else{
        requestUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@",url]];
    }
    
    if (player.isCache) {
        if (player.originUrl) {
            [player p_saveCacheMusicCurrentPlayeTime:player.originUrl];
        }else{
            [player p_saveCacheMusicCurrentPlayeTime:[NSString stringWithFormat:@"%@",url]];
        }
    }
    
    //判断是否需要转吗，如果需要则直接使用
    if (!requestUrl) {
        //中文转码
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        if ([url containsString:@"http"]) {
            requestUrl = [NSURL URLWithString:url];
        }else{
            requestUrl = [NSURL fileURLWithPath:url];
        }
    }
    
    
    //更新url
    player.originUrl = url;
    
    return requestUrl;
}


+(BOOL)p_checkUrl:(NSString*)url{
    if ([url isKindOfClass:[NSNull class]]||!url||[url isEqualToString:@""]) {
        return NO;
    }else{
        return YES;
    }
}



#pragma mark ----播放方法

+(void)yw_playerWithUrl:(NSString*)url{
    [self yw_playerWithUrl:url complateBlock:nil autoplay:NO];
    player.isReapt = NO;
    player.isCache = NO;
    player.urlList = nil;
}


+(void)yw_playerWithUrl:(NSString*)url complateBlock:(YWAVPlayerComplateBlock)complateBlock{
    [self yw_playerWithUrl:url complateBlock:complateBlock autoplay:NO];
    player.isReapt = NO;
    player.isCache = NO;
    player.urlList = nil;
}


+(void)yw_playerWithUrl:(NSString*)url isReapt:(BOOL)reapt autoplay:(BOOL)autoplay complateBlock:(YWAVPlayerComplateBlock)complateBlock{
    [self yw_playerWithUrl:url complateBlock:complateBlock autoplay:autoplay];
    player.urlList = nil;
    player.isCache = NO;
    player.isReapt = reapt;
}


+(void)yw_playerList:(NSArray<NSString*>*)urlList{
    [self yw_playerWithUrl:urlList.firstObject complateBlock:nil autoplay:YES];
    player.urlList = urlList;
    player.playIndex = 0;
    player.isReapt = NO;
}


+(void)yw_playerList:(NSArray<NSString*>*)urlList playIndex:(NSInteger)playIndex playType:(YWAVPlayerPlayType)type autoPlay:(BOOL)autoPlay{
    [self yw_playerWithUrl:urlList[playIndex] complateBlock:nil autoplay:autoPlay];
    player.urlList = urlList;
    player.playIndex = playIndex;
    player.playerType = type;
    player.isReapt = NO;
}


+(void)yw_playerWithUrl:(NSString*)url complateBlock:(YWAVPlayerComplateBlock)complateBlock autoplay:(BOOL)autoplay{
    NSAssert([self p_checkUrl:url], @"url无效");
    if (![self p_checkUrl:url]) return;
    
    if (player) {
        [[self shareInstance] p_switchPlayerItem:[self p_handleUrl:url] autoplay:autoplay];
    }else{
        YWAVPlayer *ywPlayer = [[self alloc] initWithURL:[self p_handleUrl:url]];
        [ywPlayer p_switchPlayerItem:[self p_handleUrl:url] autoplay:autoplay];
    }
    
    if (complateBlock) {
        player.playComplateBlock = complateBlock;
    }
}



#pragma mark ----结束播放

//正常播放完成
-(void)playbackFinished:(NSNotification *)notification{
    
    [self removeNotificationAndObserver];//播放完成立即移除此playerItem对应的观察者和监听
    
    //播放完成会调
    !self.playComplateBlock?nil:self.playComplateBlock(YWAVPlayerNormalComplate);
    if ([self.delegate respondsToSelector:@selector(yw_playerPlayEnd:)]) {
        [self.delegate yw_playerPlayEnd:self];
    }
    
    if (self.isReapt) {
        [self p_switchPlayerItem:[[self class]p_handleUrl:self.originUrl] autoplay:YES];
    }else{
        if (self.urlList.count!=0&&self.playIndex!=self.urlList.count-1) {
            
            switch (self.playerType) {
                case YWAVPlayerOrderPlay:
                {
                    self.playIndex ++ ;
                    [self p_switchPlayerItem:[[self class] p_handleUrl:self.urlList[self.playIndex]] autoplay:YES];
                }
                    break;
                case YWAVPlayerRandom:
                {
                    //后续补充
                }
                    break;
                case YWAVPlayerSinglePlay:
                {
                    [self p_switchPlayerItem:[[self class] p_handleUrl:self.originUrl] autoplay:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    [[YWCache shareInstance] removeObjectForKey:self.originUrl];
    [self p_resetPlayerProperty];
}



//失败时回调
-(void)playError:(NSString*)errorMessage{
    [self removeNotificationAndObserver];//播放失败也要移除对应playerItem对应的观察者和监听者
    !self.playComplateBlock?nil:self.playComplateBlock(YWAVPlayerErrorComplate);
    if ([self.delegate respondsToSelector:@selector(yw_playerPlayError:currentPlayerItem:)]) {
        [self.delegate yw_playerPlayError:self currentPlayerItem:self.currentItem];
    }
//    [SVProgressHUD yw_showErrorMessage:errorMessage];
    [self p_resetPlayerProperty];
}


//手动取消播放
-(void)canclePlayer{
    if (self.isPlaying) {
        [self pause];
    }
    [self removeNotificationAndObserver];//手动取消播放也要移除对应playerItem对应的观察者和监听者
    !self.playComplateBlock?nil:self.playComplateBlock(YWAVPlayerCancleComplate);
    [self p_resetPlayerProperty];
}



#pragma mark ----添加观察者

///添加通知和观察者
-(void)addNotificationAndObserver{
    if (self.isDidObser) {
        [self removeNotificationAndObserver];
    }
    [self addNotification];
    [self addProgressObserver];
    [self addObserverToPlayerItem:self.currentItem];
    self.isDidObser = YES;
}


-(void)addNotification{
    //给AVPlayerItem添加播放完成通知（音乐播放完成后会回调通知方法）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
}



-(void)addProgressObserver{
    __weak typeof(self) weakSelf = self;
    //这里设置每秒执行一次,这个方法会在设定的时间间隔内定时更新播放进度，通过time参数通知客户端。
    self.obeserObject = [self addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        weakSelf.currentSecond = current;
        !weakSelf.playProgressBlock?nil:weakSelf.playProgressBlock(time);
        if ([weakSelf.delegate respondsToSelector:@selector(yw_player:time:)]) {
            [weakSelf.delegate yw_player:weakSelf time:time];
        }
    }];
}


-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}



#pragma mark ----移除观察者

///移除所有的通知和观察者
-(void)removeNotificationAndObserver{
    if (!self.isDidObser) {
        [self addNotificationAndObserver];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:self.currentItem];
    
    [self removeObserverFromPlayerItem:self.currentItem];
    [self removeTimeObserver:self.obeserObject];
    self.isDidObser = NO;
}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}


#pragma mark ----KVO监听回调

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            ///获取音频长度
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            if ([self.delegate respondsToSelector:@selector(yw_player:currentPlayerItem:)]) {
                [self.delegate yw_player:self currentPlayerItem:playerItem];
            }
        }else{
            //播放失败
            if ([self.delegate respondsToSelector:@selector(yw_playerPlayError:currentPlayerItem:)]) {
                [self.delegate yw_playerPlayError:self currentPlayerItem:playerItem];
            }
            [self playError:@"播放失败"];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        float totleSeconds = CMTimeGetSeconds(playerItem.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
        !self.cacheTimeProgressBlock?nil:self.cacheTimeProgressBlock(totleSeconds,totalBuffer);
        if ([self.delegate respondsToSelector:@selector(yw_plyaer:totleTime:currentTime:)]) {
            [self.delegate yw_plyaer:self totleTime:totleSeconds currentTime:totalBuffer];
        }
    }
}
@end
