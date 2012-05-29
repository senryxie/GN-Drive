//
//  TDSPhotoViewItem.h
//  TwinDriveSystem
//
//  Created by 自 己 on 12-3-20.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDSPhotoViewItem : NSObject <NSCoding>{
    NSNumber *_pid;
    NSString *_caption;
    NSString *_photoUrl;
    BOOL _collected;
}
@property (nonatomic, retain) NSNumber *pid;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *photoUrl;
@property (nonatomic) BOOL collected;
- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (TDSPhotoViewItem *)objectWithDictionary:(NSDictionary *)dictionary;

@end
