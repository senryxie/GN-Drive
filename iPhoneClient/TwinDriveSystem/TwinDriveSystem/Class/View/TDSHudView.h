//
//  TDSHudView.h
//  TwinDriveSystem
//
//  Created by 自 己 on 12-4-2.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDSHudView : NSObject
{
    ATMHud*  _hud;
    BOOL     _overAnimFlag;
    NSTimer *_overAnimTimer;
}

@property (nonatomic, retain) ATMHud* hud;
@property (nonatomic, retain) NSTimer * overAnimTimer;

// 单例
+ (TDSHudView*) getInstance;

// 在window上显示hud
// 参数：
// caption:标题 
// image:图片 w:150px 最合适
// bActive：是否显示转圈动画
// time：自动消失时间，如果为0，则不自动消失

- (void)showHudOnWindow:(NSString*)caption 
                  image:(UIImage*)image
              acitivity:(BOOL)bAcitve
           autoHideTime:(NSTimeInterval)time;
// 在当前的view上显示hud
// 参数：
// view：要添加hud的view
// caption:标题 
// image:图片 w:150px 最合适
// bActive：是否显示转圈动画
// time：自动消失时间，如果为0，则不自动消失
- (void)showHudOnView:(UIView*)view 
              caption:(NSString*)caption
                image:(UIImage*)image
            acitivity:(BOOL)bAcitve
         autoHideTime:(NSTimeInterval)time;

// 隐藏hud
- (void)hideHud;
- (void)hideHudAfter:(NSTimeInterval)time;

@end
