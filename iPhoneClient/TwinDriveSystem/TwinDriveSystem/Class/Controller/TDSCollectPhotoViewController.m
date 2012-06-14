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
        _isEmpty = NO;
    }else {
        TDSPhotoView *photoView = [[TDSPhotoView alloc] initWithImageURL:nil
                                                                    name:@"可以点击红心收藏街拍图片"
                                                                   image:anImage];
        [photoViews addObject:photoView];
        [photoView release];        
        _isEmpty = YES;
    }
    self = [super initWithPhotoSource:[[TDSPhotoDataSource alloc] initWithPhotos:photoViews]];
    if (self) {
        _collectButton = [[UIButton alloc] initWithFrame:COLLECT_BUTTON_FRAME];
        _collectButton.backgroundColor = [UIColor clearColor];
        _collectButton.alpha = 0.0f;
        [_collectButton setImage:[UIImage imageNamed:@"likeIcon.png"]
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
    if (_isEmpty) {
        self.scrollView.userInteractionEnabled = NO;
    }else {
        self.scrollView.userInteractionEnabled = YES;
    }
}
- (void)updatePhotoSourceNotication:(NSNotification*)notication{
    NSRange range;   
    range.location = 0;
    range.length = [[self photoSource] numberOfPhotos];
    for (int index = 0; index < self.photoViews.count ; index++) {        
        if ([[self.photoViews objectAtIndex:index] isKindOfClass:[EGOPhotoImageView class]]) {
            EGOPhotoImageView *imageView = [self.photoViews objectAtIndex:index];
            [imageView removeFromSuperview];
        }

    }
    [self.photoViews removeAllObjects];
    [[self photoSource] removePhotosInRange:range];
    
    NSDictionary *collectPhotos = [TDSDataPersistenceAssistant getCollectPhotos];
    
    self.scrollView.userInteractionEnabled = YES;
    if ([collectPhotos.allKeys count] > 0) {
        _isEmpty = NO;
        NSMutableArray *photoViews = [NSMutableArray arrayWithCapacity:collectPhotos.count];
        for (TDSPhotoViewItem *photoViewItem in collectPhotos.allValues) {
            TDSPhotoView *photoView = [TDSPhotoView photoWithItem:photoViewItem];
            [photoViews addObject:photoView];
        }
        [[self photoSource] addPhotos:photoViews];
        
        for (unsigned i = 0.0f; i < collectPhotos.count; i++) {
            [self.photoViews addObject:[NSNull null]];
        }
        [self setupScrollViewContentSize];
    }
    else if([collectPhotos.allKeys count] <= 0)
    {
        _isEmpty = YES;
        [self.photoViews addObject:[NSNull null]];
        TDSPhotoView *photoView = [[TDSPhotoView alloc] initWithImageURL:nil 
                                                                    name:@"可以点击红心收藏街拍图片"
                                                                   image:[UIImage imageNamed:@"collect.png"]];
        [[self photoSource] addPhotos:[NSArray arrayWithObject:photoView]];
        [self setupScrollViewContentSize];
        self.scrollView.userInteractionEnabled = NO;
        
        [self moveToPhotoAtIndex:0 animated:NO]; 
        [self setBarsHidden:NO animated:NO];
    }
    

    
}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated{
    if (hidden&&_barsHidden) return;
    [super setBarsHidden:hidden animated:animated];
    NSLog(@" $$$$ inTDS setBarsHidden:%d",hidden);

    TDSPhotoView *photoView = (TDSPhotoView*)[[self photoSource] objectAtIndex:_pageIndex];
    if (photoView == nil) {
        return;
    }
    NSMutableDictionary *savedCollectPhotos = [NSMutableDictionary dictionaryWithDictionary:
                                               [TDSDataPersistenceAssistant getCollectPhotos]];
    if ([savedCollectPhotos.allKeys containsObject:photoView.item.pid]) {
        [_collectButton setImage:[UIImage imageNamed:@"likeIcon.png"] 
                        forState:UIControlStateNormal];
    }
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2f];        
    }
    if (_isEmpty) {    
        _collectButton.alpha = 0.0f;
    }else{        
        _collectButton.alpha = !hidden;                             
    }
    if (animated) {
        [UIView commitAnimations];
    }

}

- (void)collectAction:(id)sender{
    TDSPhotoView *photoView = (TDSPhotoView*)[[self photoSource] objectAtIndex:_pageIndex];
    if (photoView == nil) {
        return;
    }
    NSMutableDictionary *savedCollectPhotos = [NSMutableDictionary dictionaryWithDictionary:[TDSDataPersistenceAssistant getCollectPhotos]];
    NSNumber *pid = photoView.item.pid;
    NSString *message = nil;
    if ([savedCollectPhotos.allKeys containsObject:pid]) {
        [savedCollectPhotos removeObjectForKey:pid];
        message = [NSString stringWithFormat:@"取消收藏!"];
        
        if ([[self.photoViews objectAtIndex:_pageIndex] isKindOfClass:[EGOPhotoImageView class]]) {
            EGOPhotoImageView *imageView = [self.photoViews objectAtIndex:_pageIndex];
            [imageView removeFromSuperview];            
        }
        
        NSRange range;
        range.location = _pageIndex;
        range.length = 1;

        [[self photoSource] removePhotosInRange:range];            
        
        _isEmpty = NO;        
        self.scrollView.userInteractionEnabled = YES;

        if ([[self photoSource] numberOfPhotos] == 0) {
            _isEmpty = YES;
            self.scrollView.userInteractionEnabled = NO;
            TDSPhotoView *photoView = [[TDSPhotoView alloc] initWithImageURL:nil 
                                                                        name:@"可以点击红心收藏街拍图片"
                                                                       image:[UIImage imageNamed:@"collect.png"]];
            
            [[self photoSource] updatePhotos:[NSArray arrayWithObject:photoView]
                                     inRange:range];
            
        }
        _pageIndex -= 1;
        if (_pageIndex < 0) {
            _pageIndex = 0;
        }
        
        [self setupScrollViewContentSize];
        [self moveToPhotoAtIndex:_pageIndex animated:NO]; 
        [self setBarsHidden:NO animated:NO];
    }
    [TDSDataPersistenceAssistant saveCollectPhotos:savedCollectPhotos];
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setBarsHidden:YES animated:NO];
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
