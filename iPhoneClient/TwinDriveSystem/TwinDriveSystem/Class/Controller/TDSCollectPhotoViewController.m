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

@interface TDSCollectPhotoViewController (Private)

@end

@implementation TDSCollectPhotoViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TDSRecordPhotoNotification
                                                  object:nil];
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
        TDSPhotoView *photoView = [[TDSPhotoView alloc] initWithImage:anImage];
        [photoViews addObject:photoView];
        [photoView release];        
    }
    self = [super initWithPhotoSource:[[TDSPhotoDataSource alloc] initWithPhotos:photoViews]];

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
