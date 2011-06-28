//
//  ProjectileObserver.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectileWorker;
@class HelperWorker;
@class GameViewController;
@class SoundEffect;
@class ReplayData;

@interface ProjectileObserver : NSObject <NSCoding> {	
	NSInteger points;		// 0 - 9999
	NSInteger penalties;	// 0 - 6 (3 pen pts each of 2 halves)
	NSInteger pointsLimit;	// 9999
	NSInteger penaltiesLimit;   // 6
	NSInteger pauseCnt;	// used pauses
	NSInteger activeTrajId;	// active trajectory id
	// debuggin flags
	BOOL catchAll;
	
	ProjectileWorker *projectileWorker;
	HelperWorker *helperWorker;
	GameViewController *observerViewController;
	
	// replay data
	ReplayData *replayData;
	
	// backup data
	NSInteger pointsBak;
	NSInteger penaltiesBak;
	
	// sounds
	SoundEffect *catchSound;
	SoundEffect *gameOverSound;
	NSArray *moveSounds;
}

- (void)notifyTick:(id)param;
- (void)reset;
- (void)backupState;
- (void)restoreState;
- (void)resumeAfterCrash;
- (BOOL)gameIsOver;

@property (nonatomic/*, readonly*/) NSInteger points;
@property (nonatomic) NSInteger pauseCnt;
@property (nonatomic) BOOL catchAll;
@property (nonatomic, retain) ProjectileWorker *projectileWorker;
@property (nonatomic, retain) HelperWorker *helperWorker;
@property (nonatomic, retain) GameViewController *observerViewController;
@property (nonatomic, readonly) ReplayData *replayData;

@end
