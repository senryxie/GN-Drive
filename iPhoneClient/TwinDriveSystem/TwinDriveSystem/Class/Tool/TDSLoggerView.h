//
//  TDSLoggerView.h
//  TwinDriveSystem
//
//  Created by 自 己 on 12-4-2.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDSLoggerView : UIView{
    UIView *_containerView;
    UITextView *_textView;
    NSMutableString *_logText;
}
+ (TDSLoggerView *)getInstance;
- (void)appendString:(NSString*)string;
- (void)appendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)clear;
- (void)updateDebugTextAnimated:(BOOL)animated;
@end
