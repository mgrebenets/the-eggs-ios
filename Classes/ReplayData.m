//
//  ReplayData.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 3/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ReplayData.h"
#import "TimeFrame.h"

#define FRAMES_LIMIT	(10)

@implementation ReplayData

@synthesize timeFrames;

#pragma mark NSCoding protocol implementation
- (void)encodeWithCoder:(NSCoder *)coder {  //encode
       [coder encodeInteger:framesLimit forKey:@"framesLimit"]; 
	[coder encodeObject:timeFrames forKey:@"timeFrames"];
}

- (id)initWithCoder:(NSCoder *)coder {  //decode
	framesLimit = [coder decodeIntegerForKey:@"framesLimit"];
	timeFrames = [[coder decodeObjectForKey:@"timeFrames"] retain];
	if (!timeFrames) {
		timeFrames = [NSMutableArray array];
	}
	return self;
}

#pragma mark Init / dealloc methods
- (void)dealloc {
	[timeFrames release];
	[super dealloc];
}

// init method
- (id)init {
	if (self = [super init]) {
		// init frames array and frames limit
		framesLimit = FRAMES_LIMIT;
		timeFrames = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithFramesLimit:(NSInteger)limit {
	if (self = [super init]) {
		// init frames array and frames limit
		framesLimit = limit;
		timeFrames = [[NSMutableArray alloc] init];		
	}
	return self;
}

#pragma mark Frame methods
- (void)clear {
	[timeFrames removeAllObjects];
	// TO DO: reset replay counters?
}

- (void)addFrame:(TimeFrame *)frame {
        if (frame == nil) return;
        
	// if frame limit is reached, then pop out the oldest
	if (timeFrames.count >= framesLimit) {
		[timeFrames removeObjectAtIndex:0];
	}
        // push new frame on the fame queue
	[timeFrames addObject:frame];
}

@end
