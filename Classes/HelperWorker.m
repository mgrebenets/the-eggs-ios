//
//  HelperWorker.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 17/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HelperWorker.h"
#import "GameViewController.h"

@implementation HelperWorker

@synthesize observerViewController, hidden;

#pragma mark NSCoding protocol implementation
- (void)encodeWithCoder:(NSCoder *)coder {  //encode
	[coder encodeFloat:toggleTimeout forKey:@"toggleTimeout"];
	[coder encodeBool:hidden forKey:@"hidden"];
	[coder encodeBool:suspended forKey:@"suspended"];
}

- (id)initWithCoder:(NSCoder *)coder {  //decode
	toggleTimeout = [coder decodeFloatForKey:@"toggleTimeout"];
	hidden = [coder decodeBoolForKey:@"hidden"];
	suspended = [coder decodeBoolForKey:@"suspended"];
	sleeping = NO;	
	return self;
}

#pragma mark Init / dealloc methods
- (void)dealloc {
	[observerViewController release];
	[super dealloc];
}

// init method
- (id)init {
#if 0//DEBUGFULL		
	NSLog(@"\nHelperWorker:init");
#endif	
	if (self = [super init]) {
		toggleTimeout = 5.0;
		hidden = NO;
		suspended = NO;
		sleeping = NO;
		observerViewController = nil;
	}
	
	return self;
}

#pragma mark Main method for thread detaching
- (void)toggleHelper:(id)sender {
#if 0//DEBUGFULL		
	NSLog(@"\nHelperWorker:toggleHelper");	
#endif	
	// this method is detached as a thread, so it needs an autorelase pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	while (!suspended) {
#if 0//DEBUGFULL		
		NSLog(@"\n\tnext iteration, hidden:%d", hidden);	
#endif	
		// sleep for duration of one tick
		sleeping = YES;
		[NSThread sleepForTimeInterval:toggleTimeout];
		sleeping = NO;
		
		// it could be suspended while it was sleeping
		@synchronized (self) {	
			if (suspended) return;	// thread is suspended
		}
		
		// update view on main thread (doesn't update any if run from this thread)
		[observerViewController performSelector:@selector(updateHelper:) 
					 onThread:[NSThread mainThread] 
				   withObject:[NSNumber numberWithBool:!hidden] 
				waitUntilDone:YES];
		
		hidden = !hidden;	// toggle visibility
	}
	
	//[self toggleHelper:nil];	// go on, until it is not suspended
	
	[pool release];	// release autorelease pool
}

#pragma mark Worker control methods
- (void)start {
#if 0//DEBUGFULL		
	NSLog(@"\nHelperWorker:start");
#endif
	// don't forget to clear paused flag
	suspended = NO;
	// detach a new thread with "toggleHelper:" selector
	// however the thread may be sleeping
	if (!sleeping) {
		[NSThread detachNewThreadSelector:@selector(toggleHelper:) toTarget:self withObject:nil];
	}
}

- (void)stop {
#if 0//DEBUGFULL		
	NSLog(@"\nHelperWorker:stop");
#endif
	[self suspend];
}

- (void)reset {
	suspended = NO;
	hidden = YES;
	[observerViewController updateHelper:[NSNumber numberWithBool:hidden]];
}

- (void)suspend {
#if 0//DEBUGFULL		
	NSLog(@"\nHelperWorker:pause");
#endif	
	if (suspended) return;	// ignore if paused
	// set the flag and cancel next tick selector if any
	suspended = TRUE;
	[NSObject cancelPreviousPerformRequestsWithTarget:self];    // TO DO: is it required???
}

- (void)resume {
#if 0//DEBUGFULL		
	NSLog(@"\nHelperWorker:resume");
#endif	
	if (!suspended) return;	// ignore if not suspended
	// clear pauseded flag and start worker again
	suspended = FALSE;
	// it was suspended before, so there's no thread - start again
	if (!sleeping) [self start];
}

#pragma mark Observer view controller setter
- (void)setObserverViewController:(GameViewController *)viewController {
    observerViewController = [viewController retain];
    [observerViewController updateHelper:[NSNumber numberWithBool:hidden]];
}

@end

