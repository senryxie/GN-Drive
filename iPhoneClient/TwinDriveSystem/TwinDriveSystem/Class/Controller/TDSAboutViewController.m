//
//  TDSAboutViewController.m
//  TwinDriveSystem
//
//  Created by 自 己 on 12-3-29.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSAboutViewController.h"
#import "TDSFeedBackViewController.h"

#define _FEEDBACK_SECTION 1

@implementation TDSAboutViewController
@synthesize tableView = _tableView;


#pragma mark -
#pragma mark View lifecycle
- (id)init {
	if ((self = [super init])) {
        
        _sectionHeaders = [[NSArray alloc] initWithObjects:@"新浪微博", @"意见反馈", @"关于", nil];
		_sectionFooters = [[NSArray alloc] initWithObjects:@"", @"", @"©IcePhone Studio 2012", nil];
        
		NSArray *section0 = [NSArray arrayWithObjects:@"登录用户", nil];
		NSArray *section1 = [NSArray arrayWithObjects:@"欢迎大家积极反馈", nil];
		NSArray *section2 = [NSArray arrayWithObjects:@"当前版本", @"联系方式", nil];
        _cellCaptions = [[NSArray alloc] initWithObjects:section0, section1, section2, nil];
		
		NSArray *label0 = [NSArray arrayWithObjects:@"悬崖乐马", nil];
		NSArray *label1 = [NSArray arrayWithObjects:@"", nil];
		NSArray *label2 = [NSArray arrayWithObjects:@"1.0", @"jiepaikong@gmail.com", nil];
        _cellInfosLabels = [[NSArray alloc] initWithObjects:label0, label1, label2, nil];
	}
	return self;
}

- (void)dealloc{
    [_sectionHeaders release];
    [_sectionFooters release];
    [_cellCaptions release];
    [_cellInfosLabels release];
    self.tableView = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        TDSFeedBackViewController *feedbackViewController = [[TDSFeedBackViewController alloc] init];
        feedbackViewController.view.frame = self.view.bounds;
        feedbackViewController.navigationItem.title = @"意见反馈";
        [self.navigationController pushViewController:feedbackViewController animated:YES];
        [feedbackViewController release];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionHeaders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_sectionHeaders objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [_sectionFooters objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int sec[3] = {1,1,2};
    return sec[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:nil] autorelease];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;		
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:17.0];
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    cell.textLabel.text = [[_cellCaptions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.font = cell.textLabel.font;
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.font =  [UIFont fontWithName:@"Arial" size:17.0];
    [cell.contentView addSubview:infoLabel];
    infoLabel.text = [[_cellInfosLabels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    //滑动到意见反馈页
    if (indexPath.section == _FEEDBACK_SECTION) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CGSize labelSize = [infoLabel.text sizeWithFont:infoLabel.font
                                  constrainedToSize:CGSizeMake(cell.contentView.frame.size.width,
                                                               cell.contentView.frame.size.height)
                                      lineBreakMode:UILineBreakModeWordWrap];
    infoLabel.frame = CGRectMake(CGRectGetMaxX(cell.contentView.frame) - labelSize.width - 30, 
                                 11.0, 
                                 labelSize.width, 
                                 labelSize.height);
    [infoLabel release];
	
	return cell;
}
@end
