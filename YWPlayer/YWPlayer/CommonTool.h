//
//  CommonTool.h
//  YWPlayer
//
//  Created by GZDongbing on 2019/5/28.
//  Copyright © 2019 dyw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonTool : NSObject

//获取特定富态文本
+(NSMutableAttributedString*)gz_stirngWith:(NSString*)oneString two:(NSString*)twoString oneColor:(UIColor*)oneColor twoColor:(UIColor*)twoColor oneFont:(UIFont*)oneFont twoFont:(UIFont*)twoFont;

///时间转换
+(NSString*)switchSecondsToMinute:(float)seconds;

@end

NS_ASSUME_NONNULL_END
