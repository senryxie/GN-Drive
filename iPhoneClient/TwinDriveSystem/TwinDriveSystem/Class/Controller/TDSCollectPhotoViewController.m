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
    
    if ([collectPhotos.allKeys count] > 0) {
        NSMutableArray *photoViews = [NSMutableArray arrayWithCapacity:collectPhotos.count];
        for (TDSPhotoViewItem *photoViewItem in collectPhotos.allValues) {
            TDSPhotoView *photoView = [TDSPhotoView photoWithItem:photoViewItem];
            [photoViews addObject:photoView];
        }
//        NSRange range;    
//        range.location = 0;
//        range.length = collectPhotos.count;
//        [[self photoSource] updatePhotos:photoViews inRange:range];
//        for (unsigned i = 0; i < range.length; i++) {
//            [self.photoViews insertObject:[NSNull null] atIndex:0];
//        }
        
        self = [super initWithPhotoSource:[[EGOQuickPhotoSource alloc] initWithPhotos:photoViews]];
        
    }else {
        self = [super initWithImage:anImage];
    }
    return self;
    
}
#pragma mark - Public Function
- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated {
    [super moveToPhotoAtIndex:index animated:animated];
}
- (void)updatePhotoSource{
    
    NSDictionary *collectPhotos = [TDSDataPersistenceAssistant getCollectPhotos];
    
    if ([collectPhotos.allKeys count] > 0) {
        NSMutableArray *photoViews = [NSMutableArray arrayWithCapacity:collectPhotos.count];
        for (TDSPhotoViewItem *photoViewItem in collectPhotos.allValues) {
            TDSPhotoView *photoView = [TDSPhotoView photoWithItem:photoViewItem];
            [photoViews addObject:photoView];
        }
        NSRange range;    
        range.location = 0;
        range.length = collectPhotos.count;
        [[self photoSource] updatePhotos:photoViews inRange:range];
        for (unsigned i = 0; i < range.length; i++) {
            [self.photoViews insertObject:[NSNull null] atIndex:0];
        }
    }
    
    [self setupScrollViewContentSize];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePhotoSource) 
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
