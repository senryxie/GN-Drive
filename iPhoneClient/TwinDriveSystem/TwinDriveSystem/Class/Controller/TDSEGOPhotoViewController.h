//
//  TDSEGOPhotoViewController.h
//  TwinDriveSystem
//
//  Created by 自 己 on 12-4-9.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "EGOPhotoViewController.h"
@class TDSPhotoDataSource;

@interface TDSEGOPhotoViewController : EGOPhotoViewController

//@property(nonatomic,readonly) id <EGOPhotoSource> photoSource;
//@property(nonatomic,retain) NSMutableArray *photoViews;
//@property(nonatomic,retain) UIScrollView *scrollView;
//@property(nonatomic,assign) BOOL _fromPopover;

- (id)initWithPhoto:(id<EGOPhoto>)aPhoto;

- (id)initWithImage:(UIImage*)anImage;
- (id)initWithImageURL:(NSURL*)anImageURL;

- (id)initWithPhotoSource:(id <EGOPhotoSource>)aPhotoSource;
- (id)initWithPopoverController:(id)aPopoverController photoSource:(id <EGOPhotoSource>)aPhotoSource;


- (NSInteger)currentPhotoIndex;
- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated;


// 暴露出来的
- (void)loadScrollViewWithPage:(NSInteger)page;
- (void)setupScrollViewContentSize;
- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated;
- (TDSPhotoDataSource *)photoSource; // 这尼玛为啥会是readOnly，暴露出来

@end
