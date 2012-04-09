//
//  TDSPhotoViewItem.m
//  TwinDriveSystem
//
//  Created by 自 己 on 12-3-20.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "TDSPhotoViewItem.h"

@implementation TDSPhotoViewItem
@synthesize pid = _pid;
@synthesize photoUrl = _photoUrl;
@synthesize caption = _caption;
@synthesize collected = _collected;

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.pid = [dictionary objectForKey:@"id"];        
        self.photoUrl = [dictionary objectForKey:@"url"];
        self.caption = [dictionary objectForKey:@"text"];
        self.collected = NO;
    }
    return self;
}

+ (TDSPhotoViewItem *)objectWithDictionary:(NSDictionary *)dictionary{
    TDSPhotoViewItem *photoViewItem = [[TDSPhotoViewItem alloc] initWithDictionary:dictionary]; 
    return [photoViewItem autorelease];
}

#pragma mark -NSCoding methods
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
	if (self) {		
		self.pid = [decoder decodeObjectForKey:@"pid"];
		self.caption = [decoder decodeObjectForKey:@"caption"];
		self.photoUrl = [decoder decodeObjectForKey:@"photoUrl"];
        self.collected = [decoder decodeBoolForKey:@"collected"];
	}
	return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.pid forKey:@"pid"];
	[encoder encodeObject:self.caption forKey:@"caption"];
	[encoder encodeObject:self.photoUrl forKey:@"photoUrl"];    
    [encoder encodeBool:self.collected forKey:@"collected"];
}

@end
