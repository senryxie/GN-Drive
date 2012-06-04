//
//  TDSAboutViewController.m
//  TwinDriveSystem
//
//  Created by 自 己 on 12-3-29.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSAboutViewController.h"
#import "UMFeedback.h"
#import "TDSFeedBackViewController.h"

#define CONTACT_INFO @"icephone@gmail.com"

@interface TDSAboutViewController ()
- (void)setDataSource;
@end

@implementation TDSAboutViewController
@synthesize tableView = _tableView;

- (void)dealloc{
    [_aboutArray release];
    self.tableView = nil;
    [super dealloc];
}

#pragma mark - debug
- (void)testAction:(id)sender{
    [TDSDataPersistenceAssistant clearAllData];
    [[TDSHudView getInstance] showHudOnView:self.view
                                    caption:@"     暂时清除缓存成功     "
                                      image:[UIImage imageNamed:@"hudDefault.png"] 
                                  acitivity:NO
                               autoHideTime:1.0f];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"关于街拍控";
    
    [self setDataSource];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
//    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    /* for debug
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(50, 50, 50, 50);
    button.center = self.view.center;
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self 
               action:@selector(testAction:) 
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
     //*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Pirvate
- (void)setDataSource{
    // dirty code
    // TODO:为了快点看到效果
    _aboutArray = [[NSArray alloc] initWithObjects:AboutInfo_Version,AboutInfo_Feedback,AboutInfo_ContactInfo, nil];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BOOL show = YES;
    // dirty code
    NSString *cellInfo = [_aboutArray objectAtIndex:indexPath.row];
    NSMutableString *message= [NSMutableString stringWithFormat:@"%@\n",cellInfo];
    if ([cellInfo isEqualToString:AboutInfo_Version]) {
        [message appendFormat:@"%@",[TDSConfig getInstance].version];
    }else if([cellInfo isEqualToString:AboutInfo_Feedback]) {
        TDSFeedBackViewController *feedbackViewController = [[TDSFeedBackViewController alloc] init];
        feedbackViewController.view.frame = self.view.bounds;
        feedbackViewController.navigationItem.title = cellInfo;
        [self.navigationController pushViewController:feedbackViewController animated:YES];
        [feedbackViewController release];
        show = NO;
    }else if([cellInfo isEqualToString:AboutInfo_ContactInfo]) {
        [message appendFormat:@"%@",CONTACT_INFO];        
    }
    if (show) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:message
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.0f];

    }
  }
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_aboutArray != nil && [_aboutArray count]>0)
        return [_aboutArray count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
	if(_aboutArray != nil && [_aboutArray count]>0)
	{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.font = [UIFont fontWithName:@"Arial" size:17.0];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		NSString *aboutText = [_aboutArray objectAtIndex:indexPath.row];
		cell.textLabel.text = [NSString stringWithFormat:@"%@",aboutText];
	}
	return cell;
}
@end
