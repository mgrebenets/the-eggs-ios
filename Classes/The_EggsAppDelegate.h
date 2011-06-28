//
//  The_EggsAppDelegate.h
//  The Eggs
//
//  Created by Maksym Grebenets on 1/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameViewController;
@class ProjectileWorker;
@class ProjectileObserver;
@class HelperWorker;
@class AboutViewController;
#ifdef DISKOTEKA_90
@class DiskotekaViewController;
#endif

#define STATS_CAPACITY	(10)

enum {
	gameModeNone = 0,
    gameModeI = 3,
    gameModeII = 4,
    gameModeBoth = gameModeI & gameModeII,
    gameModeTotal = 4
};

enum {
    stateReady = 0,
    stateRunning,
    statePaused,
	stateUnpausing,
    stateGameOver,
    stateReplay,
    stateReplaying,
	stateTotal
};

@interface i4nGoalieAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GameViewController *gameViewController;
	UINavigationController *aboutNavigationController;
	AboutViewController *aboutViewController;
#ifdef DISKOTEKA_90	
	DiskotekaViewController *diskotekaViewController;
#endif	
    NSInteger gameState;
    ProjectileWorker *projectileWorker;
    ProjectileObserver *projectileObserver;
    HelperWorker *helperWorker;
	BOOL soundOn;
	NSMutableArray *statsModeI;
	NSMutableArray *statsModeII;
	BOOL replayOn;
	BOOL stopReplaying;
	
	NSString *nickName;
	NSString *emailKey;
	NSString *countryCode;
	
	NSMutableArray *countriesDisplayList;
	NSArray *countriesIndexLetters;
	
	// current game type and current selection (for all in one)
	NSInteger gameId;
	NSInteger currentGameId;
	NSInteger oldGameId;
	NSDictionary *gamePrefixesDic;
	NSArray *gamesIdList;    // list of all-in-one collection game ids
	
    BOOL fullFeatures;
    BOOL fullSkins;
    BOOL submitOnUpgrade;
}

- (void)suspendProjectileWorker:(id)sender;
- (void)resumeProjectileWorker:(id)sender;
- (void)resetProjectileWorker:(id)sender;
- (void)restartProjectileWorker:(id)sender;

- (void)toggleCatchAllFlag:(id)sender;

- (void)gameStart:(NSInteger)mode;
- (void)gameOver:(id)sender;
- (void)gamePause:(id)sender;
- (void)gameResume:(id)sender;
- (void)gameSoundOn:(id)on;
- (void)gameReplayOn:(id)on;
- (void)displayGameInfo:(id)show;
- (void)openFeintAction:(id)sender;
#ifdef DISKOTEKA_90
- (void)displayDiskotekaPromo:(id)show;
#endif

- (void)enterReplayModeAction:(id)sender;
- (void)startReplayAction:(id)sender;
- (void)stopExitReplayAction:(id)sender;
- (void)stopReplayAction:(id)sender;
- (void)exitReplayModeAction:(id)sender;


- (NSString *)currentGamePrefix;
- (NSString *)gamePrefixForId:(NSInteger)theGameId;
- (NSString *)currentSoundPrefix;
- (NSString *)soundPrefixForId:(NSInteger)theGameId;
- (NSString *)gameDescription;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GameViewController *gameViewController;
@property (nonatomic, readonly) BOOL soundOn;
@property (nonatomic, readonly) BOOL replayOn;
@property (nonatomic, readonly) NSInteger gameState;
@property (nonatomic, assign) NSInteger currentGameId;
@property (nonatomic, readonly) NSInteger oldGameId;
@property (nonatomic, readonly) NSMutableArray *statsModeI;
@property (nonatomic, readonly) NSMutableArray *statsModeII;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *emailKey;
@property (nonatomic, retain) NSString *countryCode;
@property (nonatomic, retain) NSMutableArray *countriesDisplayList;
@property (nonatomic, retain) NSArray *countriesIndexLetters;
@property (nonatomic, readonly) NSArray *gamesIdList;

@property BOOL fullFeatures;
@property BOOL fullSkins;
@property BOOL submitOnUpgrade;

@end


