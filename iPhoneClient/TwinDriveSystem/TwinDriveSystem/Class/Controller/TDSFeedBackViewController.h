//
//  TDSFeedBackViewController.h
//  TwinDriveSystem
//
//  Created by 自 己 on 12-6-4.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSNetControlCenter.h"

@interface TDSFeedBackViewController : UIViewController <TDSNetControlCenterDelegate,UITextViewDelegate>{
    UITextView *_textView;
    TDSNetControlCenter *_netWorkHelper;
}

@end
