//
//  TDSRequestObject.m
//  TwinDriveSystem
//
//  Created by zhongsheng on 12-3-1.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSRequestObject.h"

@implementation TDSRequestObject
@synthesize URL = _URL;
@synthesize parametersDic = _parametersDic;
@synthesize userInfo = _userInfo;
@synthesize error = _error;
@synthesize rootObject = _rootObject;
@synthesize responseString = _responseString;

- (void)dealloc{
    self.URL = nil;
    self.parametersDic = nil;
    self.userInfo = nil;
    self.error = nil;
    self.rootObject = nil;
    self.responseString = nil;
    [super dealloc];
}
- (id)init{
    self = [super init];
    if (self) {
        self.URL = nil;
        self.parametersDic = nil;
        self.userInfo = nil;
        self.error = nil;
        self.rootObject = nil;
        self.responseString = nil;
    }
    return self;
}
+ (TDSRequestObject*)request{
    TDSRequestObject *requestObject = [[TDSRequestObject alloc] init];
    return [requestObject autorelease];
}
+ (TDSRequestObject*)requestWithURL:(NSURL*)URL andUserInfo:(NSDictionary*)userInfo{
    TDSRequestObject *requestObject = [[TDSRequestObject alloc] init];
    requestObject.URL = URL;
    requestObject.userInfo = userInfo;
    return [requestObject autorelease];
}
+ (id)requestObjectForQuery:(NSMutableDictionary*)query{
    TDSRequestObject *requestObject = [TDSRequestObject request];
    requestObject.parametersDic = query;
    return requestObject;
}

- (NSURL*)URL{
    if (_URL == nil) {
        TDSConfig *config = [TDSConfig getInstance];
        NSMutableString *urlString = [NSMutableString stringWithString:config.mApiUrl];
        if ([self.parametersDic allKeys]>0) {
            [urlString appendString:@"?"];
            for (id key in self.parametersDic.allKeys) {
                id value = [self.parametersDic objectForKey:key];
                [urlString appendFormat:@"%@=%@",key,value];
            }
        }
        _URL = [NSURL URLWithString:urlString];       
    }
    TDSLOG_debug(@" ##requestURL:%@",_URL);    
    return _URL;
}
@end
