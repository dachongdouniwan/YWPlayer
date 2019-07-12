//
//  MBProgressHUD+YWHud.m
//  DYWHud
//
//  Created by duyawei on 2017/11/1.
//  Copyright © 2017年 abao. All rights reserved.
//

#import "MBProgressHUD+YWHud.h"
#import "YYKit.h"
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
@implementation MBProgressHUD (YWHud)

+(void)mb_showTextOnly:(UIView*)view title:(NSString*)title{
    [self p_showTextOnly:view title:title offsetY:0.0];
}

+(void)mb_showTextWithOffsetYOnly:(UIView*)view title:(NSString*)title offsetY:(CGFloat)offsetY{
    [self p_showTextOnly:view title:title offsetY:offsetY];
}

+(void)mb_showTextOnlyInWindow:(NSString*)title{
    [self mb_showTextOnly:[self p_getTopView] title:title];
}

+(void)mb_showLoadOnly:(UIView *)view{
    [self p_showLoadOnly:view displayDim:NO isLoadTitle:nil];
}

+(void)mb_showLoadWithTitle:(UIView *)view title:(NSString*)title{
    [self p_showLoadOnly:view displayDim:NO isLoadTitle:title];
}

+(void)mb_showErrowMessage:(NSString*)title{
    [self mb_showTextOnly:[self p_getTopView] title:title];
}

+(void)mb_showSuccessMessage:(NSString*)title{
    [self mb_showTextOnly:[self p_getTopView] title:title];
}

+(void)mb_showAlphaHud:(UIView*)view alpha:(CGFloat)alpha title:(NSString*)title cornerRadius:(CGFloat)radius{
    [self p_showAlphaHud:alpha cornerRadius:radius view:view title:title offsetX:0];
}

+(void)p_showLoadOnly:(UIView*)view displayDim:(BOOL)disPlay isLoadTitle:(NSString*)title{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.bezelView.color = [UIColor blackColor];
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.alpha = 1.0;
    hud.label.text = title;
    if (disPlay) {
        hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.backgroundView.color = [UIColor blackColor];
        hud.backgroundView.alpha = 1.0;
    }
    [hud hideAnimated:YES afterDelay:3.f];
}

+(void)p_showTextOnly:(UIView*)view title:(NSString*)title offsetY:(CGFloat)offsetY{
//    if (offsetY<=0.0) {
//        offsetY = 50;
//    }
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
//    hud.label.text = title;
//    hud.mode = MBProgressHUDModeText;
//    hud.offset = CGPointMake(0.f, offsetY);
//    hud.margin = 10;
//    //设置背景颜色
//    hud.bezelView.color = [UIColor blackColor];
//    //放在最后否则可能被覆盖
//    hud.label.textColor = [UIColor whiteColor];
//    [hud hideAnimated:YES afterDelay:2.f];
//
    [self mb_showAlphaToView:nil title:title];
}


/**
 显示一个透明的hud

 @param alpha hud的透明度
 @param radius hud的半径
 @param view 父控件
 @param title 内容
 @param offsetx 左右间距
 */
+(void)p_showAlphaHud:(CGFloat)alpha cornerRadius:(CGFloat)radius view:(UIView*)view title:(NSString*)title offsetX:(CGFloat)offsetx{
    if (view==nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
    hud.label.text = title;
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10;
    hud.bezelView.layer.cornerRadius = radius;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    //设置背景颜色
    hud.bezelView.color = [UIColor colorWithWhite:0.0 alpha:.5];
    //放在最后否则可能被覆盖
    hud.label.textColor = [UIColor whiteColor];
    if (offsetx!=0) {
        NSDictionary *attrDic = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
        CGSize size = [title boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDic context:nil].size;
        hud.minSize = CGSizeMake(size.width+2*offsetx, 30);
    }
    [hud hideAnimated:YES afterDelay:2.f];
}


///妙小程APP使用
+(void)mb_showAlphaToView:(UIView*)view title:(NSString*)title{
    NSDictionary *attrDic = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
    CGSize size = [title boundingRectWithSize:CGSizeMake(ScreenW, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDic context:nil].size;
    
    if (view==nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
    hud.label.text = title;
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10;
    hud.offset = CGPointMake(0, 30);
    hud.minSize = CGSizeMake(size.width+60, 30);
    hud.bezelView.layer.cornerRadius = 20;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    //设置背景颜色
    hud.bezelView.color = [UIColor colorWithWhite:0.0 alpha:.5];;
    //放在最后否则可能被覆盖
    hud.label.textColor = [UIColor whiteColor];
    [hud hideAnimated:YES afterDelay:2.f];
}


+(UIView*)p_getTopView{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    NSArray *windowViews = [window subviews];
    if(windowViews && [windowViews count] > 0){
        UIView *topSubView = [windowViews objectAtIndex:[windowViews count]-1];
        return topSubView;
    }
    return nil;
}

@end
