//
//  TDSPhotoViewController.m
//  TwinDriveSystem
//
//  Created by 钟 声 on 12-2-12.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSPhotoViewController.h"
#import "TDSPhotoView.h"
#import "TDSPhotoDataSource.h"
#import "TDSRequestObject.h"
#import "TDSPhotoViewItem.h"

#define ONCE_REQUEST_COUNT_LIMIT 5
#define MAC_COUNT_LIMIT 20

@interface TDSPhotoViewController(Private)
- (void)photosLoadMore:(BOOL)more inPage:(NSInteger)page;
- (void)updatePhotosByResponseDic:(NSDictionary *)responseDic;
@end

@interface TDSPhotoViewController(Super)
- (void)setupScrollViewContentSize;
- (void)loadScrollViewWithPage:(NSInteger)page;
@end

@implementation TDSPhotoViewController
@synthesize photoViewNetControlCenter = _photoViewNetControlCenter;

#pragma mark - 
- (void)dealloc{
    self.photoViewNetControlCenter = nil;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:@"EGOPhotoViewToggleBars" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoViewDidFinishLoading:) name:@"EGOPhotoDidFinishLoading" object:nil];
		
		self.hidesBottomBarWhenPushed = YES;
		self.wantsFullScreenLayout = YES;		
		_photoSource = [[TDSPhotoDataSource alloc] init];
		_pageIndex = 0;
        
        //====================================================================================================
        // 应用失去焦点时存下当前浏览到哪一页
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(saveReadedPhotoInfo)
                                                     name:UIApplicationWillResignActiveNotification
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
        
        _noMore = NO;
    }
    return self;
}
- (TDSPhotoDataSource *)photoSource{
    return (TDSPhotoDataSource*)_photoSource;
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Super Function

- (void)loadScrollViewWithPage:(NSInteger)page {
	
    if (page < 0) return;
    if (page >= [self.photoSource numberOfPhotos]) return;
	
	EGOPhotoImageView * photoView = [self.photoViews objectAtIndex:page];
	if ((NSNull*)photoView == [NSNull null]) {
		
		photoView = [self dequeuePhotoView];
		if (photoView != nil) {
			[self.photoViews exchangeObjectAtIndex:photoView.tag withObjectAtIndex:page];
			photoView = [self.photoViews objectAtIndex:page];
		}
		
	}
	
	if (photoView == nil || (NSNull*)photoView == [NSNull null]) {
		
		photoView = [[EGOPhotoImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
		[self.photoViews replaceObjectAtIndex:page withObject:photoView];
		[photoView release];
		
	} 
	
	[photoView setPhoto:[self.photoSource photoAtIndex:page]];
	
    if (photoView.superview == nil) {
		[self.scrollView addSubview:photoView];
	}
	
	CGRect frame = self.scrollView.frame;
	NSInteger centerPageIndex = _pageIndex;
	CGFloat xOrigin = (frame.size.width * page);
	if (page > centerPageIndex) {
		xOrigin = (frame.size.width * page) + EGOPV_IMAGE_GAP;
	} else if (page < centerPageIndex) {
		xOrigin = (frame.size.width * page) - EGOPV_IMAGE_GAP;
	}
	
	frame.origin.x = xOrigin;
	frame.origin.y = 0;
	photoView.frame = frame;
}

- (void)setupScrollViewContentSize{
	
	CGFloat toolbarSize = _popover ? 0.0f : self.navigationController.toolbar.frame.size.height;	
	
	CGSize contentSize = self.view.bounds.size;
	contentSize.width = (contentSize.width * [self.photoSource numberOfPhotos]);
	
	if (!CGSizeEqualToSize(contentSize, self.scrollView.contentSize)) {
		self.scrollView.contentSize = contentSize;
	}
	
	_captionView.frame = CGRectMake(0.0f, self.view.bounds.size.height - (toolbarSize + 40.0f), self.view.bounds.size.width, 40.0f);
    
}

- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated {
    [super moveToPhotoAtIndex:index animated:animated];
    
    TDSLOG_info(@"allCount:%d:%d    moveIndex:%d  ",[self.photoViews count],[self.photoSource numberOfPhotos],index);
    
    // TODO:<前提有网>
    BOOL haveNet = YES;
    if (!haveNet) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"似乎没网了"
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.0f];
        return;
    }

    // 超过一天能看的总数了
    if(index == [self.photoViews count]-1 && [self.photoViews count] >= MAC_COUNT_LIMIT){
        _noMore = YES;
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"轻撸！流量受不了了"
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.0f];
    }
    // 到起点了
    else if (index == 0 && 0 == (_startPage-_requestPrePageCount)) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"page == 0"
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.0f];    
    }
    
    // 无限前滚逻辑
    // 在浏览到第一张照片的时候添加loadingView和请求
    if (!_noMore && index == 0 && _startPage-_requestPrePageCount > 0) 
    {
        NSLog(@" ### now index = 0");
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
    // 无限后滚逻辑
    // 在最后2个内的时候重新请求
	else if (!_noMore && index + 1 >= [self.photoSource numberOfPhotos]-1) {
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

    _recordPageSection = (NSInteger)ceilf(index/ONCE_REQUEST_COUNT_LIMIT)+_startPage-_requestPrePageCount;
    _recordPageIndex = index%ONCE_REQUEST_COUNT_LIMIT ;
    
    TDSLOG_info(@"@@@ %.0f+%d == %d[now move index]",ceilf(index/ONCE_REQUEST_COUNT_LIMIT)*ONCE_REQUEST_COUNT_LIMIT,_recordPageIndex,index);        
    TDSLOG_info(@"record<%d,%d>,startPage:%d,next:%d,pre:%d",_recordPageSection,_recordPageIndex,_startPage,_requestNextPageCount,_requestPrePageCount);
    
}
#pragma mark - Notification Action
- (void)saveReadedPhotoInfo{
    [TDSDataPersistenceAssistant saveReadedPhotoIndexPath:[NSIndexPath indexPathForRow:_recordPageIndex 
                                                                             inSection:_recordPageSection]];
    
}
#pragma mark - Private Function
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

- (void)updatePhotosByResponseDic:(NSDictionary *)responseDic{
    BOOL more = [[responseDic objectForKey:@"more"]  boolValue];
    NSArray *pics = nil;
    if (more) {
        pics = [responseDic objectForKey:@"pics"];
        if ([pics isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *photoArray = [NSMutableArray arrayWithCapacity:[(NSArray*)pics count]];
            NSNumber *nowId = nil;
            for (NSDictionary *infoDic in (NSArray*)pics) {
                TDSPhotoViewItem *photoItem = [TDSPhotoViewItem objectWithDictionary:infoDic];
                TDSPhotoView *photoView = [TDSPhotoView photoWithItem:photoItem];
                [photoArray addObject:photoView];
                nowId = [infoDic objectForKey:@"id"];
            }
            /////
            int requestPage = ([nowId intValue]/ONCE_REQUEST_COUNT_LIMIT)-1;
            // 获取到图片后重置loadingPhoto为有效Photo
            NSRange range ;
            
            if (requestPage<_startPage+_requestNextPageCount) {// 插前面
                range.location = 0;
            }else {// 插后面
                range.location = (_requestNextPageCount+_requestPrePageCount)*ONCE_REQUEST_COUNT_LIMIT;
            }
            range.length = ONCE_REQUEST_COUNT_LIMIT;
            NSLog(@" ### range:(%d,%d)",range.location,range.length);
            [[self photoSource] updatePhotos:photoArray inRange:range];
            ///////
            
            
            // 如果当前页面得到数据了，则刷新下显示
            if (_pageIndex>=range.location && _pageIndex<=(range.location+range.length)) {
                [self loadScrollViewWithPage:_pageIndex-1];                        
                [self loadScrollViewWithPage:_pageIndex];            
                [self loadScrollViewWithPage:_pageIndex+1];            
            }
        }
    }else {
        _noMore = YES;
        // TODO:没有更多照片了
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:[NSString stringWithFormat:@"没有了@%d",(_startPage+_requestNextPageCount)]
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.0f];
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
            [self updatePhotosByResponseDic:responseDic];
        }
    }
}

- (void)tdsNetControlCenter:(TDSNetControlCenter*)netControlCenter requestDidFailedLoad:(id)response{
    if ([response isKindOfClass:[TDSRequestObject class]]) {
        TDSRequestObject *responseObject = (TDSRequestObject *)response;        
        TDSLOG_info(@"---->get response with error:%@",responseObject.error);    
    }
}

@end
