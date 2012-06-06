//
//  TDSPhotoViewController.m
//  TwinDriveSystem
//
//  Created by 钟 声 on 12-2-12.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSPhotoViewController.h"
#import "TDSPhotoView.h"
#import "TDSPhotoViewItem.h"
#import "TDSPhotoDataSource.h"
#import "TDSRequestObject.h"


#define ONCE_REQUEST_COUNT_LIMIT 5
#define MAC_COUNT_LIMIT 200


@interface TDSPhotoViewController(Private)
- (void)photosLoadMore:(BOOL)more inPage:(NSInteger)page;
- (void)updatePhotosByResponseDic:(NSDictionary *)responseDic andPage:(NSInteger)page;

- (void)showError:(BOOL)value;
- (void)showExtremity:(BOOL)value;
- (void)showNoPrevious:(BOOL)value;
- (void)showNoNext:(BOOL)value;
@end

@implementation TDSPhotoViewController
@synthesize photoViewNetControlCenter = _photoViewNetControlCenter;

#pragma mark - 
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.photoViewNetControlCenter = nil;
    [_collectButton release];
    [_retryRequestPageDic release];    
    [super dealloc];
}

#pragma mark - debug
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)init{
    self = [super init];
    if (self) {
        //====================================================================================================
        // 应用失去焦点时存下当前浏览到哪一页
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(saveReadedPhotoInfo)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        // 网络状态变化
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(netWorkStatuesChanged:) 
                                                     name:TDSNetStatueChangedNotication 
                                                   object:nil];

        
        
        _requestNextPageCount = 0;
        _requestPrePageCount = 0;

        // 初始化载入Loading图
        [[self photoSource] addLoadingPhotosOfCount:ONCE_REQUEST_COUNT_LIMIT];
        
        NSIndexPath *startIndexPath = [TDSDataPersistenceAssistant getReadedPhotoIndexPath];
        _recordPageSection = startIndexPath.section;
        _recordPageIndex = startIndexPath.row;
        NSLog(@" recordPage<%d,%d>",_recordPageSection,_recordPageIndex);

        _pageIndex = _recordPageIndex; // 重置了下初始index,EGO自带处理，真好
        
        _startPage = _recordPageSection;
        
        _firstLoad = YES;
        
        _isExtremity = NO;
        
        _isNoPrevious = NO;
        
        _isNoNext = NO;
        
        _isError = NO;
        
        _haveNet = NO;
        
        _collectButton = [[UIButton alloc] initWithFrame:COLLECT_BUTTON_FRAME];
        _collectButton.backgroundColor = [UIColor clearColor];
        _collectButton.alpha = .7f;
        [_collectButton setImage:[UIImage imageNamed:@"likeIcon.png"]
                        forState:UIControlStateNormal];
        [_collectButton addTarget:self
                           action:@selector(collectAction:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_collectButton];
        
        
        _retryRequestPageDic = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    // 启动获得初始页面
    // TODO:获取缓存页数，下面每次都请求了个最新页数
    if (_recordPageSection>0 || _recordPageIndex>0) {
        [self photosLoadMore:YES inPage:_recordPageSection];
    }else {
        [self photosLoadMore:NO inPage:0];
    }
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setBarsHidden:YES animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Public Function
- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated {
    // TODO:<前提有网>
    if (!_haveNet) {
        return;
    }
    
    [super moveToPhotoAtIndex:index animated:animated];
    
    TDSLOG_info(@"allCount:%d:%d    moveIndex:%d  ",[self.photoViews count],[self.photoSource numberOfPhotos],index);
    
    // 超过一天能看的总数了
    if ([self.photoViews count] >= MAC_COUNT_LIMIT) {
        _isExtremity = YES;
    }
    // 到起点了
    if ( index == 0 && 0 == (_startPage-_requestPrePageCount)){
        _isNoPrevious = YES;
    }

    
    // 无限前滚逻辑
    // 在浏览到第一张照片的时候添加loadingView和请求
    if (index == 0 && _startPage-_requestPrePageCount > 0) 
    {
        NSLog(@" ### now index = 0");
        if (_isExtremity) {
            [self showExtremity:YES];
        }else if(_isNoPrevious){
            [self showNoPrevious:YES];
        }else {
            TDSLOG_info(@"previous===================================");
            ++_requestPrePageCount;
            [[self photoSource] addLoadingPhotosOfCount:ONCE_REQUEST_COUNT_LIMIT atIndex:0];
            NSRange range;
            range.location = 0;
            range.length = ONCE_REQUEST_COUNT_LIMIT;
            for (unsigned i = 0; i < ONCE_REQUEST_COUNT_LIMIT; i++) {
                [self.photoViews insertObject:[NSNull null] atIndex:0];
            }
            [self setupScrollViewContentSize];
            [self moveToPhotoAtIndex:ONCE_REQUEST_COUNT_LIMIT animated:NO];
            // send request
            [self photosLoadMore:YES inPage:(_startPage-_requestPrePageCount)];
            return;    
        }
    }
    // 无限后滚逻辑
    // 在最后2个内的时候重新请求
	else if (index + 1 >= [self.photoSource numberOfPhotos]-1) {
        if (_isExtremity) {
            if (index == [self.photoSource numberOfPhotos]-1) {
                [self showExtremity:YES];                
            }
        }else if(_isNoNext){
            if (index == [self.photoSource numberOfPhotos]-1) {
                [self showNoNext:YES];
            }
        }
        else{
            @synchronized(self){
                TDSLOG_info(@"next===================================");
                // load photoSource first
                [[self photoSource] addLoadingPhotosOfCount:ONCE_REQUEST_COUNT_LIMIT];
                for (unsigned i = 0; i < ONCE_REQUEST_COUNT_LIMIT; i++) {
                    [self.photoViews addObject:[NSNull null]];
                }
                [self setupScrollViewContentSize];
                // send request
                ++_requestNextPageCount;
                [self photosLoadMore:YES inPage:(_startPage+_requestNextPageCount)];
            }   
        }            
	}// TODO:需要重试的page _retryRequestPageDic <pageNum,boolOfRetry>
    
    _recordPageSection = (NSInteger)ceilf(index/ONCE_REQUEST_COUNT_LIMIT)+_startPage-_requestPrePageCount;
    _recordPageIndex = index%ONCE_REQUEST_COUNT_LIMIT ;
    
    if (_retryRequestPageDic.count > 0
        && (_recordPageIndex == 0 || _recordPageIndex == ONCE_REQUEST_COUNT_LIMIT-1)) 
    {
        for (NSNumber *errorPage in _retryRequestPageDic.allKeys) 
        {
            if (errorPage.intValue == _recordPageSection 
                && [[_retryRequestPageDic objectForKey:errorPage] isEqual:@"1"]) 
            {
                [_retryRequestPageDic setObject:@"0" forKey:errorPage];
                [self photosLoadMore:YES inPage:errorPage.intValue];
            }
        }    
    }
    TDSLOG_info(@"@@@ %.0f+%d == %d[now move index]",ceilf(index/ONCE_REQUEST_COUNT_LIMIT)*ONCE_REQUEST_COUNT_LIMIT,_recordPageIndex,index);        
    TDSLOG_info(@"record<%d,%d>,startPage:%d,next:%d,pre:%d",_recordPageSection,_recordPageIndex,_startPage,_requestNextPageCount,_requestPrePageCount);
    
}
#pragma mark - Super Function
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated{
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) return; 
    
    NSLog(@" $$$$ inTDS setStatusBarHidden:%d",hidden);
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		
//		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
		
	} else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30200
//		[[UIApplication sharedApplication] setStatusBarHidden:hidden animated:animated];
#endif
	}
    
}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated{
    if (hidden&&_barsHidden) return;
    NSLog(@" $$$$ inTDS setBarsHidden:%d",hidden);
	_collectButton.hidden = hidden;// my added
    
    TDSPhotoView *photoView = (TDSPhotoView*)[[self photoSource] objectAtIndex:_pageIndex];
    if (photoView == nil) {
        return;
    }
    NSMutableDictionary *savedCollectPhotos = [NSMutableDictionary dictionaryWithDictionary:
                                               [TDSDataPersistenceAssistant getCollectPhotos]];
    if (![savedCollectPhotos.allKeys containsObject:photoView.item.pid]) {
        [_collectButton setImage:[UIImage imageNamed:@"likeIcon.png"]
                        forState:UIControlStateNormal];
    }else {
        [_collectButton setImage:[UIImage imageNamed:@"likeIconGray.png"] 
                        forState:UIControlStateNormal];
    }
            
	if (_popover && [self.photoSource numberOfPhotos] == 0) {
		[_captionView setCaptionHidden:hidden];
		return;
	}
    
//	[self setStatusBarHidden:hidden animated:animated];
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		if (!_popover) {
			
			if (animated) {
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.3f];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			}
			
			self.navigationController.navigationBar.alpha = hidden ? 0.0f : 1.0f;
			self.navigationController.toolbar.alpha = hidden ? 0.0f : 1.0f;
			
			if (animated) {
				[UIView commitAnimations];
			}
			
		} 
		
	} else {
		
		[self.navigationController setNavigationBarHidden:hidden animated:animated];
		[self.navigationController setToolbarHidden:hidden animated:animated];
		
	}
#else
	
	[self.navigationController setNavigationBarHidden:hidden animated:animated];
	[self.navigationController setToolbarHidden:hidden animated:animated];
	
#endif
	
	if (_captionView) {
		[_captionView setCaptionHidden:hidden];
	}
	
	_barsHidden=hidden;
}
- (EGOPhotoImageView*)dequeuePhotoView{
	
	NSInteger count = 0;
	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			if (view.superview == nil) {
				view.tag = count;
				return view;
			}
		}
		count ++;
	}	
	return nil;
	
}


#pragma mark - Notification Action
- (void)saveReadedPhotoInfo{
    [TDSDataPersistenceAssistant saveReadedPhotoIndexPath:[NSIndexPath indexPathForRow:_recordPageIndex 
                                                                             inSection:_recordPageSection]];
    
}

#pragma mark - Private Function

- (void)collectAction:(id)sender{
    TDSPhotoView *photoView = (TDSPhotoView*)[[self photoSource] objectAtIndex:_pageIndex];
    if (photoView == nil) {
        return;
    }
    NSMutableDictionary *savedCollectPhotos = [NSMutableDictionary dictionaryWithDictionary:[TDSDataPersistenceAssistant getCollectPhotos]];
    NSNumber *pid = photoView.item.pid;
    NSString *message = nil;
    if (![savedCollectPhotos.allKeys containsObject:pid]) {
        [savedCollectPhotos addEntriesFromDictionary:[NSDictionary dictionaryWithObject:photoView.item forKey:pid]];
        message = [NSString stringWithFormat:@"收藏成功!",photoView.item.pid];
        [_collectButton setImage:[UIImage imageNamed:@"likeIconGray.png"] 
                        forState:UIControlStateNormal];
    }else {
        [savedCollectPhotos removeObjectForKey:pid];
        message = [NSString stringWithFormat:@"取消收藏!",photoView.item.pid];
        [_collectButton setImage:[UIImage imageNamed:@"likeIcon.png"]
                        forState:UIControlStateNormal];

    }
    [TDSDataPersistenceAssistant saveCollectPhotos:savedCollectPhotos];
    [[NSNotificationCenter defaultCenter] postNotificationName:TDSRecordPhotoNotification 
                                                        object:nil];
    TDSLOG_info(@"====================");
    TDSLOG_info(@"savedCollectUrls:%@",[savedCollectPhotos allKeys]);    
    TDSLOG_info(@"====================");    
    if (message) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:message
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.0f];
    }
}

- (TDSNetControlCenter*)photoViewNetControlCenter{
    if (!_photoViewNetControlCenter) {
        _photoViewNetControlCenter = [[TDSNetControlCenter alloc] init];
        _photoViewNetControlCenter.delegate = self;
    }
    return _photoViewNetControlCenter;
}
- (void)photosLoadMore:(BOOL)more inPage:(NSInteger)page{
    if (page < 0) {
        return;
    }
    TDSConfig *config = [TDSConfig getInstance];
    NSDictionary *userInfo = nil;
    NSMutableString *requestString = [NSMutableString stringWithString:config.mApiUrl];
    if (more) {
        TDSLOG_info(@"---->send request with page:%d",page);
        [requestString appendFormat:@"/v/%@/snaps/%d/",config.version,page];
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:page] forKey:@"page"];        
    }else{
        [requestString appendFormat:@"/v/%@/user/%@/start_page/",config.version,config.udid];        
    }
    
    NSURL *requestURL = [NSURL URLWithString:requestString];
    TDSRequestObject *requestObject = [TDSRequestObject requestWithURL:requestURL 
                                                           andUserInfo:userInfo];
    [self.photoViewNetControlCenter sendRequestWithObject:requestObject];
    
}

- (void)updatePhotosByResponseDic:(NSDictionary *)responseDic andPage:(NSInteger)page{
    BOOL more = [[responseDic objectForKey:@"more"]  boolValue];
    NSArray *pics = [responseDic objectForKey:@"pics"];;
    if (!more) {
        _isNoNext = YES;
        // TODO:没有更多照片了
//        [[TDSHudView getInstance] showHudOnView:self.view
//                                        caption:[NSString stringWithFormat:@"没有了@%d",(_startPage+_requestNextPageCount)]
//                                          image:nil
//                                      acitivity:NO
//                                   autoHideTime:1.0f];
    }
    if (pics.count>0) {
        
        NSMutableArray *photoArray = [NSMutableArray arrayWithCapacity:[(NSArray*)pics count]];
        NSNumber *nowId = nil;
        for (NSDictionary *infoDic in (NSArray*)pics) {
            TDSPhotoViewItem *photoItem = [TDSPhotoViewItem objectWithDictionary:infoDic];
            TDSPhotoView *photoView = [TDSPhotoView photoWithItem:photoItem];
            [photoArray addObject:photoView];
            nowId = [infoDic objectForKey:@"id"];
        }
        
        ////// 更新对应页面的dataSource
        NSRange range ;
        range.location = (page - (_startPage-_requestPrePageCount))*ONCE_REQUEST_COUNT_LIMIT;
        range.length = photoArray.count;
        NSLog(@" ### range:(%d,%d)",range.location,range.length);
        [[self photoSource] updatePhotos:photoArray inRange:range];
        if (range.length < ONCE_REQUEST_COUNT_LIMIT) {
            range.location += range.length;
            range.length = ONCE_REQUEST_COUNT_LIMIT - range.length;
            [[self photoSource] removePhotosInRange:range];
            [self.photoViews removeObjectsInRange:range];
            [self setupScrollViewContentSize];
        }
        ///////
        
        // 则刷新下显示
        [self loadScrollViewWithPage:_pageIndex-1];                        
        [self loadScrollViewWithPage:_pageIndex];            
        [self loadScrollViewWithPage:_pageIndex+1];            
    }
}
- (void)netWorkStatuesChanged:(NSNotification *)notification{
    Reachability* curReach = [notification object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    if (status == kNotReachable) {
        _haveNet = NO;
    }else {
        _haveNet = YES;
        [self moveToPhotoAtIndex:_pageIndex animated:NO];
    }
}
- (void)showError:(BOOL)value{
    if (value) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"<error>\n一定是打开的方式有问题，请再试试吧！"
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.5f];        
    }
}
- (void)showExtremity:(BOOL)value{
    if (value) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"似乎看了太多图\n流量会受不了的"
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.5f];
    }
}
- (void)showNoPrevious:(BOOL)value{
    if (value) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"这边翻到头了\n每日更新在另一边"
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.5f];        
    } 
}
- (void)showNoNext:(BOOL)value{
    if (value) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"今日的街拍图\n已被您鉴赏完毕了"
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.5f];    
    }
}
#pragma mark - TDSNetControlCenterDelegate

- (void)tdsNetControlCenter:(TDSNetControlCenter*)netControlCenter requestDidStartRequest:(id)response{
//    TDSLOG_debug(@"start request" );    
}
- (void)tdsNetControlCenter:(TDSNetControlCenter*)netControlCenter requestDidFinishedLoad:(id)response{
    TDSLOG_debug(@"result :%@",response );
    if ([response isKindOfClass:[TDSRequestObject class]]) {
        TDSRequestObject *responseObject = (TDSRequestObject *)response;
        NSLog(@" %@",responseObject.rootObject);
        TDSLOG_info(@"---->get response with page:%@",[responseObject.userInfo objectForKey:@"page"]);
        if (![responseObject.rootObject isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *responseDic = responseObject.rootObject;
        NSString *actionString = [responseDic objectForKey:@"action"];
        if (actionString == nil || [actionString isEqualToString:@""]) {
            return;
        }
        // 获取当前版本
        if ([actionString isEqualToString:ResponseAction_Version]) {
            NSNumber *version = [responseDic objectForKey:@"version"];
            [TDSConfig getInstance].version = [version stringValue];
        }
        // 获取首页
        else if([actionString isEqualToString:ResponseAction_GetStartPage]){
            NSNumber *page = [responseDic objectForKey:@"page"];
            _startPage = [page intValue];
            // 获取到页码后重置下数据
            [self moveToPhotoAtIndex:0 animated:NO];
            [self photosLoadMore:YES inPage:_startPage];
        }
        // 单张照片
        else if([actionString isEqualToString:ResponseAction_SinglePhoto]){
            NSNumber *pId = [responseDic objectForKey:@"id"];
            NSString *caption = [responseDic objectForKey:@"text"];
            NSString *url = [responseDic objectForKey:@"url"];
            NSLog(@"###### get single photo[%@]:%@\n%@",pId,url,caption);                        
        }
        // 多张照片
        else if([actionString isEqualToString:ResponseAction_MultiPhoto]){
            NSNumber *pageNum = [responseObject.userInfo objectForKey:@"page"];
            [_retryRequestPageDic removeObjectForKey:pageNum];
            [self updatePhotosByResponseDic:responseDic andPage:pageNum.integerValue];
        }
    }
}

- (void)tdsNetControlCenter:(TDSNetControlCenter*)netControlCenter requestDidFailedLoad:(id)response{
    if ([response isKindOfClass:[TDSRequestObject class]]) {
        TDSRequestObject *responseObject = (TDSRequestObject *)response;        
        NSNumber *errorRequestPage = [responseObject.userInfo objectForKey:@"page"];
        TDSLOG_info(@"---->get response with error:%@ inpage:%@",
                    responseObject.error,
                    errorRequestPage);    
        if (errorRequestPage) {
            [_retryRequestPageDic addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"1" forKey:errorRequestPage]];            
        }
    }
}

@end
