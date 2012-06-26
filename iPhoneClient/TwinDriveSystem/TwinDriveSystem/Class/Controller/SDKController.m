//
//  SDKController.m
//  TwinDriveSystem
//
//  Created by zhong sheng on 12-6-26.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "SDKController.h"
static SDKController *_instance = nil;
@implementation SDKController
@synthesize weiBoEngine = _weiBoEngine;

#pragma mark - singleton
- (void)dealloc{
    self.weiBoEngine = nil;
    [super dealloc];
}
- (id)init 
{
    self = [super init];
	if (self) {        
        WBEngine *engine = [[WBEngine alloc] initWithAppKey:kWBSDKAppKey appSecret:kWBSDKAppSecret];
        //[engine setRootViewController:self];
        //[engine setDelegate:self];
        [engine setRedirectURI:kWBSDKRedirectURI];
        [engine setIsUserExclusive:NO];
        self.weiBoEngine = engine;
        [engine release];
        
	}
	return self;
}

+ (SDKController*)getInstance{
    @synchronized(self) { // 防止同步问题
		if (_instance == nil) {
            _instance = [[SDKController alloc] init];
		}
	}
	return _instance; 
}

+ (id) allocWithZone:(NSZone*) zone {
	@synchronized(self) { 
		if (_instance == nil) {
			_instance = [super allocWithZone:zone];  // assignment and return on first allocation
			return _instance;
		}
	}
	return nil;
}

- (id) copyWithZone:(NSZone*) zone {
	return _instance;
}

- (id) retain {
	return _instance;
}

- (unsigned) retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (id) autorelease {
	return self;
}
@end
