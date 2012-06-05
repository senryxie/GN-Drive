//
//  TDSCollectPhotoViewController.m
//  TwinDriveSystem
//
//  Created by 自 己 on 12-4-9.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSCollectPhotoViewController.h"
#import "TDSPhotoDataSource.h"
#import "TDSDataPersistenceAssistant.h"
#import "TDSPhotoView.h"
#import "TDSPhotoViewItem.h"

@interface TDSCollectPhotoViewController (Private)

@end

@implementation TDSCollectPhotoViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TDSRecordPhotoNotification
                                                  object:nil];
    [_collectButton release];
    [super dealloc];
}
- (id)initWithImage:(UIImage*)anImage{
    NSDictionary *collectPhotos = [TDSDataPersistenceAssistant getCollectPhotos];
    NSMutableArray *photoViews = [NSMutableArray arrayWithCapacity:collectPhotos.count];
    if ([collectPhotos.allKeys count] > 0) {
        for (TDSPhotoViewItem *photoViewItem in collectPhotos.allValues) {
            TDSPhotoView *photoView = [TDSPhotoView photoWithItem:photoViewItem];
            [photoViews addObject:photoView];
        }        
    }else {
        TDSPhotoView *photoView = [[TDSPhotoView alloc] initWithImageURL:nil
                                                                    name:@"可以点击红心收藏街拍图片"
                                                                   image:anImage];
        [photoViews addObject:photoView];
        [photoView release];        
    }
    self = [super initWithPhotoSource:[[TDSPhotoDataSource alloc] initWithPhotos:photoViews]];
    if (self) {
        _collectButton = [[UIButton alloc] initWithFrame:COLLECT_BUTTON_FRAME];
        _collectButton.backgroundColor = [UIColor clearColor];
        _collectButton.alpha = .7f;
        _collectButton.hidden = YES;
        [_collectButton setImage:[UIImage imageNamed:@"likeIconGray.png"]
                        forState:UIControlStateNormal];
        [_collectButton addTarget:self
                           action:@selector(collectAction:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_collectButton];
    }
    return self;
    
}
#pragma mark - Public Function
- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated {
    [super moveToPhotoAtIndex:index animated:animated];
}
- (void)updatePhotoSourceNotication:(NSNotification*)notication{

    NSDictionary *collectPhotos = [TDSDataPersistenceAssistant getCollectPhotos];
    NSRange range;    
    if ([collectPhotos.allKeys count] > 0) {
        NSMutableArray *photoViews = [NSMutableArray arrayWithCapacity:collectPhotos.count];
        for (TDSPhotoViewItem *photoViewItem in collectPhotos.allValues) {
            TDSPhotoView *photoView = [TDSPhotoView photoWithItem:photoViewItem];
            [photoViews addObject:photoView];
        }
        
        range.location = 0;
        range.length = collectPhotos.count;
        [[self photoSource] updatePhotos:photoViews inRange:range];
        if (range.length < [_photoSource numberOfPhotos]) {
            if (_pageIndex > range.length) {
                [self moveToPhotoAtIndex:range.length-1 animated:NO]; 
            }
            range.location = collectPhotos.count;
            range.length = [_photoSource numberOfPhotos] - collectPhotos.count;
            [[self photoSource] removePhotosInRange:range];    
        }
        for (unsigned i = self.photoViews.count; i < collectPhotos.count; i++) {
            [self.photoViews addObject:[NSNull null]];
        }
    }else if(self.photoViews.count > 0){

//        range.location = 1;
//        range.length = [_photoSource numberOfPhotos];
//        [[self photoSource] removePhotosInRange:range];
//        [self.photoViews removeAllObjects];
//        [self.photoViews addObject:[NSNull null]];
//        range.location = 0;
//        range.length = 1;
//        TDSPhotoView *photoView = [[TDSPhotoView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
//        [[self photoSource] insertPhotos:[NSArray arrayWithObject:photoView] inRange:range];
//        
//        [self moveToPhotoAtIndex:0 animated:NO]; 
    }
    
    [self setupScrollViewContentSize];
    
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
    [[TDSHudView getInstance] showHudOnView:self.view
                                    caption:message
                                      image:nil
                                  acitivity:NO
                               autoHideTime:1.0f];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setBarsHidden:YES animated:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePhotoSourceNotication:) 
                                                 name:TDSRecordPhotoNotification 
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
