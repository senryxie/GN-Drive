//
//  TDSPhotoViewController.h
//  TwinDriveSystem
//
//  Created by 钟 声 on 12-2-12.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "EGOPhotoViewController.h"
#import "TDSNetControlCenter.h"
@class TDSPhotoDataSource;
@interface TDSPhotoViewController : EGOPhotoViewController <TDSNetControlCenterDelegate>{
    TDSNetControlCenter *_photoViewNetControlCenter;
    
    NSInteger _requestNextPageCount; // 向后请求page计数    
    NSInteger _requestPrePageCount;  // 向前请求page计数
    
    NSInteger _startPage;   // 开始页面，配合无线前后翻滚逻辑

    // 记录历史页面
    NSInteger _recordPageSection; // (nowIndex/5)+requestPage-requestPrePageCount
    NSInteger _recordPageIndex;   // (nowIndex%5)
    
    // 收藏建
    UIButton *_collectButton;
    
    BOOL _firstLoad;
    
    BOOL _isExtremity;
    
    BOOL _isError; // 可能需要一个枚举
    
    BOOL _isNoNext;
    
    BOOL _isNoPrevious;    
}
@property (nonatomic, retain)TDSNetControlCenter *photoViewNetControlCenter;
- (TDSPhotoDataSource *)photoSource; // 这尼玛为啥会是readOnly，暴露出来

@end
