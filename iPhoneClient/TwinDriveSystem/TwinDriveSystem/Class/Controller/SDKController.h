//
//  SDKController.h
//  TwinDriveSystem
//
//  Created by zhong sheng on 12-6-26.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDKController : NSObject
@property (nonatomic ,retain) WBEngine *weiBoEngine;
+ (SDKController*)getInstance;
@end
