//
//  TDSLoggerView.m
//  TwinDriveSystem
//
//  Created by 自 己 on 12-4-2.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSLoggerView.h"

#define CAP_POINT CGPointMake(10.0f, 200.0f)
#define SMALL_LOGGER_SIZE CGSizeMake(30.0f, 30.0f)
#define BIG_LOGGER_SIZE   CGSizeMake(320.0f, 200.0f)
#define LOGVIEW_DEFALUT_STRING @""

static TDSLoggerView *_instance = nil;

@implementation TDSLoggerView

- (void)clear{
    [_logText setString:LOGVIEW_DEFALUT_STRING];
    [self updateDebugTextAnimated:NO];
}
- (void)appendString:(NSString*)string{
    [_logText appendString:string];
    [self updateDebugTextAnimated:YES];    
}
- (void)appendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2){
    [_logText appendFormat:format];
    [self updateDebugTextAnimated:YES];    
}

- (void)showDebugInfo:(UIGestureRecognizer*)recognizer{

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.2f];
        CGRect frame = _containerView.frame;
        CGRect textFrame = _textView.frame;
        if (CGSizeEqualToSize(_textView.frame.size, SMALL_LOGGER_SIZE) ) {
            _textView.text = _logText;
            textFrame.size = BIG_LOGGER_SIZE;
            frame.origin = CGPointMake(0.0f, 20.0f);
            _textView.scrollEnabled = YES;            
        }else {
            _textView.text = LOGVIEW_DEFALUT_STRING;
            textFrame.size = SMALL_LOGGER_SIZE;
            frame.origin = CAP_POINT;
            _textView.scrollEnabled = NO;
        }       
        _textView.frame = textFrame;
        
        frame.size = _textView.frame.size;
        _containerView.frame = frame;
    
        [UIView commitAnimations];
        
        [self updateDebugTextAnimated:NO];            
    }

}
- (void)updateDebugTextAnimated:(BOOL)animated{
    if (!CGSizeEqualToSize(_textView.frame.size, SMALL_LOGGER_SIZE) ) {
        _textView.text = _logText;
        CGRect visibleFrame = CGRectZero;
        visibleFrame.size = _textView.contentSize;
        [_textView scrollRectToVisible:visibleFrame animated:animated];
    }
}

#pragma mark - 
- (void)dealloc
{
    [_containerView release];
    [_textView release];
    [_logText release];
	[super dealloc];
}

+ (TDSLoggerView *)getInstance{
    @synchronized(self)
	{
		if (_instance == nil)
		{
            _instance = [[TDSLoggerView alloc] init];
		}
	}	
	return  _instance;
}
- (id)init{
    self = [super init];
    if (self) {
        _logText =[[NSMutableString alloc] initWithString:LOGVIEW_DEFALUT_STRING];
        
        CGRect frame = CGRectZero;
        frame.origin = CAP_POINT;
        frame.size = SMALL_LOGGER_SIZE;
        
        _containerView = [[UIView alloc] initWithFrame:frame];
        _containerView.backgroundColor = [UIColor clearColor];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window!= nil && ![window.subviews containsObject:_containerView]) {
            [window addSubview:_containerView];
        }
        
        CGRect textFrame = CGRectZero;
        textFrame.size = _containerView.frame.size;
        _textView = [[UITextView alloc] initWithFrame:textFrame];
        _textView.editable = NO;
        _textView.scrollEnabled = YES;
        _textView.backgroundColor = [UIColor blackColor];
        _textView.alpha = .7f;
        _textView.textColor = [UIColor greenColor];
        _textView.text = _logText;
        UITapGestureRecognizer *pinchGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(showDebugInfo:)];
        [_textView addGestureRecognizer:pinchGestureRecognizer];
        [pinchGestureRecognizer release];
        [_containerView addSubview:_textView];
    }
    return self;
}
+ (id) allocWithZone:(NSZone*) zone {
	@synchronized(self) { 
		if (_instance == nil) {
			_instance = [super allocWithZone:zone];  // assignment and return on first allocation
			return _instance;
		}
	}
	return nil;
}

- (id) copyWithZone:(NSZone*) zone {
	return _instance;
}

- (id) retain {
	return _instance;
}

- (unsigned) retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (id) autorelease {
	return self;
}
@end
