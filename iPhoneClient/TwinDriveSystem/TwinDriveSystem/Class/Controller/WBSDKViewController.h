//
//  WBSDKViewController.h
//  TwinDriveSystem
//
//  Created by zhong sheng on 12-6-26.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBSDKViewController : UIViewController <WBEngineDelegate, UIAlertViewDelegate>{
}
@property (nonatomic ,retain) WBEngine *weiBoEngine;
@end
