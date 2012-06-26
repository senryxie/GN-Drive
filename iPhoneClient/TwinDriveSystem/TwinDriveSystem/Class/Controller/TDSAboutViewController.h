//
//  TDSAboutViewController.h
//  TwinDriveSystem
//
//  Created by 自 己 on 12-3-29.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TDSFeedBackViewController;

@interface TDSAboutViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    NSArray *_sectionHeaders;
	NSArray *_sectionFooters;
	NSArray *_cellCaptions;
    NSArray *_cellInfosLabels;
    TDSFeedBackViewController *_feedbackViewController;
}

@property (nonatomic, retain) UITableView *tableView;
@end
