//
//  TDSFeedBackViewController.m
//  TwinDriveSystem
//
//  Created by 自 己 on 12-6-4.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSFeedBackViewController.h"
#import "TDSRequestObject.h"

@interface TDSFeedBackViewController ()

@end

@implementation TDSFeedBackViewController

- (void)dealloc{
    [_textView release];
    [_netWorkHelper release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"意见反馈";
    if (!self.navigationItem.rightBarButtonItem) {
        UIBarButtonItem *sendBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" 
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(sendAction:)];
        self.navigationItem.rightBarButtonItem = sendBtnItem;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [sendBtnItem release];
    }
    
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    }

    _textView.font = [UIFont systemFontOfSize:16.0f];
    _textView.delegate = self;
    [self.view addSubview:_textView];
    [_textView becomeFirstResponder];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    if (!_textView) {
        [_textView release];
    }
    self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _textView.text = @"";
}
#pragma mark - private
- (void)sendAction:(id)sender{
    TDSConfig *config = [TDSConfig getInstance];
    NSString *requestString = [NSMutableString stringWithFormat:@"%@/v/%@/user/%@/feedback/",
                               config.mApiUrl,
                               config.version,
                               config.udid];
    NSURL *requestURL = [NSURL URLWithString:requestString];
    TDSRequestObject *requestObject = [TDSRequestObject requestWithURL:requestURL 
                                                           andUserInfo:nil];

    requestObject.postBody = [NSMutableDictionary dictionaryWithDictionary:
                              [NSDictionary dictionaryWithObject:_textView.text
                                                          forKey:@"feedback"]];
    
    _netWorkHelper = [[TDSNetControlCenter alloc] init];
    _netWorkHelper.delegate = self;
    [_netWorkHelper sendRequestWithObject:requestObject];
    
}
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSString *resultString = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (resultString.length>0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}
#pragma mark - TDSNetControlCenterDelegate
- (void)tdsNetControlCenter:(TDSNetControlCenter*)netControlCenter requestDidStartRequest:(id)response{
    
}
- (void)tdsNetControlCenter:(TDSNetControlCenter*)netControlCenter requestDidFinishedLoad:(id)response{
    TDSRequestObject *requestObject = (TDSRequestObject *)response;
    NSMutableDictionary *responseDic = requestObject.rootObject;
    NSString *message = @"已发送";
    NSNumber *statusCode = [responseDic objectForKey:@"r"];
    if ([statusCode.stringValue isEqualToString:@"0"]) {
        message = @"发送成功";
    }else {
        message = [NSString stringWithFormat:@"<status code:%@>\n请重新发送",statusCode];
    }
    [[TDSHudView getInstance] showHudOnView:self.parentViewController.view
                                    caption:message
                                      image:nil
                                  acitivity:NO
                               autoHideTime:1.5f];
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"success response:%@",requestObject.responseString);
}
- (void)tdsNetControlCenter:(TDSNetControlCenter*)netControlCenter requestDidFailedLoad:(id)response{
    TDSRequestObject *requestObject = (TDSRequestObject *)response;
    NSLog(@"failed response:%@",requestObject.responseString);
    [[TDSHudView getInstance] showHudOnView:self.parentViewController.view
                                    caption:@"发送失败"
                                      image:nil
                                  acitivity:NO
                               autoHideTime:1.5f];
}


@end
