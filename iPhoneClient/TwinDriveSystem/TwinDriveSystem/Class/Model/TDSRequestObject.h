//
//  TDSRequestObject.h
//  TwinDriveSystem
//
//  Created by zhongsheng on 12-3-1.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDSRequestObject : NSObject{
    // request
    NSMutableDictionary *_parametersDic;
    NSURL *_URL;
    NSDictionary *_userInfo;
    NSMutableDictionary *_postBody;
    // response
    id _rootObject;
    NSError *_error;
    NSString *_responseString;
}
@property (nonatomic, retain) NSMutableDictionary *postBody;
@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) NSMutableDictionary *parametersDic;
@property (nonatomic, retain) NSDictionary *userInfo;
@property (nonatomic, retain) id rootObject;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, copy) NSString *responseString;

+ (TDSRequestObject*)request;
+ (TDSRequestObject*)requestWithURL:(NSURL*)URL andUserInfo:(NSDictionary*)userInfo;
+ (id)requestObjectForQuery:(NSMutableDictionary*)query;
@end
