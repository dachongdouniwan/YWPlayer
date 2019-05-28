//
//  CommonTool.m
//  YWPlayer
//
//  Created by GZDongbing on 2019/5/28.
//  Copyright © 2019 dyw. All rights reserved.
//

#import "CommonTool.h"
#import "YYKit.h"
#import "sys/utsname.h"

@implementation CommonTool


//获取特定富态文本
+(NSMutableAttributedString*)gz_stirngWith:(NSString*)oneString two:(NSString*)twoString oneColor:(UIColor*)oneColor twoColor:(UIColor*)twoColor oneFont:(UIFont*)oneFont twoFont:(UIFont*)twoFont{
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:oneString];
    one.font = oneFont;
    one.color = oneColor;
    NSMutableAttributedString *two = [[NSMutableAttributedString alloc] initWithString:twoString];
    two.font = twoFont;
    two.color = twoColor;
    [one appendAttributedString:two];
    return one;
}



///时间转换
+(NSString*)switchSecondsToMinute:(float)seconds{
    
    NSString *minuteStr;
    NSString *secondStr;
    
    seconds = floor(seconds);
    NSInteger minute = seconds/60;
    NSInteger hour = minute/60;
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
    
    if (hour>0) {
        if (hour>9.0) {
            hour = [NSString stringWithFormat:@"%ld:%@",hour,minuteStr];
        }else{
            hour = [NSString stringWithFormat:@"0%ld:%@",hour,minuteStr];
        }
    }
    return minuteStr;
}

@end
