//
//  TDSAboutViewController.h
//  TwinDriveSystem
//
//  Created by 自 己 on 12-3-29.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDSAboutViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSArray *_sectionHeaders;
	NSArray *_sectionFooters;
	NSArray *_cellCaptions;
    NSArray *_cellInfosLabels;
}

@property (nonatomic, retain) UITableView *tableView;
@end
