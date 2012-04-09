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

@interface TDSCollectPhotoViewController (Private)

@end

@implementation TDSCollectPhotoViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TDSRecordPhotoNotification
                                                  object:nil];
    [super dealloc];
}

#pragma mark - Public Function
- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < [self.photoSource numberOfPhotos] && index >= 0) {
        return;
    }
    [super moveToPhotoAtIndex:index animated:animated];
}
- (void)updatePhotoSource{
//    [[self photoSource] addLoadingPhotosOfCount:ONCE_REQUEST_COUNT_LIMIT atIndex:0];
//    for (unsigned i = 0; i < ONCE_REQUEST_COUNT_LIMIT; i++) {
//        [self.photoViews insertObject:[NSNull null] atIndex:0];
//    }
    [self setupScrollViewContentSize];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	NSDictionary *collectPhotos = [TDSDataPersistenceAssistant getCollectPhotos];
    
    if ([collectPhotos.allKeys count] <= 0) {
        
    }
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
