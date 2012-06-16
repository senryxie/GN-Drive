//
//  EGOPhotoCaptionView.m
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/13/2010.
//  Copyright (c) 2008-2009 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGOPhotoCaptionView.h"

#import <QuartzCore/QuartzCore.h>

@implementation EGOPhotoCaptionView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

		_textLabelFrame = CGRectMake(15.0f, 10.0f, self.frame.size.width - 30.0f, 40.0f);
		_textLabel = [[UILabel alloc] initWithFrame:_textLabelFrame];        
		_textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		_textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.lineBreakMode = UILineBreakModeWordWrap;
        _textLabel.numberOfLines = 4;        
        _textLabel.font = [UIFont fontWithName:@"Arial" size:15.0f];
		_textLabel.textAlignment = UITextAlignmentLeft;//UITextAlignmentCenter;
		_textLabel.textColor = [UIColor whiteColor];
		_textLabel.shadowColor = [UIColor blackColor];
		_textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		[self addSubview:_textLabel];
		[_textLabel release];
		
							  
    }
    return self;
}

- (void)layoutSubviews{
	
	[self setNeedsDisplay];
    
    [_textLabel setFrame:_textLabelFrame];
    CGRect v_frame = self.frame;
    v_frame.size.height = _textLabelFrame.size.height + 20;
    self.frame = v_frame;

	
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[[UIColor colorWithWhite:1.0f alpha:0.8f] setStroke];
	CGContextMoveToPoint(ctx, 0.0f, 0.0f);
	CGContextAddLineToPoint(ctx, self.frame.size.width, 0.0f);
	CGContextStrokePath(ctx);
	
}

- (void)setCaptionText:(NSString*)text hidden:(BOOL)val{
	
	if (text == nil || [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
		
		_textLabel.text = nil;	
		[self setHidden:YES];		
        
	} else {
        
        CGSize labelSize = [text sizeWithFont:_textLabel.font
                            constrainedToSize:CGSizeMake(self.frame.size.width-15.0,
                                                         80.0f)
                                lineBreakMode:UILineBreakModeWordWrap];
//        if (labelSize.height<40.0) {
//            labelSize.height = 40.0f;
//        }
        _textLabelFrame.size.height = labelSize.height;
        [_textLabel setFrame:_textLabelFrame];
        _textLabel.text = text;
        
        CGRect v_frame = self.frame;
        v_frame.size.height = _textLabelFrame.size.height + 20;
        self.frame = v_frame;
        
        [self setNeedsLayout];
        
		[self setHidden:val];

	}
	
	
}

- (void)setCaptionHidden:(BOOL)hidden{
	if (_hidden==hidden) return;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3f];
		self.alpha= hidden ? 0.0f : 1.0f;
		[UIView commitAnimations];
		
		_hidden=hidden;
		
		return;
		
	}
#endif
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2f];
	
	if (hidden) {
		
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		self.frame = CGRectMake(0.0f, self.superview.frame.size.height + 10, self.frame.size.width, self.frame.size.height);
		
	} else {
		
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		
		self.frame = CGRectMake(0.0f, self.superview.frame.size.height - self.frame.size.height - 10, self.frame.size.width, self.frame.size.height);

	}
	
	[UIView commitAnimations];
	
	_hidden=hidden;
	
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	_textLabel=nil;
    [super dealloc];
}


@end
