//
//  TDSCollectPhotoViewController.h
//  TwinDriveSystem
//
//  Created by 自 己 on 12-4-9.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "EGOPhotoViewController.h"
@class TDSPhotoDataSource;
@interface TDSCollectPhotoViewController : TDSEGOPhotoViewController{
    BOOL _isEmpty;
    UIButton *_collectButton;
}
- (void)updatePhotoSourceNotication:(NSNotification*)notication;
@end
