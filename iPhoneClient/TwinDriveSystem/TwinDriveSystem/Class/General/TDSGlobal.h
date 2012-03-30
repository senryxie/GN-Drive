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

// notification
#define TDSNewPhotoNotification           @"TDSNewPhotoNotification"

// string
#define ResponseAction_Version        @"version"
#define ResponseAction_GetStartPage   @"get_start_page"
#define ResponseAction_SinglePhoto    @"single"
#define ResponseAction_MultiPhoto     @"get_multi"

#define AboutInfo_Version @"版本"
#define AboutInfo_Feedback @"意见反馈"
#define AboutInfo_ContactInfo @"联系方式"