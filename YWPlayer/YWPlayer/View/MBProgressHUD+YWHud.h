//
//  MBProgressHUD+YWHud.h
//  DYWHud
//
//  Created by duyawei on 2017/11/1.
//  Copyright © 2017年 abao. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (YWHud)

+(void)mb_showTextOnly:(UIView*)view title:(NSString*)title;

+(void)mb_showTextOnlyInWindow:(NSString*)title;

+(void)mb_showTextWithOffsetYOnly:(UIView*)view title:(NSString*)title offsetY:(CGFloat)offsetY;


+(void)mb_showLoadOnly:(UIView *)view;

+(void)mb_showLoadWithTitle:(UIView *)view title:(NSString*)title;


+(void)mb_showErrowMessage:(NSString*)title;

+(void)mb_showSuccessMessage:(NSString*)title;

+(void)mb_showAlphaToView:(UIView*)view title:(NSString*)title;

@end
