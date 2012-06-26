//
//  TDSProgressView.m
//
//  Created by on 5/10/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import "TDSProgressView.h"

@implementation TDSProgressView

@synthesize borderGap;
@synthesize innerColor;
@synthesize outerColor;
@synthesize emptyColor;
@synthesize progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.innerColor = [UIColor lightGrayColor];
        self.outerColor = [UIColor lightGrayColor];
        self.emptyColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    [innerColor release], innerColor = nil;
    [outerColor release], outerColor = nil;
    [emptyColor release], emptyColor = nil;

    [super dealloc];
}

- (void)setProgress:(float)theProgress
{
    // make sure the user does not try to set the progress outside of the bounds
    progress = MAX(MIN(theProgress, 1.0), 0.0);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    // save the context
    CGContextSaveGState(context);

    // allow antialiasing
    CGContextSetAllowsAntialiasing(context, TRUE);

    // we first draw the outter rounded rectangle
    rect = CGRectInset(rect, 1.0f, 1.0f);
    CGFloat radius = 0.5f * rect.size.height;

    [outerColor setStroke];
    CGContextSetLineWidth(context, 2.0f);

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);

    // draw the empty rounded rectangle (shown for the "unfilled" portions of the progress
    rect = CGRectInset(rect, borderGap, borderGap);
    radius = 0.5f * rect.size.height;

    [emptyColor setFill];

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius);
    CGContextClosePath(context);
    CGContextFillPath(context);

    // draw the inside moving filled rounded rectangle
    radius = 0.5f * rect.size.height;

    // make sure the filled rounded rectangle is not smaller than 2 times the radius
    rect.size.width *= progress;
    if (rect.size.width < 2 * radius)
        rect.size.width = 2 * radius;

    [innerColor setFill];

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius);
    CGContextClosePath(context);
    CGContextFillPath(context);

    // restore the context
    CGContextRestoreGState(context);
}

@end
