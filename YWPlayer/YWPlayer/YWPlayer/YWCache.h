//
//  YWCache.h
//  AVPlayerTest
//
//  Created by 杜亚伟 on 2018/3/28.
//  Copyright © 2018年 duyawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YWCache : NSCache

+(instancetype)shareInstance;


-(void)saveValue:(id)value withKey:(id)key;


-(id)fetchValueWithKey:(id)key;

@end
