//
//  TDSGlobal.h
//  TwinDriveSystem
//
//  Created by zhongsheng on 12-2-29.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TDSConfig.h"
#import "EGOPhotoGlobal.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "TDSLogger.h"
#import "NSString+NSStringExt.h"
#import "UIDevice+UIDeviceExt.h"
#import "TDSDataPersistenceAssistant.h"
#import "ATMHud.h"
#import "TDSHudView.h"
#import "TDSEGOPhotoViewController.h"
#import "Reachability.h"
#import "WBEngine.h"
#import "SDKController.h"

// SDK
#define kWBSDKAppKey @"459673502"
#define kWBSDKAppSecret @"87ff70bf34f6b026217a4025a97b0ed0"
#define kWBSDKRedirectURI @"http://morelife.sinaapp.com/connect_callback"


// notification
#define TDSNewPhotoNotification              @"TDSNewPhotoNotification"
#define TDSRecordPhotoNotification           @"TDSRecordPhotoNotification"
#define TDSNetStatueChangedNotication        @"TDSNetStatueChangedNotication"

// string
#define ResponseAction_Version        @"version"
#define ResponseAction_GetStartPage   @"get_start_page"
#define ResponseAction_SinglePhoto    @"single"
#define ResponseAction_MultiPhoto     @"get_multi"


#define COLLECT_BUTTON_FRAME CGRectMake(260, 10, 40, 40)
