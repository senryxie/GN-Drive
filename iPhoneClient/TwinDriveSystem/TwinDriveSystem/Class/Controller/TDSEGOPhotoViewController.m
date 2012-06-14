//
//  TDSEGOPhotoViewController.m
//  TwinDriveSystem
//
//  Created by 自 己 on 12-4-9.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSEGOPhotoViewController.h"
#import "TDSPhotoDataSource.h"

@interface TDSEGOPhotoViewController ()

@end

@implementation TDSEGOPhotoViewController


- (TDSPhotoDataSource *)photoSource{
    return (TDSPhotoDataSource*)_photoSource;
}

#pragma mark - Super Method
- (void)dealloc{
    [super dealloc];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
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
    }
    return self;
}
- (id)initWithPhoto:(id<EGOPhoto>)aPhoto{
    self = [super initWithPhoto:aPhoto];
    if (self) {
    }
    return self;
}

- (id)initWithImage:(UIImage*)anImage{
    self = [super initWithImage:anImage];
    if (self) {

    }
    return self;
}
- (id)initWithImageURL:(NSURL*)anImageURL{
    self = [super initWithImageURL:anImageURL];
    if (self) {
    }
    return self;
}

- (id)initWithPhotoSource:(id <EGOPhotoSource>)aPhotoSource{
    self = [super initWithPhotoSource:aPhotoSource];
    if (self) {

    }
    return self;
}
- (id)initWithPopoverController:(id)aPopoverController photoSource:(id <EGOPhotoSource>)aPhotoSource{
    self = [super initWithPopoverController:aPopoverController photoSource:aPhotoSource];
    if (self) {
    }
    return self;
}


- (NSInteger)currentPhotoIndex{
    return [super currentPhotoIndex];
}
- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated{
    [super moveToPhotoAtIndex:index animated:animated];
}

// 
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
	
    CGSize contentSize = self.view.bounds.size;
	contentSize.width = (contentSize.width * [self.photoSource numberOfPhotos]);
	
	if (!CGSizeEqualToSize(contentSize, self.scrollView.contentSize)) {
		self.scrollView.contentSize = contentSize;
	}
	
	_captionView.frame = CGRectMake(0.0f, self.view.bounds.size.height, self.view.bounds.size.width, 80.0f);
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setBarsHidden:YES animated:YES];
    [super scrollViewDidScroll:scrollView];
}
@end
