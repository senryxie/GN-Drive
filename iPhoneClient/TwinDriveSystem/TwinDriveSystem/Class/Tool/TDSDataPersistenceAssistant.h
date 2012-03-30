//
//  TDSDataPersistenceAssistant.h
//  TwinDriveSystem
//
//  Created by 自 己 on 12-3-29.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDSDataPersistenceAssistant : NSObject

+ (void)clearAllData;

+ (void)saveCollectPhotos:(NSArray *)array;
+ (void)clearCollectPhotos;
+ (NSArray *)getCollectPhotos;


+ (void)saveReadedPhotoIndexPath:(NSIndexPath *)indexPath;
+ (void)clearReadedPhotoIndexPath;
+ (NSIndexPath *)getReadedPhotoIndexPath;

@end
