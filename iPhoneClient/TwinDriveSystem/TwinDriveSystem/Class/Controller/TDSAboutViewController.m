//
//  TDSAboutViewController.m
//  TwinDriveSystem
//
//  Created by 自 己 on 12-3-29.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSAboutViewController.h"
#import "TDSFeedBackViewController.h"

#define _FEEDBACK_INDEX 2

@implementation TDSAboutViewController
@synthesize tableView = _tableView;


#pragma mark -
#pragma mark View lifecycle
- (id)init {
	if ((self = [super init])) {

        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;    
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self.view addSubview:_tableView];
        
        _feedbackViewController = [[TDSFeedBackViewController alloc] init];
        _feedbackViewController.navigationItem.title = @"意见反馈";

        
		NSArray *section1 = [NSArray arrayWithObjects:@"当前版本", @"联系方式",@"欢迎大家积极反馈", nil];
        _cellCaptions = [[NSArray alloc] initWithObjects:section1,  nil];
		
		NSArray *label1 = [NSArray arrayWithObjects:@"1.0", @"jiepaikong@gmail.com",@"", nil];
        _cellInfosLabels = [[NSArray alloc] initWithObjects:label1,  nil];
	}
	return self;
}

- (void)dealloc{
    [_sectionHeaders release];
    [_sectionFooters release];
    [_cellCaptions release];
    [_cellInfosLabels release];
    [_feedbackViewController release];
    self.tableView = nil;
    [super dealloc];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _feedbackViewController.view.frame = self.view.bounds;
}
- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.navigationItem.title = @"关于";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == _FEEDBACK_INDEX){        
        [self.navigationController pushViewController:_feedbackViewController 
                                             animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"©IcePhone Studio 2012";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
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
    if (indexPath.row == _FEEDBACK_INDEX) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
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
