//
//  TDSProgressView.h
//
//  Created by  on 5/10/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDSProgressView : UIView
{
    CGFloat borderGap;
    float progress;
    UIColor *innerColor;
    UIColor *outerColor;
    UIColor *emptyColor;
}

@property (nonatomic, assign) CGFloat borderGap;
@property (nonatomic, retain) UIColor *innerColor;
@property (nonatomic, retain) UIColor *outerColor;
@property (nonatomic, retain) UIColor *emptyColor;
@property (nonatomic, assign) float progress;

@end
