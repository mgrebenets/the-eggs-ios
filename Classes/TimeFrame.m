//
//  TimeFrame.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 3/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TimeFrame.h"
#import "ProjectileWorkerDelegate.h"

@implementation TimeFrame

@synthesize realTime, projectileWorkerDelegate, activeTrajId, catcherPosition, points, penalties, helper;

#pragma mark NSCoding protocol implementation
- (void)encodeWithCoder:(NSCoder *)coder {  //encode
	[coder encodeBool:realTime forKey:@"realTime"];
	[coder encodeObject:projectileWorkerDelegate forKey:@"projectileWorkerDelegate"];
	[coder encodeInteger:activeTrajId forKey:@"activeTrajId"];
	[coder encodeInteger:catcherPosition forKey:@"catcherPosition"];
	[coder encodeInteger:points forKey:@"points"];
	[coder encodeInteger:penalties forKey:@"penalties"];
	[coder encodeBool:helper forKey:@"helper"];
}

- (id)initWithCoder:(NSCoder *)coder {  //decode
	realTime = [coder decodeBoolForKey:@"realTime"];	
	projectileWorkerDelegate = [[coder decodeObjectForKey:@"projectileWorkerDelegate"] retain];
	if (!projectileWorkerDelegate) {
		// TO DO: must do something here
	}
	activeTrajId = [coder decodeIntegerForKey:@"activeTrajId"];
	catcherPosition = [coder decodeIntegerForKey:@"catcherPosition"];
	points = [coder decodeIntegerForKey:@"points"];
	penalties = [coder decodeIntegerForKey:@"penalties"];
	helper = [coder decodeBoolForKey:@"helper"];	
	return self;
}

#pragma mark Init / dealloc methods
- (void)dealloc {
	[projectileWorkerDelegate release];
	[super dealloc];
}

// init methods
- (id)init {
	if (self = [super init]) {
		realTime = NO;
		projectileWorkerDelegate = nil;
		activeTrajId = -1;
		catcherPosition = 0;
		points = 0;
		penalties = 0;
		helper = NO;
	}
	return self;
}

- (id)initWithDelegate:(ProjectileWorkerDelegate *)delegate 
			  realTime:(BOOL)rtime 
		  activeTrajId:(NSInteger)trajId
			   catcher:(NSInteger)catcher
				points:(NSInteger)pts
			 penalties:(NSInteger)pens
				helper:(BOOL)hlp
{
    if (self = [super init]) {
        // make a complete copy of delegate (needs testing)
        realTime = rtime;
		activeTrajId = trajId;
		[projectileWorkerDelegate autorelease];
        projectileWorkerDelegate = [delegate copy];
        catcherPosition = catcher;
        points = pts;
        penalties = pens;
        helper = hlp;
    }
    return self;
}

@end
