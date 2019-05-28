//
//  YWCache.m
//  AVPlayerTest
//
//  Created by 杜亚伟 on 2018/3/28.
//  Copyright © 2018年 duyawei. All rights reserved.
//

#import "YWCache.h"

@implementation YWCache

static YWCache *cache = nil;


+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[self alloc] init];
    });
    return cache;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [super allocWithZone:zone];
    });
    return cache;
}

-(void)saveValue:(id)value withKey:(id)key{
    if (value&&key) {
        [self setObject:value forKey:key cost:1];
    }
}

-(id)fetchValueWithKey:(id)key{
    if ([self objectForKey:key]) {
        return [self objectForKey:key];
    }
    return nil;
}

@end
