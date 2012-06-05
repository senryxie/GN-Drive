//
//  TDSPhotoHTTPRequest.m
//  TwinDriveSystem
//
//  Created by zhongsheng on 12-2-28.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSNetControlCenter.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "TDSRequestObject.h"


#define RETRY_TIMES 3

@interface TDSNetControlCenter (Private)
- (void)requestDidStartSelector:(ASIFormDataRequest *)request;
- (void)requestDidFinishSelector:(ASIFormDataRequest *)request;
- (void)requestDidFailSelector:(ASIFormDataRequest *)request;

@end
@implementation TDSNetControlCenter
@synthesize operationQueue = _operationQueue;
@synthesize delegate;
- (void)dealloc{
    
    NSArray * array = _operationQueue.operations;
    for (ASIFormDataRequest* op in array) {
        [op setDelegate:nil];
    }
    [self.operationQueue reset];
    self.operationQueue = nil;
    self.delegate = nil;
    [super dealloc];
}

- (id)init{
    self = [super init];
    if (self) {
        _operationQueue = [[ASINetworkQueue alloc] init];
    }
    return self;
}
- (void)notifyWithNewMessage:(id)message {
    
}

- (void) sendRequestWithObject:(id)reqObj{
//    TDSLOG_info(@"sendRequestWithObject %@",reqObj);
    if (reqObj == nil) {
        return;
    }
    
    TDSConfig *config = [TDSConfig getInstance];
    
    ASIFormDataRequest *asiRequest = nil;
    
    if ([reqObj isKindOfClass:[NSURL class]]) {
        asiRequest = [ASIFormDataRequest requestWithURL:reqObj];
    }else if ([reqObj isKindOfClass:[TDSRequestObject class]]){
        TDSRequestObject *requestObject = (TDSRequestObject*)reqObj;
        asiRequest = [ASIFormDataRequest requestWithURL:requestObject.URL];
        asiRequest.userInfo = requestObject.userInfo;
        [asiRequest setRequestMethod:@"GET"];
        if (requestObject.postBody!= nil && requestObject.postBody.count > 0) {
            for (id key in requestObject.postBody.allKeys) {
                id value = [requestObject.postBody objectForKey:key];
                if (key && value) {
                    [asiRequest addPostValue:value forKey:key];                
                }
            }
            [asiRequest setRequestMethod:@"POST"];
        }
    }
    if (asiRequest != nil) {
        [asiRequest setDelegate:self];
        [asiRequest setDidStartSelector:@selector(requestDidStartSelector:)];    
        [asiRequest setDidFailSelector:@selector(requestDidFailSelector:)];
        [asiRequest setDidFinishSelector:@selector(requestDidFinishSelector:)];    
        [asiRequest setTimeOutSeconds:config.httpTimeout];
        [asiRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
        [asiRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [asiRequest setNumberOfTimesToRetryOnTimeout:RETRY_TIMES];
        [self.operationQueue addOperation:asiRequest];     

    }
    // 锁定操作队列执行
    @synchronized(self.operationQueue){
        if (self.operationQueue.isSuspended) {   
            [self.operationQueue go];
        }
    }
}

- (void)requestDidStartSelector:(ASIFormDataRequest *)request{
//    TDSLOG_info(@" requestDidStartSelector withUserInfo:%@",request.userInfo);
    // 回调
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tdsNetControlCenter:requestDidFinishedLoad:)]) {
        [self.delegate tdsNetControlCenter:self requestDidStartRequest:nil];
    }
}

- (void)requestDidFinishSelector:(ASIFormDataRequest *)request{
//    TDSLOG_info(@" requestDidFinishSelector withUserInfo:%@",request.userInfo);
    
    TDSRequestObject *responseObject = [TDSRequestObject request];
    responseObject.userInfo = request.userInfo;
    responseObject.responseString = request.responseString;
    // json 格式
    responseObject.rootObject = [request.responseString JSONValue];
    
    // 回调
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tdsNetControlCenter:requestDidFinishedLoad:)]) {
        [self.delegate tdsNetControlCenter:self requestDidFinishedLoad:responseObject];
    }
}
- (void)requestDidFailSelector:(ASIFormDataRequest *)request{
//    TDSLOG_info(@" requestDidFailSelector withUserInfo:%@",request.userInfo);
    TDSRequestObject *responseObject = [TDSRequestObject request];
    responseObject.error = request.error;
    TDSLOG_error(@"error:%@ === 【%@】",request.responseString,responseObject.error);    
    // 回调
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tdsNetControlCenter:requestDidFailedLoad:)]) {
        [self.delegate tdsNetControlCenter:self requestDidFailedLoad:responseObject];
    }    
    return;
}

@end
