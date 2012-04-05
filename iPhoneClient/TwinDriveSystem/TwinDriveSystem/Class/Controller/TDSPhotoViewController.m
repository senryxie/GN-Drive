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
#define MAC_COUNT_LIMIT 200
#define COLLECT_BUTTON_FRAME CGRectMake(260, 10, 40, 40)

@interface TDSPhotoViewController(Private)
- (void)photosLoadMore:(BOOL)more inPage:(NSInteger)page;
- (void)updatePhotosByResponseDic:(NSDictionary *)responseDic;

- (void)showError:(BOOL)value;
- (void)showExtremity:(BOOL)value;
- (void)showNoPrevious:(BOOL)value;
- (void)showNoNext:(BOOL)value;
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
    [_collectButton release];
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
        
        _isExtremity = NO;
        
        _isNoPrevious = NO;
        
        _isNoNext = NO;
        
        _isError = NO;
        
        _collectButton = [[UIButton alloc] initWithFrame:COLLECT_BUTTON_FRAME];
        _collectButton.backgroundColor = [UIColor redColor];
        _collectButton.alpha = .7f;
        [_collectButton setImage:[UIImage imageNamed:@"heart.png"]
                        forState:UIControlStateNormal];
        [_collectButton addTarget:self
                           action:@selector(collectAction:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_collectButton];
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
#pragma mark - Public Function
- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated {
    [super moveToPhotoAtIndex:index animated:animated];
    
    TDSLOG_info(@"allCount:%d:%d    moveIndex:%d  ",[self.photoViews count],[self.photoSource numberOfPhotos],index);
    
    // TODO:<前提有网>
    BOOL haveNet = YES;
    if (!haveNet) {
        [self showError:YES];
        return;
    }
    
    // 超过一天能看的总数了
    if ([self.photoViews count] >= MAC_COUNT_LIMIT) {
        _isExtremity = YES;
    }
    // 到起点了
    if (index == 0 && 0 == (_startPage-_requestPrePageCount)){
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
        if (_isExtremity && index == [self.photoSource numberOfPhotos]-1) {
            [self showExtremity:YES];
        }else if(_isNoNext && index == [self.photoSource numberOfPhotos]-1){
            [self showNoNext:YES];
        }else {
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
	} 
    
    _recordPageSection = (NSInteger)ceilf(index/ONCE_REQUEST_COUNT_LIMIT)+_startPage-_requestPrePageCount;
    _recordPageIndex = index%ONCE_REQUEST_COUNT_LIMIT ;
    
    TDSLOG_info(@"@@@ %.0f+%d == %d[now move index]",ceilf(index/ONCE_REQUEST_COUNT_LIMIT)*ONCE_REQUEST_COUNT_LIMIT,_recordPageIndex,index);        
    TDSLOG_info(@"record<%d,%d>,startPage:%d,next:%d,pre:%d",_recordPageSection,_recordPageIndex,_startPage,_requestNextPageCount,_requestPrePageCount);
    
}
#pragma mark - Super Function
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated{
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) return; 
    
    NSLog(@" $$$$ inTDS setStatusBarHidden:%d",hidden);
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
		
	} else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30200
		[[UIApplication sharedApplication] setStatusBarHidden:hidden animated:animated];
#endif
	}
    
}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated{
    if (hidden&&_barsHidden) return;
    NSLog(@" $$$$ inTDS setBarsHidden:%d",hidden);
	_collectButton.hidden = hidden;// my added
    
	if (_popover && [self.photoSource numberOfPhotos] == 0) {
		[_captionView setCaptionHidden:hidden];
		return;
	}
    
	[self setStatusBarHidden:hidden animated:animated];
	
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

#pragma mark - Notification Action
- (void)saveReadedPhotoInfo{
    [TDSDataPersistenceAssistant saveReadedPhotoIndexPath:[NSIndexPath indexPathForRow:_recordPageIndex 
                                                                             inSection:_recordPageSection]];
    
}

#pragma mark - Private Function

- (void)collectAction:(id)sender{
    TDSPhotoView *photoView = (TDSPhotoView*)[[self photoSource] objectAtIndex:_pageIndex];
    TDSConfig *config = [TDSConfig getInstance];
    NSString *collectRequestUrl = [NSString stringWithFormat:@"%@/v/%@/snap/%@",config.mApiUrl,config.version,photoView.item.pid];
    NSMutableArray *savedCollectPhotoUrls = [NSMutableArray arrayWithArray:[TDSDataPersistenceAssistant getCollectPhotos]];
    [savedCollectPhotoUrls addObject:collectRequestUrl];
    [TDSDataPersistenceAssistant saveCollectPhotos:savedCollectPhotoUrls];
    TDSLOG_info(@"====================");
    TDSLOG_info(@"savedCollectUrls:%@",savedCollectPhotoUrls);    
    TDSLOG_info(@"====================");    
    [[TDSHudView getInstance] showHudOnView:self.view
                                    caption:[NSString stringWithFormat:@"[%@]收藏成功!",photoView.item.pid]
                                      image:nil
                                  acitivity:NO
                               autoHideTime:1.0f];
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
            
            
            ////// dirty code
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
        _isNoNext = YES;
        // TODO:没有更多照片了
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:[NSString stringWithFormat:@"没有了@%d",(_startPage+_requestNextPageCount)]
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.0f];
    }
}
- (void)showError:(BOOL)value{
    if (value) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"<error>\n一定是打开的方式有问题"
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.0f];        
    }
}
- (void)showExtremity:(BOOL)value{
    if (value) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"轻撸！流量受不了了"
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.0f];
    }
}
- (void)showNoPrevious:(BOOL)value{
    if (value) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"page == 0"
                                          image:nil
                                      acitivity:NO
                                   autoHideTime:1.0f];        
    } 
}
- (void)showNoNext:(BOOL)value{
    if (value) {
        [[TDSHudView getInstance] showHudOnView:self.view
                                        caption:@"服务器表示没有下一页了"
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
