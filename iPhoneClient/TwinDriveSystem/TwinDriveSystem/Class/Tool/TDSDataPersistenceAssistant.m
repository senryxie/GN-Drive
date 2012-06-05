//
//  TDSDataPersistenceAssistant.m
//  TwinDriveSystem
//
//  Created by 自 己 on 12-3-29.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSDataPersistenceAssistant.h"
#define kDataVersion @"kDataVersion"
#define kCollectPhotos @"kCollectPhotos"
#define kReadedPhotoIndexPath @"kReadedPhotoIndexPath"
@implementation TDSDataPersistenceAssistant

+ (void)clearAllData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDataVersion];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kCollectPhotos];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kReadedPhotoIndexPath];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)saveCollectPhotos:(NSDictionary *)collectPhotos{
    TDSConfig *config = [TDSConfig getInstance];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。
    [[NSUserDefaults standardUserDefaults] setObject:productVersion forKey:kDataVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:collectPhotos];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCollectPhotos];
}
+ (void)clearCollectPhotos{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kCollectPhotos];    
}
+ (NSDictionary *)getCollectPhotos{
    TDSConfig *config = [TDSConfig getInstance];
    NSString *nowVersion = config.version; // 也可以从info.plist中读取
    NSString *oldVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kDataVersion];
    if (!oldVersion || ![oldVersion isEqualToString:nowVersion]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCollectPhotos];
        return nil;
    }
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCollectPhotos];
    NSDictionary *collectPhotos = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	return collectPhotos;    
}
//////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)saveReadedPhotoIndexPath:(NSIndexPath *)indexPath{
    TDSConfig *config = [TDSConfig getInstance];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。
    [[NSUserDefaults standardUserDefaults] setObject:productVersion forKey:kDataVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:indexPath];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kReadedPhotoIndexPath];
    
    NSLog(@" ### IN DATA Persist %@ saved",indexPath);
}
+ (void)clearReadedPhotoIndexPath{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kReadedPhotoIndexPath];        
}
+ (NSIndexPath *)getReadedPhotoIndexPath{
    TDSConfig *config = [TDSConfig getInstance];
    NSString *nowVersion = config.version; // 也可以从info.plist中读取
    NSString *oldVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kDataVersion];
    if (!oldVersion || ![oldVersion isEqualToString:nowVersion] ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kReadedPhotoIndexPath];
        return [NSIndexPath indexPathForRow:0 inSection:-1];
    }
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kReadedPhotoIndexPath];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:-1];
    if (data) {
        indexPath = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    
	return indexPath;        
}

@end
