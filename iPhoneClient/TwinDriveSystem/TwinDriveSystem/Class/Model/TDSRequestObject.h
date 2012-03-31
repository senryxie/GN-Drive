//
//  TDSRequestObject.h
//  TwinDriveSystem
//
//  Created by zhongsheng on 12-3-1.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDSRequestObject : NSObject{
    NSMutableDictionary *_parametersDic;
    NSURL *_URL;
    NSDictionary *_userInfo;
}

@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) NSMutableDictionary *parametersDic;
@property (nonatomic, retain) NSDictionary *userInfo;

+ (TDSRequestObject*)request;
+ (TDSRequestObject*)requestWithURL:(NSURL*)URL andUserInfo:(NSDictionary*)userInfo;
+ (id)requestObjectForQuery:(NSMutableDictionary*)query;
@end
