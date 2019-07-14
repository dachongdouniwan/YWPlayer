//
//  YWMusicPlayer.m
//  GZEduProject
//
//  Created by GZDongbing on 2018/12/20.
//  Copyright © 2018年 dyw. All rights reserved.
//

#import "YWMusicPlayer.h"
#import "YWCache.h"
//#import "SVProgressHUD+YWSVPHud.h"

@interface YWMusicPlayer()

@property(nonatomic,strong) id  obeserObject;

@property (nonatomic,assign) BOOL isDidObser;//是否已经添加通知和观察

@property (nonatomic,strong) NSArray *urlList;//播放队列

@property (nonatomic,assign) NSInteger playIndex;//当前播放音视频的索引

@end


@implementation YWMusicPlayer

#pragma mark ---设置单例

static YWMusicPlayer *musicPlayer = nil;

+(instancetype)shareInstance{
    NSAssert(musicPlayer!=nil, @"播放器必须通过url进行初始化");
    return musicPlayer;
}


+(instancetype)shareInstanceWithUrl:(NSString*)url autoPlay:(BOOL)autoPlay{
    if ([self p_checkUrl:url]) {
        if (musicPlayer) {
            [musicPlayer p_switchPlayerItem:[self p_handleUrl:url] autoplay:autoPlay];
            musicPlayer.isReapt = NO;
            musicPlayer.isCache = NO;
            musicPlayer.urlList = nil;
            return musicPlayer;
        }else{
            YWMusicPlayer *ywMusicPlayer = [[self alloc] initWithURL:[self p_handleUrl:url]];
            [ywMusicPlayer p_switchPlayerItem:[self p_handleUrl:url] autoplay:autoPlay];
            ywMusicPlayer.isReapt = NO;
            ywMusicPlayer.isCache = NO;
            ywMusicPlayer.urlList = nil;
            return ywMusicPlayer;
        }
    }else{
        musicPlayer.originUrl = nil;
        //断言url不能用
        NSAssert(NO, @"url不可用");
    }
    return nil;
}


+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        musicPlayer = [super allocWithZone:zone];
        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
    });
    return  musicPlayer;
}


-(id)copyWithZone:(NSZone *)zone{
    return musicPlayer;
}


-(id)mutableCopyWithZone:(NSZone *)zone{
    return musicPlayer;
}

#pragma mark ----播放，暂停方法

//重写play方法
-(void)play{
    /// 如果originUrl为nil则认为此播放器已失效不能进行播放
    if (self.originUrl) {
        [super play];
    }
}


//重写pause方法监听暂停状态
- (void)pause{
    if (self.originUrl) {
        [super pause];
    }
}


//重写快进方法
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler{
    /// 如果originUrl为nil则认为此播放器已失效不能进行播放
    if (self.originUrl) {
        [super seekToTime:time completionHandler:completionHandler];
    }
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
    if (!self.isReapt) {
        self.originUrl = nil;
        self.playComplateBlock = nil;
        self.playProgressBlock = nil;
        self.cacheTimeProgressBlock = nil;
        self.playTotleTimeBlock = nil;
    }
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
    if (musicPlayer&&(musicPlayer.urlList.count>1&&musicPlayer.playIndex!=musicPlayer.urlList.count-1)) {
        musicPlayer.playIndex ++ ;
        [musicPlayer p_switchPlayerItem:[self p_handleUrl:musicPlayer.urlList[musicPlayer.playIndex]] autoplay:YES];
    }else{
        //提示不能切换下一曲
        NSLog(@"没有下一曲");
    }
}


//切换到上一个音视频只适用urllist形式
+(void)yw_switchLastPlayer{
    if (musicPlayer&&(musicPlayer.urlList.count>1&&musicPlayer.playIndex!=0)) {
        musicPlayer.playIndex -- ;
        [musicPlayer p_switchPlayerItem:[self p_handleUrl:musicPlayer.urlList[musicPlayer.playIndex]] autoplay:YES];
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
    
    NSURL *requestUrl ;
    if ([url hasPrefix:@"http"]) {
        requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",url]];
    }else{
        requestUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@",url]];
    }
    
    if (musicPlayer.isCache) {
        if (musicPlayer.originUrl) {
            [musicPlayer p_saveCacheMusicCurrentPlayeTime:musicPlayer.originUrl];
        }else{
            [musicPlayer p_saveCacheMusicCurrentPlayeTime:[NSString stringWithFormat:@"%@",url]];
        }
    }
    
    //判断是否需要转吗，如果需要则直接使用
    if (!requestUrl) {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if ([url containsString:@"http"]) {
            requestUrl = [NSURL URLWithString:url];
        }else{
            requestUrl = [NSURL fileURLWithPath:url];
        }
    }
    //更新url
    musicPlayer.originUrl = url;
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
    musicPlayer.isReapt = NO;
    musicPlayer.isCache = NO;
    musicPlayer.urlList = nil;
}


+(void)yw_playerWithUrl:(NSString*)url complateBlock:(YWMusicPlayerComplateBlock)complateBlock{
    [self yw_playerWithUrl:url complateBlock:complateBlock autoplay:NO];
    musicPlayer.isReapt = NO;
    musicPlayer.isCache = NO;
    musicPlayer.urlList = nil;
}


+(void)yw_playerWithUrl:(NSString*)url isReapt:(BOOL)reapt autoplay:(BOOL)autoplay complateBlock:(YWMusicPlayerComplateBlock)complateBlock{
    [self yw_playerWithUrl:url complateBlock:complateBlock autoplay:autoplay];
    musicPlayer.urlList = nil;
    musicPlayer.isCache = NO;
    musicPlayer.isReapt = reapt;
}


+(void)yw_playerList:(NSArray<NSString*>*)urlList{
    [self yw_playerWithUrl:urlList.firstObject complateBlock:nil autoplay:YES];
    musicPlayer.urlList = urlList;
    musicPlayer.playIndex = 0;
    musicPlayer.isReapt = NO;
}


+(void)yw_playerList:(NSArray<NSString*>*)urlList playIndex:(NSInteger)playIndex playType:(YWMusicPlayerPlayType)type autoPlay:(BOOL)autoPlay{
    [self yw_playerWithUrl:urlList[playIndex] complateBlock:nil autoplay:autoPlay];
    musicPlayer.urlList = urlList;
    musicPlayer.playIndex = playIndex;
    musicPlayer.playerType = type;
    musicPlayer.isReapt = NO;
}


+(void)yw_playerWithUrl:(NSString*)url complateBlock:(YWMusicPlayerComplateBlock)complateBlock autoplay:(BOOL)autoplay{
    NSAssert([self p_checkUrl:url], @"url无效");
    if (![self p_checkUrl:url]) return;
    
    if (musicPlayer) {
        [[self shareInstance] p_switchPlayerItem:[self p_handleUrl:url] autoplay:autoplay];
    }else{
         YWMusicPlayer *ywPlayer = [[self alloc] initWithURL:[self p_handleUrl:url]];
        [ywPlayer p_switchPlayerItem:[self p_handleUrl:url] autoplay:autoplay];
    }
    
    if (complateBlock) {
        musicPlayer.playComplateBlock = complateBlock;
    }
}



#pragma mark ----结束播放

//正常播放完成
-(void)playbackFinished:(NSNotification *)notification{
    
    [self removeNotificationAndObserver];//播放完成立即移除此playerItem对应的观察者和监听
    
    //播放完成会调
    !self.playComplateBlock?nil:self.playComplateBlock(YWMusicPlayerrNormalComplate);
    if ([self.delegate respondsToSelector:@selector(yw_musicPlayerPlayEnd:)]) {
        [self.delegate yw_musicPlayerPlayEnd:self];
    }
    
    if (self.isReapt) {
        [self p_switchPlayerItem:[[self class]p_handleUrl:self.originUrl] autoplay:YES];
    }else{
        if (self.urlList.count!=0&&self.playIndex!=self.urlList.count-1) {
            
            switch (self.playerType) {
                case YWMusicPlayerOrderPlay:
                {
                    self.playIndex ++ ;
                    [self p_switchPlayerItem:[[self class] p_handleUrl:self.urlList[self.playIndex]] autoplay:YES];
                }
                    break;
                case YWMusicPlayerRandom:
                {
                    //后续补充
                }
                    break;
                case YWMusicPlayerSinglePlay:
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
-(void)playError{
    [self removeNotificationAndObserver];//播放失败也要移除对应playerItem对应的观察者和监听者
    !self.playComplateBlock?nil:self.playComplateBlock(YWMusicPlayerErrorComplate);
    if ([self.delegate respondsToSelector:@selector(yw_musicPlayerPlayError:currentPlayerItem:)]) {
        [self.delegate yw_musicPlayerPlayError:self currentPlayerItem:self.currentItem];
    }
    [self p_resetPlayerProperty];
}


//手动取消播放
-(void)canclePlayer{
    if (self.isPlaying) {
        [self pause];
    }
    self.isReapt = NO;/// 手动取消时设置为NO清空对应的block
    [self removeNotificationAndObserver];//手动取消播放也要移除对应playerItem对应的观察者和监听者
    !self.playComplateBlock?nil:self.playComplateBlock(YWMusicPlayerCancleComplate);
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
        if ([weakSelf.delegate respondsToSelector:@selector(yw_musicPlayer:time:)]) {
            [weakSelf.delegate yw_musicPlayer:weakSelf time:time];
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
            if ([self.delegate respondsToSelector:@selector(yw_musicPlayer:currentPlayerItem:)]) {
                [self.delegate yw_musicPlayer:self currentPlayerItem:playerItem];
            }
        }else{
            //播放失败
            if ([self.delegate respondsToSelector:@selector(yw_musicPlayerPlayError:currentPlayerItem:)]) {
                [self.delegate yw_musicPlayerPlayError:self currentPlayerItem:playerItem];
            }
            [self playError];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        float totleSeconds = CMTimeGetSeconds(playerItem.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
        if ([self.delegate respondsToSelector:@selector(yw_musicPlayer:totleTime:currentTime:)]) {
            [self.delegate yw_musicPlayer:self totleTime:totleSeconds currentTime:totalBuffer];
        }
    }
}

@end
