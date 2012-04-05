//
//  TDSHudView.m
//  TwinDriveSystem
//
//  Created by 自 己 on 12-4-2.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSHudView.h"

static TDSHudView* instance = nil;

@interface TDSHudView(Private)

- (void)setHudCaption:(NSString*)caption image:(UIImage*)image acitivity:(BOOL)bAcitve;
- (void)showHudAutoHideAfter:(NSTimeInterval)time;

@end


@implementation TDSHudView

@synthesize hud = _hud;
@synthesize overAnimTimer = _overAnimTimer;

- (void)dealloc
{
    [self hideHud];
    self.overAnimTimer = nil;
    [super dealloc];
}

#pragma mark - public method
// 在window上显示hud
- (void)showHudOnWindow:(NSString*)caption 
                  image:(UIImage*)image
              acitivity:(BOOL)bAcitve
           autoHideTime:(NSTimeInterval)time
{
    [self setHudCaption:caption image:image acitivity:bAcitve];
    [self.hud setAccessoryPosition:ATMHudAccessoryPositionTop];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.hud.view];
    
    [self showHudAutoHideAfter:time];
}

// 在当前的view上显示hud
- (void)showHudOnView:(UIView*)view 
              caption:(NSString*)caption
                image:(UIImage*)image
            acitivity:(BOOL)bAcitve
         autoHideTime:(NSTimeInterval)time
{
    [self setHudCaption:caption image:image acitivity:bAcitve];
    [self.hud setAccessoryPosition:ATMHudAccessoryPositionTop];  
    
    [view addSubview:self.hud.view];
    
    [self showHudAutoHideAfter:time];
}


// 隐藏hud
- (void)hideHud
{
    if(self.hud != nil)
    {
        [self.hud.view removeFromSuperview];
        [self.hud hide];
        self.hud = nil;
    }
}

- (void)hideHudAfter:(NSTimeInterval)time
{
	[self performSelector:@selector(hideHud) withObject:nil afterDelay:time];
}

#pragma mark - private method

- (void)setHudCaption:(NSString*)caption image:(UIImage*)image acitivity:(BOOL)bAcitve
{
    @synchronized (self.hud){
        // 强制清除一下
        [self hideHud];
        
        self.hud = [[[ATMHud alloc] initWithDelegate:nil] autorelease];
        if (image != nil) {
            [self.hud setImage:image];
        }
        
        [self.hud setCaption:caption];
        
        if (bAcitve) {
            [self.hud setActivity:YES];
            [self.hud setActivityStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
    }
}

- (void)showHudAutoHideAfter:(NSTimeInterval)time
{
    [self.hud show];
    
    if (time > 0.0f) {
        [self hideHudAfter:time];
    }
}

#pragma mark - Sington
+ (TDSHudView*) getInstance
{
    @synchronized(self){
        if (!instance) {
            instance = [[TDSHudView alloc] init];
        }
        return instance;
    }
}

- (id) init
{
    self = [super init];
    if (self) {
        self.overAnimTimer = nil;
    }
    return self;
}
//+ (id) allocWithZone:(NSZone*) zone {
//	@synchronized(self) { 
//		if (instance == nil) {
//			instance = [super allocWithZone:zone];  // assignment and return on first allocation
//			return instance;
//		}
//	}
//	return nil;
//}

//- (id) copyWithZone:(NSZone*) zone {
//	return instance;
//}
//
//- (id) retain {
//	return instance;
//}
//
//- (unsigned) retainCount {
//	return UINT_MAX;  //denotes an object that cannot be released
//}
//
//- (id) autorelease {
//	return self;
//}

@end
