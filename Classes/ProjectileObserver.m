//
//  ProjectileObserver.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ProjectileObserver.h"
#import "ProjectileWorker.h"
#import "ProjectileWorkerDelegate.h"
#import "HelperWorker.h"
#import "GameViewController.h"
#import "The_EggsAppDelegate.h"
#import "SoundEffect.h"
// replay
#import "ReplayData.h"
#import "TimeFrame.h"

@implementation ProjectileObserver

@synthesize points;
@synthesize pauseCnt;
@synthesize catchAll;
@synthesize projectileWorker, helperWorker, observerViewController;
@synthesize replayData;

#pragma mark Init sounds
- (void)initSounds {
	// use current game prefix for sounds
	i4nGoalieAppDelegate *appDelegate = (i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *prefix = [appDelegate currentSoundPrefix];

	catchSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[prefix stringByAppendingString:@"catchSound" ] ofType:@"wav"]];
	gameOverSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[prefix stringByAppendingString:@"gameOverSound"] ofType:@"wav"]];
	moveSounds = [[NSArray alloc] initWithObjects:
				  [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[prefix stringByAppendingString:@"moveSound0"] ofType:@"wav"]],
				  [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[prefix stringByAppendingString:@"moveSound1"] ofType:@"wav"]],
				  [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[prefix stringByAppendingString:@"moveSound2"] ofType:@"wav"]],
				  [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[prefix stringByAppendingString:@"moveSound3"] ofType:@"wav"]],
				  nil];
	
}

#pragma mark NSCoding protocol implementation
- (void)encodeWithCoder:(NSCoder *)coder {  //encode
	[coder encodeInteger:points forKey:@"points"];
	[coder encodeInteger:penalties forKey:@"penalties"];
	[coder encodeInteger:pointsLimit forKey:@"pointsLimit"];
	[coder encodeInteger:penaltiesLimit forKey:@"penaltiesLimit"];
	[coder encodeInteger:pauseCnt forKey:@"pauseCnt"];
	[coder encodeInteger:activeTrajId forKey:@"activeTrajId"];
	[coder encodeObject:replayData forKey:@"replayData"];
	[coder encodeInteger:pointsBak forKey:@"pointsBak"];
	[coder encodeInteger:penaltiesBak forKey:@"penaltiesBak"];
}

- (id)initWithCoder:(NSCoder *)coder {  //decode
	points = [coder decodeIntegerForKey:@"points"];
	penalties = [coder decodeIntegerForKey:@"penalties"];
	pointsLimit = [coder decodeIntegerForKey:@"pointsLimit"];
	penaltiesLimit = [coder decodeIntegerForKey:@"penaltiesLimit"];
	pauseCnt = [coder decodeIntegerForKey:@"pauseCnt"];
	activeTrajId = [coder decodeIntegerForKey:@"activeTrajId"];
	replayData = [[coder decodeObjectForKey:@"replayData"] retain];
	if (!replayData) {
		replayData = [[ReplayData alloc] init];
	}
	pointsBak = [coder decodeIntegerForKey:@"pointsBak"];
	penaltiesBak = [coder decodeIntegerForKey:@"penaltiesBak"];
	
	catchAll = NO;
	projectileWorker = nil;
	helperWorker = nil;
	observerViewController = nil;
	[self initSounds];
	
	return self;
}

#pragma mark Dealloc
- (void)dealloc {
	[projectileWorker release];
	[helperWorker release];
	[observerViewController release];
	[catchSound release];
	[gameOverSound release];
	[moveSounds release];
	[replayData release];
	[super dealloc];
}

#pragma mark Initialize
- (id)init {
	if (self = [super init]) {
		
		points = 0;
		penalties = 0;
		pointsLimit = 9999;
		penaltiesLimit = 6;
		pauseCnt = 0;
		activeTrajId = -1;
		
		catchAll = NO;
		
		projectileWorker = nil;
		helperWorker = nil;
		observerViewController = nil;
		
		[self initSounds];	// init sounds
		
		// init replay data
		replayData = [[ReplayData alloc] init];
	}
	
	return self;
}

#pragma mark Time Frame auxiliary
- (TimeFrame *)getCurrentTimeFrame {
    TimeFrame *timeFrame = [[TimeFrame alloc] 
							initWithDelegate:[projectileWorker delegate]
							realTime:NO 
							activeTrajId:activeTrajId
							catcher:observerViewController.catcherPosition
							points:points
							penalties:penalties
							helper:helperWorker.hidden];
	
    return timeFrame;
}


#pragma mark Reset
- (void)reset {
    points = 0;
    penalties = 0;
	pauseCnt = 0;
	activeTrajId = -1;
    [observerViewController updatePoints:[NSNumber numberWithInteger:points]];
    [observerViewController updatePenalties:[NSNumber numberWithInteger:penalties]];
    // catchAll = NO;
    [replayData clear]; // reset replay data
	
    // add initial frame to the sequence
    // we use the fact, that projectile worker delegate and helper are already reset up to this point
    TimeFrame *initialFrame = [self getCurrentTimeFrame]; // do not retain here
    // add newly created time frame to replay data
    [replayData addFrame:initialFrame];
    // release the time frame
    [initialFrame release];
}

#pragma mark Auxiliary methods
- (void)updateTrajectoryViews:(id)param {
#if 0//DEBUGFULL	
	NSLog(@"\nupdateTrajectoryViews");
#endif	
	ProjectileWorkerDelegate *delegate = (ProjectileWorkerDelegate *)param;
	NSInteger trajectoriesNum = [delegate trajectoriesNumber];
	for (int i = 0; i < trajectoriesNum; i++) {
		NSInteger trajectoryLen = [delegate trajectoryLength:i];
		for (int j = 0; j < trajectoryLen - 1; j++) {
			[observerViewController updateProjectileOn:i atIndex:j hidden:![delegate hasProjectileOn:i atIndex:j]];
		}
	}
}

- (NSInteger)getFellDownId:(id)param {
	ProjectileWorkerDelegate *delegate = (ProjectileWorkerDelegate *)param;
	NSInteger trajectoriesNum = [delegate trajectoriesNumber];
	for (int i = 0; i < trajectoriesNum; i++) {
		if ([delegate projectileFell:i]) return i;
	}
	return -1;
}

- (void)backupState {
    pointsBak = points;
    penaltiesBak = penalties;
}

- (void)restoreState {
    points = pointsBak;
    penalties = penaltiesBak;
	
    // update new values to the observer view controllers
    [observerViewController updatePoints:[NSNumber numberWithInteger:points]];
    [observerViewController updatePenalties:[NSNumber numberWithInteger:penalties]];
}

- (void)resumeAfterCrash {
	
	// clear trajectories
	[observerViewController clearTrajectories:nil];
	
	// proceed with checking game over and resuming the game (if possible)
	
	// check game over condition
	if (penalties >= penaltiesLimit) {
		// game over: notify to application delegate
		if (((i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate]).soundOn) {
			[gameOverSound play];
		}
		// clear replay data here, the initial frame will be added when new game starts (with projectile observer reset)
		[replayData clear];
		
		// notify to app delegate
		[(i4nGoalieAppDelegate*)[[UIApplication sharedApplication] delegate] gameOver:nil];
	} else {
		// game is not over
		// trajectories are reset and the game goes on with no speed decrease
		// however, if the game was paused during crash animation --> do not resume
		if ([(i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate] gameState] != statePaused) {
			// it's time to clear replay data and add initial time frame before resuming the game
			[replayData clear];
			TimeFrame *initialFrame = [self getCurrentTimeFrame];
			[replayData addFrame:initialFrame];
			[initialFrame release];
			
			[projectileWorker resume];
			[helperWorker resume];   // will be ignored if not suspended
		}
	}
}

- (BOOL)gameIsOver {
	return (penalties >= penaltiesLimit);
}

#pragma mark Notify tick implementation
- (void)notifyTick:(id)param {
#if 0//DEBUGFULL	
	NSLog(@"\nProjectileObserver:notifyTick:");
#endif
	// TO DO: all below
	
	// may be detached as a thread, so need autorelease pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// get the time frame or active traj id from the parameter
	TimeFrame *tickTimeFrame = nil;
	BOOL replayMode = NO;
	if ([param isKindOfClass:[TimeFrame class]]) {
		tickTimeFrame = (TimeFrame *)param;
		replayMode = (tickTimeFrame && tickTimeFrame.realTime == NO);
	} else if ([param isKindOfClass:[NSNumber class]]) {
		activeTrajId = [param integerValue];
	}
	
	ProjectileWorkerDelegate *tickDelegate = (replayMode ? tickTimeFrame.projectileWorkerDelegate : [projectileWorker delegate]);
	
	// update trajectory views on main thread (cause it alters ui)
	[self performSelectorOnMainThread:@selector(updateTrajectoryViews:) withObject:tickDelegate waitUntilDone:YES];
	
	// update penalty points to support blinking
	[observerViewController performSelectorOnMainThread:@selector(updatePenalties:) withObject:[NSNumber numberWithInteger:(replayMode ? tickTimeFrame.penalties : penalties)] waitUntilDone:YES];
	
	// if not in replay mode, then add current frame to replay data
	TimeFrame *timeFrame = nil;
	if (!replayMode) {
		// create and save time frame here with current projectile worker delegate, points, penalties, helper, catcher position, etc
		timeFrame = [self getCurrentTimeFrame];	// no need to retain
		
		// add newly created time frame to replay data
		[replayData addFrame:timeFrame];
	}
		
	// in replay mode we need to force update of data on the screen
	NSInteger catcherPosition = (replayMode ? tickTimeFrame.catcherPosition : observerViewController.catcherPosition);
	if (replayMode) {
		// catcher
		[observerViewController performSelectorOnMainThread:@selector(catcherAction:) withObject:[NSNumber numberWithInteger:catcherPosition] waitUntilDone:YES];
		// points
		[observerViewController performSelectorOnMainThread:@selector(updatePoints:) withObject:[NSNumber numberWithInteger:tickTimeFrame.points] waitUntilDone:YES];
		// penalties (already updated?)
		// helper
		[observerViewController performSelectorOnMainThread:@selector(updateHelper:) withObject:[NSNumber numberWithBool:tickTimeFrame.helper] waitUntilDone:YES];
	}
	
	// look up for fallen projectile
	NSInteger fellDownId = [self getFellDownId:tickDelegate];
	
	if (fellDownId >= 0) {	// projectile fell
		// check if fallen projectile has been caught or not
		// by checking current catcher position
		if (catchAll) {
			// need to perform on main thread, to see result on screen immediately
			catcherPosition = fellDownId;
			[observerViewController performSelectorOnMainThread:@selector(catcherAction:) withObject:[NSNumber numberWithInteger:fellDownId] waitUntilDone:YES];
		}
		
		if (fellDownId == catcherPosition) {
#if 0//DEBUGFULL
			printf("\n\n--->CATCH<---!");
#endif			
			if (!replayMode) {
				if (points++ > pointsLimit) {
					points = 0;
				}
				
				// update points to projectile worker delegate
				// so that it will adjust it's tick speed
				[tickDelegate setPoints:points];
				
				// update points to the current time frame
				// also, just in case, consider updating catcher position ?
				timeFrame.points = points;
			}
			
			// the projectile is caught
			if (((i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate]).soundOn) {
				[catchSound play];   // play catch sound
			}
			
			// update points (no main thread to see changes immediately)
			[observerViewController performSelectorOnMainThread:@selector(updatePoints:) withObject:[NSNumber numberWithInteger:(replayMode ? tickTimeFrame.points: points)] waitUntilDone:YES];
			
			// check the milestones, if one of them is reached, reset penalties (if any)
			NSInteger pointsRem = (replayMode ? tickTimeFrame.points : points) % 1000;
			if ((replayMode ? tickTimeFrame.penalties : penalties) > 0
				&& (pointsRem == 0 /* test */ || pointsRem == 200 || pointsRem == 500)) 
			{
				if (!replayMode) {
				    [projectileWorker suspend];	// suspend projectile worker
				}
				
				// set new penalties value before doing reset animation
				// so if app is closed during animation, the recovery will work fine
				if (!replayMode) {
				    penalties = 0;
				}
				
				// let the view controller do the blinking and sounds
				[observerViewController 
				 performSelectorOnMainThread:@selector(resetPenalties:) 
				 withObject:[NSNumber numberWithInteger:penalties] 
				 waitUntilDone:YES];
				
				// sleep current thread to give main thread time for sounds and blinks
				[NSThread sleepForTimeInterval:[observerViewController resetPenaltiesTime]];
				
				[observerViewController performSelectorOnMainThread:@selector(updatePenalties:) withObject:[NSNumber numberWithInteger:0] waitUntilDone:YES];
				
				// can go on now if the game was not paused during penalties reset
				if ([(i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate] gameState] != statePaused) {
					if (!replayMode) {
					    [projectileWorker resume];
					}
				}
			}
		} else {
#if 0//DEBUGFULL
			printf("\n\n--->CRASH!<---");
#endif	
			// projectile fell down
			
			if (!replayMode) {
				[projectileWorker suspend]; // suspend the projectile worker
			}
			
			// do we need to suspend helper worker here?
			// suspending and resuming it will make unequal time intervals for his appearance
			// [helperWorker suspend]; // also suspend helper worker
			
			// add penalty points and check the half penalty point condition
			// NOTE: the hidden property of the helperWorker is changed in advance,
			// so the "old" value should be checked
			BOOL saved = (replayMode ? !tickTimeFrame.helper : !helperWorker.hidden);
			if (!replayMode) {
			    penalties += (saved ? 1 : 2);
			    if (penalties > penaltiesLimit) penalties = penaltiesLimit;
			}
			
			// one more update of helper
			[observerViewController performSelectorOnMainThread:@selector(updateHelper:) withObject:[NSNumber numberWithBool:(replayMode ? tickTimeFrame.helper : helperWorker.hidden)] waitUntilDone:YES];
			
			// update projectile worker delegate and current time frame
			// before starting animation, to allow correct recovery if power goes off 
			// during that animation
			if (!replayMode) {
				// reset the projectiles now
				[tickDelegate resetProjectiles];
				
				// update penalties to the current time frame
				timeFrame.penalties = penalties;
			}
			
			// animate helper here if it is visible
			if (saved) {
				[observerViewController performSelectorOnMainThread:@selector(helperCrashAnimate:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
			}
			
			// submit fall down animation to observer view controller
			// the animation will happen right here in this thread, it will also play sounds
			NSArray *params = [NSArray arrayWithObjects:[NSNumber numberWithInteger:fellDownId], [NSNumber numberWithBool:saved], nil];
			[observerViewController performSelectorOnMainThread:@selector(animateCrash:) 
													 withObject:params 
												  waitUntilDone:YES];
			
			
			
			// give the crash animation time to complete
			[NSThread sleepForTimeInterval:[observerViewController animateCrashTime:saved]];
			
			// animation completed, update penalties now
			[observerViewController performSelectorOnMainThread:@selector(updatePenalties:) withObject:[NSNumber numberWithInteger:(replayMode ? tickTimeFrame.penalties : penalties)] waitUntilDone:YES];
			
			if (!replayMode) {
				// update projectiles (trajectory views) on the screen (they've been just reset)
				[self updateTrajectoryViews:tickDelegate];
				
				// if replay is enabled and this is not replay itself, then start replaying here
				if (((i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate]).replayOn) {
					// initiate replay by calling application delegate's method
					[(i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate] enterReplayModeAction:nil];
					// don't forget to suspend helper worker when starting replay (in app delegate)
				} else {
					// resume the game
					[self resumeAfterCrash];
				}
			}
		}
	} else {	// no fallen projectile
		if (((i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate]).soundOn) {
			NSInteger localActiveTrajId = (replayMode ? tickTimeFrame.activeTrajId :activeTrajId);
			if (TRUE && localActiveTrajId >= 0) {
				[[moveSounds objectAtIndex:localActiveTrajId] play];
			}
		}
	}
	
	// can release the time frame now (release message to nil object is ok)
	[timeFrame release];
	
	[pool release];	// release autorelease pool
}

#pragma mark some setters
- (void)setObserverViewController:(GameViewController *)controller {
	observerViewController = [controller retain];
	[observerViewController updatePoints:[NSNumber numberWithInteger:points]];
	[observerViewController updatePenalties:[NSNumber numberWithInteger:penalties]];
	[self updateTrajectoryViews:[projectileWorker delegate]];
}

@end
