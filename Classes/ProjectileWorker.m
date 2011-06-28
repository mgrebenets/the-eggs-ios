//
//  ProjectileWorker.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ProjectileWorker.h"
#import "ProjectileWorkerDelegate.h"
#import "ProjectileObserver.h"

@implementation ProjectileWorker

@synthesize suspended, delegate, observer;

#pragma mark NSCoding protocol implementation
- (void)encodeWithCoder:(NSCoder *)coder {  //encode
	[coder encodeInteger:tickCnt forKey:@"tickCnt"];
	[coder encodeBool:suspended forKey:@"suspended"];
	[coder encodeObject:delegate forKey:@"delegate"];
}

- (id)initWithCoder:(NSCoder *)coder {  //decode
	tickCnt = [coder decodeIntegerForKey:@"tickCnt"];
	suspended = [coder decodeBoolForKey:@"suspended"];
	delegate = [[coder decodeObjectForKey:@"delegate"] retain];
	sleeping = NO;	
	observer = nil;
	return self;
}

#pragma mark dealloc
- (void)dealloc {
#if 0//DEBUGFULL		
	NSLog(@"\nProjectileWorker:dealloc");
#endif	
	[delegate release];
	[observer release];
	[super dealloc];
}

- (void)tick:(id)sender {
#if 0//DEBUGFULL		
	NSLog(@"\nProjectileWorker:tick", suspended, tickCnt);	
#endif	
	// this method is detached as a thread, so it needs an autorelase pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	while (!suspended) {
		// sleep for duration of one tick
		sleeping = YES;
		[NSThread sleepForTimeInterval:[delegate tickSpeed:tickCnt]];
		sleeping = NO;
		
		// it could be suspended while it was sleeping
		@synchronized (self) {	
			if (suspended) return;	// thread is suspended
		}
		
		[delegate updateProjectiles:tickCnt];	// update projectiles (request delegate)
		//[observer notifyTick:nil];	// notify observer about the tick
		[NSThread detachNewThreadSelector:@selector(notifyTick:) toTarget:observer withObject:[NSNumber numberWithInteger:[delegate activeTrajId]]]; 
		
		tickCnt++;
	}
	
	[pool release];	// release autorelease pool
}

// init method
- (id)init {
#if 0//DEBUGFULL		
	NSLog(@"\nProjectileThread:init");
#endif	
	if (self = [super init]) {
		suspended = NO;
		sleeping = NO;
		tickCnt = 0;
		delegate = nil;
		observer = nil;
	}
	
	return self;
}

- (void)start {
#if 0//DEBUGFULL		
	NSLog(@"\nProjectileWorker:start");
#endif	
	suspended = NO;
	// detach a new thread with "tick:" selector
	// however the thread may be sleeping
	if (!sleeping) {
		[NSThread detachNewThreadSelector:@selector(tick:) toTarget:self withObject:nil];
	}
}

- (void)restart {
	// suspend, reset, reset tick count, resume
	[self suspend];	// suspend
	[delegate reset];	// reset delegate
	tickCnt = 0;	// reset tick count
	suspended = NO;
	if (!sleeping) [self start];
	//[self resume];	// resume
}

- (void)reset {
	// reset projectiles and trajectories, but not tick count
	// like it should be, delegate this responsibility
	[delegate reset];
	tickCnt = 0;
}

- (void)suspend {
#if 0//DEBUGFULL		
	NSLog(@"\nProjectileWorker:suspend");
#endif	
	if (suspended) return;	// ignore if suspended
	// set the flag and cancel next tick selector if any
	suspended = TRUE;
	[NSObject cancelPreviousPerformRequestsWithTarget:self];    // TO DO: is it required???
}

- (void)resume {
#if 0//DEBUGFULL		
	NSLog(@"\nProjectileWorker:resume");
#endif	
	if (!suspended) return;	// ignore if not suspended
	// clear suspened flag and start ticking again
	suspended = FALSE;
	// it was suspended during sleep time and did not wake up yet, 
	// then there's already a thread, otherwise start again
	if (!sleeping) [self start];
}

@end
