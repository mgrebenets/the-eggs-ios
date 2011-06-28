//
//  i4nGoalieAppDelegate.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/11/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//



#import "The_EggsAppDelegate.h"
#import "OpenFeint.h"
#import "GameViewController.h"
#import "WideGameViewController.h"
#import "TheEggsProAboutViewController.h"
#import "ViewTransformer.h"

#import "ProjectileWorker.h"
#import "ProjectileWorkerDelegate.h"
#import "SimpleProjectileWorkerDelegate.h"
#import "ProjectileObserver.h"
#import "HelperWorker.h"
#import "StatsEntry.h"

#import "TimeFrame.h"
#import "ReplayData.h"

#import "OFLeaderboardService.h"
#import "OFLeaderboard.h"
#import "OFHighScoreService.h"
#import "OFHighScore.h"
#import "OFAchievementService.h"

#ifdef DISKOTEKA_90
#import "DiskotekaViewController.h"
#endif



#define kSoundOnKey	@"SoundOnKey"
#define kReplayOnKey	@"ReplayOnKey"
#define kGameStateKey	@"GameStateKey"
#define kCatcherPositionKey	@"CatcherPositionKey"
#define kHelperWorkerKey	@"HelperWorkerKey"
#define kProjectileWorkerKey	@"ProjectileWorkerKey"
#define kProjectileObserverKey	@"ProjectileObserverKey"
#define kStatsModeIKey	@"StatsModeIKey"
#define kStatsModeIIKey	@"StatsModeIIKey"
#define kNickNameKey	@"NickNameKey"
#define kEmailKeyKey	@"EmailKeyKey"
#define kCountryCodeKey	@"CountryCodeKey"
#define kCurrentGameIdKey	@"CurrentGameIdKey"
#define kFullFeaturesKey    @"FullFeaturesKey"
#define kFullSkinsKey   @"FullSkinKey"
#define kSubmitOnUpgradeKey @"SubmitOnUpgradeKey"

typedef enum {
	gameType_Simple = 1,
	gameType_Wide = 2,
	gameType_Custom = 4,
	gameType_Total = 3
} GameType;

typedef enum {
	gameID_Unknown = 0,
	gameID_TheEggs = (8 | gameType_Simple),
	gameID_TheWolf = (16 | gameType_Wide),
	gameID_TheHunt = (32 | gameType_Wide),
	gameID_TheHockey = (64 | gameType_Wide),
	gameID_TheSpaceExplorers = (128 | gameType_Wide),
	gameID_TheSpaceFlight = (256 | gameType_Wide),
	gameID_TheCat = (512 | gameType_Wide),
	gameID_BullsAndBears = (1024 | gameType_Custom), //temp
	gameID_TheCatching = (2048 | gameType_Custom),
	gameID_TheEggsHD = ((2048 * 2) | gameType_Wide),
	gameID_TheEggsLite = ((2048 * 4) | gameType_Simple),
	gameID_TheEggsPro = ((2048 * 8) | gameType_Custom),
	gameID_Total = 12
} GameID;

@interface i4nGoalieAppDelegate ()
- (void)submitPoints:(NSInteger)points forMode:(NSInteger)mode;
@end


#pragma mark -

@implementation i4nGoalieAppDelegate

#pragma mark -
@synthesize window;
@synthesize gameViewController;
@synthesize gameState;
@synthesize currentGameId;
@synthesize oldGameId;
@synthesize soundOn;
@synthesize replayOn;
@synthesize statsModeI, statsModeII;
@synthesize nickName, emailKey, countryCode;
@synthesize countriesDisplayList;
@synthesize countriesIndexLetters;
@synthesize gamesIdList;
@synthesize fullFeatures;
@synthesize fullSkins;
@synthesize submitOnUpgrade;

#pragma mark Setup countries display list
- (void)setupCountriesDisplayList {
	/* 
	 * refer to TableViewSuite\2_SimpleIndexedtableView sample code 
	 */
	
	/* make a dictionary with first letter from country name used as a key
	 * the elements of a dictionary are arrays of country dictionaries
	 * country dictionary is a dictionary with 2 pairs:
	 * ISO code for "coutryCode" key and display name for "countryName" key (display name is localized)
	 */
	
	NSMutableDictionary *indexedCountries = [[NSMutableDictionary alloc] init];
	NSArray *knownCountryCodes = [NSLocale ISOCountryCodes];    // list of all known ISO country codes
	
	for (NSString *code in knownCountryCodes) {
		//get localized display name for the country code
		NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:code];
		NSString *firstLetter = [countryName substringToIndex:1];   // use first letter of display name as an index
		NSMutableArray *indexArray = [indexedCountries objectForKey:firstLetter];   // array of countries starting with this letter
		if (indexArray == nil) {
			indexArray = [[NSMutableArray alloc] init];
			[indexedCountries setObject:indexArray forKey:firstLetter];
			[indexArray release];
		}
		
		// country dictionary: "countryCode" --> ISO code, "countryName" --> localized display name
		NSDictionary *countryDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:code, @"countryCode", countryName, @"countryName", nil];
		[indexArray addObject:countryDictionary];
		[countryDictionary release];
	}
	
	
	// alloc and init display list here
	self.countriesDisplayList = [[NSMutableArray alloc] init];
	
	// get a list of all indeces, will be used later to display sections and right indeces
	// Normally we'd use a localized comparison to present information to the user, but here we know the data only contains unaccented uppercase letters
	// TO DO: will this sort work for russian and other locales???
	self.countriesIndexLetters = [[indexedCountries allKeys] sortedArrayUsingSelector:@selector(compare:)];
	
	// define sort descriptors to sort countries starting with same letter in ascending order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"countryName" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];    // array of sort descriptors (only one)
	
	for (NSString *indexLetter in countriesIndexLetters) {
		
		// get an array of country dictionaries for this letter
		NSMutableArray *countryDictionaries = [indexedCountries objectForKey:indexLetter];
		// sort this array by country display names
		[countryDictionaries sortUsingDescriptors:sortDescriptors];
		
		// add sorted array of dictionaries to display list, together with index letter
		NSDictionary *letterDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:indexLetter, @"letter", countryDictionaries, @"countries", nil];
		[countriesDisplayList addObject:letterDictionary];
		[letterDictionary release];
	}
	
	[sortDescriptor release];   // release sort descriptor
	[indexedCountries release];
}

#pragma mark object encode
- (NSData *)getEncodedDataForObject:(id)object forKey:(NSString *)key {
	// archive object data using the key
	NSMutableData *data;
	NSKeyedArchiver *archiver;
	
	data = [NSMutableData data];
	archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	// Customize archiver here
	[archiver encodeObject:object forKey:key];
	[archiver finishEncoding];
	[archiver release];
	
	return data;	// autorelease won't work
}

- (id)getDecodedObjectForKey:(NSString *)key {
	// read and decode object from user defaults
	id object = nil;
	NSData *localData = nil;
	localData = [[[NSUserDefaults standardUserDefaults] objectForKey:key] mutableCopy];
	if (!localData) return nil;
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:localData];
	// unarchive the object, NOTE: RETAIN is needed!!!
	// the same key is used for user defaults and archiving
	object = [[unarchiver decodeObjectForKey:key] retain]; // the initWithEncoder will be called
	[unarchiver finishDecoding];
	[unarchiver release];		    
	[localData release];   // release local game data
	
	// register object with user defaults
	// same key is used for defaults and archiving
	NSDictionary *objectDict = [NSDictionary dictionaryWithObject:[self getEncodedDataForObject:object forKey:key] forKey:key];
	[[NSUserDefaults standardUserDefaults] registerDefaults:objectDict];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return object;
}

#pragma mark Some setter
- (void)setCurrentGameId:(NSInteger)theGameId {
    currentGameId = theGameId;
    // TODO: if the skin update will be made "on the fly"
    // then this is the place to do all job    
}

- (void) setupOpenFeint {
	//init open feint
	NSString *key;
	NSString *secret;
	NSString *name;
	if (gameId == gameID_TheEggsPro) {
		key = @"<YOUR-OPENFEINT-KEY>";
		secret = @"<YOUR-OPENFEINT-SECRET>";
		name = NSLocalizedString(@"The Eggs Pro", @"The Eggs Pro");
	} else if (gameId == gameID_TheCatching) {
		key = @"";
		secret = @"";
		name = NSLocalizedString(@"The Cathing", @"The Cathing");
	} else if (gameId == gameID_TheEggs) {
		key = @"";
		secret = @"";
		name = NSLocalizedString(@"The Eggs", @"The Eggs");
	}
	
	// orientation and other settings
	NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight], OpenFeintSettingDashboardOrientation,
							  @"The Eggs Pro", OpenFeintSettingShortDisplayName, 
//							  NSNumber numberWithBool:YES], OpenFeintSettingEnablePushNotifications,
//							[NSNumber numberWithBool:NO], OpenFeintSettingDisableChat,
							  nil];
	[OpenFeint initializeWithProductKey:key
							  andSecret:secret
						 andDisplayName:name
							andSettings:settings
						   andDelegates:nil];              // see OFDelegatesContainer.h
}

- (void)setFullFeatures:(BOOL)newVal {
	if (fullFeatures != newVal && newVal) {
		//[self setupOpenFeint];
	}
	
	fullFeatures = newVal;	
}

#pragma mark -
#pragma mark Launch and setup, terminate and dealloc
- (void)initStatsForMode:(NSInteger)mode {
	// read stats (if any)
	NSMutableArray **p2Stats = (mode == gameModeI ? &statsModeI : &statsModeII);
	NSString *key = (mode == gameModeI ? kStatsModeIKey : kStatsModeIIKey);
	*p2Stats = [self getDecodedObjectForKey:key];
	if (!(*p2Stats)) {
		*p2Stats = [[NSMutableArray alloc] initWithCapacity:STATS_CAPACITY];
	}
	
#if 0//DEBUGFULL
	NSLog(@"\nInit stats for mode: %d", mode);
	for (StatsEntry *entry in *p2Stats) {
		printf("\n%s", [[entry debugStr] UTF8String]);
	}
#endif	
}

- (void)setupGameModel {
	// init with nil
	projectileWorker = nil;
	projectileObserver = nil;
	helperWorker = nil;
	statsModeI = nil;
	statsModeII = nil;
	
	// read workers and observers (when needed) from user defaults
	
	// helper worker (simple, but still store and recover)
	helperWorker = [self getDecodedObjectForKey:kHelperWorkerKey];
	if (!helperWorker) {
		helperWorker = [[HelperWorker alloc] init];
	}
	
	// projectile worker (read from user defaults)
	projectileWorker = [self getDecodedObjectForKey:kProjectileWorkerKey];
	if (!projectileWorker) {
		projectileWorker = [[ProjectileWorker alloc] init];
		projectileWorker.delegate = [[SimpleProjectileWorkerDelegate alloc] init];
	}
	
	// projectile observer (read from user defaults)
	projectileObserver = [self getDecodedObjectForKey:kProjectileObserverKey];
	if (!projectileObserver) {
		projectileObserver = [[ProjectileObserver alloc] init];
	}
	
	// setup workers and observers relationships
	// helper worker --> view controller
	helperWorker.observerViewController = gameViewController;
	// projectile worker --> projectile observer
	projectileWorker.observer = projectileObserver;
	// projectile observer --> projectile worker, view controller, helper worker
	projectileObserver.projectileWorker = projectileWorker;
	projectileObserver.observerViewController = gameViewController;
	projectileObserver.helperWorker = helperWorker;
	
	// init stats for game modes
	[self initStatsForMode:gameModeI];
	[self initStatsForMode:gameModeII];
}

- (void)setupGameId {
	// modify used prefixes
	// also provide another prefixes array for compatibility issues
	
	// setup the game prefixes, note, these prefixes must match to 
	// the used bundle ids, to be more correct, the bundle ids must be chosen
	// only amongst these prefixes
	gamePrefixesDic = [[NSDictionary alloc] initWithObjectsAndKeys:
					   @"The_Eggs", [NSNumber numberWithInteger:gameID_TheEggs],
					   @"The_Eggs_HD", [NSNumber numberWithInteger:gameID_TheEggsHD],
					   @"The_Wolf", [NSNumber numberWithInteger:gameID_TheWolf],
					   @"The_Hunt", [NSNumber numberWithInteger:gameID_TheHunt],
					   @"The_Hockey", [NSNumber numberWithInteger:gameID_TheHockey],
					   @"The_Cat", [NSNumber numberWithInteger:gameID_TheCat],
					   @"The_Space_Explorers", [NSNumber numberWithInteger:gameID_TheSpaceExplorers],
					   @"The_Space_Flight", [NSNumber numberWithInteger:gameID_TheSpaceFlight],
					   @"Bulls_and_Bears", [NSNumber numberWithInteger:gameID_BullsAndBears],
					   @"The_Catching", [NSNumber numberWithInteger:gameID_TheCatching], 
					   /* obsolete *///@"The_Eggs_Lite", [NSNumber numberWithInteger:gameID_TheEggsLite],
					   /* lite->pro */  @"The_Eggs_Lite", [NSNumber numberWithInteger:gameID_TheEggsPro],
					   nil];
	
	// init with unknown id first
	gameId = gameID_Unknown;
	
	// gameId is defined by the bundle id
	NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	NSString *gamePrefix = [[bundleId componentsSeparatedByString:@"."] lastObject];
	//	gamePrefix = @"thewolf";    // DEBUG
	NSArray *keysArray = [gamePrefixesDic allKeysForObject:gamePrefix];
	if (keysArray && keysArray.count > 0) {
		gameId = [[keysArray objectAtIndex:0] integerValue];
	}
	
	// backwards compatibility issue for old bundle identifiers like TheEggs, TheWolf, etc...
	// and shit, I've messed up, the '_' is not allowed for bundle id on device
	// so this array has readl identifiers
	if (gameId == gameID_Unknown) {
		NSDictionary *oldGamePrefixesDic = [[NSDictionary alloc] initWithObjectsAndKeys:
											@"TheEggs", [NSNumber numberWithInteger:gameID_TheEggs], 
											@"TheWolf", [NSNumber numberWithInteger:gameID_TheWolf],
											@"TheHunt", [NSNumber numberWithInteger:gameID_TheHunt],
											@"TheHockey", [NSNumber numberWithInteger:gameID_TheHockey],
											@"TheCat", [NSNumber numberWithInteger:gameID_TheCat],
											@"TheSpaceExp", [NSNumber numberWithInteger:gameID_TheSpaceExplorers],
											@"TheSpaceFl", [NSNumber numberWithInteger:gameID_TheSpaceFlight],
											@"TheEggsHD", [NSNumber numberWithInteger:gameID_TheEggsHD],
											@"TheCatching", [NSNumber numberWithInteger:gameID_TheCatching],
											@"BullsAndBears", [NSNumber numberWithInteger:gameID_BullsAndBears],
											/*obsolete*///@"TheEggsLite", [NSNumber numberWithInteger:gameID_TheEggsLite],
											/* pro */		@"TheEggsLite", [NSNumber numberWithInteger:gameID_TheEggsPro],											
											nil];
		
		NSArray *oldKeysArray = [oldGamePrefixesDic allKeysForObject:gamePrefix];
		if (oldKeysArray && oldKeysArray.count > 0) {
			gameId = [[oldKeysArray objectAtIndex:0] integerValue];
		}
		
		// release the dictionary
		[oldGamePrefixesDic release];
	}
	
#if 0//DEBUGFULL	
	NSString *bundleDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	
	NSLog(@"\nDisplay name: %@, Name: %@, ID: %@ Prefix: %@ game ID: %d", bundleDisplayName, bundleName, bundleId, gamePrefix, gameId);
#endif
	
	// read current game id from user defaults
	// DEBUG: use next line to clear prefix problems
	//currentGameId = gameId;	// DEBUG
	
	currentGameId = [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentGameIdKey];
	// why are we so sure that at first start the 0 is always read?
	// maybe this is a possible reason for all reported crashes on game start up
	// so, to close this question once and for all, make a full check here
	BOOL validGameId = FALSE;
	for (NSNumber *key in [gamePrefixesDic allKeys]) {
		if (currentGameId == [key integerValue]) {
			validGameId = TRUE;
			break;
		}
	}
	
	//currentGameId = gameID_TheWolf;	// DEBUG
	
	// correct invalid game id
	if (!validGameId || currentGameId == gameID_Unknown) {
		// by default set to the wolf (the eggs?) in case of all in one and to game id for single version
		currentGameId = ((gameId == gameID_TheCatching || gameId == gameID_TheEggsPro) ? gameID_TheEggs : gameId);
	}
	
	// save the old game id (for all-in-one collection)
	oldGameId = currentGameId;	
	
	// store current game id to user defaultss
	NSDictionary *curGameIdDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:currentGameId] forKey:kCurrentGameIdKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:curGameIdDict];
}

- (void)setupProVersion {
	// read the full features flag from user defaults
	fullFeatures = [[[NSUserDefaults standardUserDefaults] objectForKey:kFullFeaturesKey] boolValue];
	// register fullFeatures flag with user defs
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:fullFeatures] forKey:kFullFeaturesKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
	
	if (gameId == gameID_TheEggs || gameId == gameID_TheCatching) {
	    // for original (old) The Eggs and The Catching fullFeatures enabled by default
		fullFeatures = TRUE;
	}
	
	// TEST
	fullFeatures = FALSE;
	
	// initialize open feint
	//[self setupOpenFeint];
	
	// read the submitOnUpgrade flag from user defaults
	submitOnUpgrade= [[[NSUserDefaults standardUserDefaults] objectForKey:kSubmitOnUpgradeKey] boolValue];
	// register submitOnUpgrade flag with user defs
	dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:submitOnUpgrade] forKey:kSubmitOnUpgradeKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
	
	// check if scores have been submitted after upgrade
	if (fullFeatures && !submitOnUpgrade) {
		// submit best scores for mode 1 and mode 2 to open feint
		// stats are already sorted out, so use 1st element
		if (statsModeI.count > 0) {
			[self submitPoints:((StatsEntry *)[statsModeI objectAtIndex:0]).points 
					   forMode:gameModeI];
		}
		if (statsModeII.count > 0) {
			[self submitPoints:((StatsEntry *)[statsModeII objectAtIndex:0]).points 
					   forMode:gameModeII];
		}
		submitOnUpgrade = TRUE;
	}
	
	// read the full skins flag from user defaults
	fullSkins = [[[NSUserDefaults standardUserDefaults] objectForKey:kFullSkinsKey] boolValue];
	// register fullSkins flag with user defs
	dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:fullSkins] forKey:kFullSkinsKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];	
}

- (GameViewController *)getGameViewController:(NSInteger)curGameId {
	GameViewController *loadedView = nil;
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *prefix = [gamePrefixesDic objectForKey:[NSNumber numberWithInteger:curGameId]];
	NSString *nibName = [prefix stringByAppendingString:@"-ViewController"];
	if (curGameId & gameType_Simple) {
		loadedView = [[GameViewController alloc] initWithNibName:nibName bundle:bundle];
	} else if (curGameId & gameType_Wide) {
		loadedView = [[WideGameViewController alloc] initWithNibName:nibName bundle:bundle];
	} else if (curGameId & gameType_Custom) {
		// dig in and check which of the custom classes to load
		NSLog(@"Invalid current game ID: %d", curGameId);
	}
	
	return [loadedView autorelease];
}

- (AboutViewController *)getAboutViewController:(NSInteger)theGameId {
	AboutViewController *localAboutViewCtl = nil;

	localAboutViewCtl = [[TheEggsProAboutViewController alloc] initWithNibName:@"The_Eggs_Pro-AboutView" bundle:[NSBundle mainBundle]];			
	
	return [localAboutViewCtl autorelease];
}

- (UINavigationController *)getNavigationCtlWithRootCtl:(UIViewController *)rootCtl {
	// about navigation controller
	UINavigationController *localNavCtl = [[UINavigationController alloc] initWithRootViewController:rootCtl];
	[localNavCtl setNavigationBarHidden:YES];
	localNavCtl.navigationBar.barStyle = UIBarStyleBlackTranslucent;

	[ViewTransformer rotateToLandscapeRightAndResize:localNavCtl.view];
	
	return [localNavCtl autorelease];
}

- (void)setupViewControllers {
	// setup main window and UI
	// load game view controller specific for current game
	gameViewController = [[self getGameViewController:currentGameId] retain];
	gameViewController.appDelegate = self;
	[window addSubview:gameViewController.view];
	// setup user interface and sounds
	[gameViewController setupUserInterface];
	[gameViewController setupSounds];
	
	// about view controller and navigation view controller
	// check current application and load specific about view
 	aboutViewController = [[self getAboutViewController:gameId] retain];
	//[ViewTransformer rotateToLandscapeRight:aboutViewController.view];
	// get the about navigation controller adjusted to current screen geometry
	aboutNavigationController = [[self getNavigationCtlWithRootCtl:aboutViewController] retain];

#ifdef DISKOTEKA_90
	diskotekaViewController = [[DiskotekaViewController alloc] initWithNibName:@"DiskotekaViewController" bundle:[NSBundle mainBundle]];
	[ViewTransformer rotateToLandscapeRight:diskotekaViewController.view];
#endif

}

- (void)setupGamesIdList {
	gamesIdList = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:gameID_TheEggs],
				   [NSNumber numberWithInteger:gameID_TheEggsHD],
				   //[NSNumber numberWithInteger:gameID_TheWolf],   // remove due to possible legal issues
				   [NSNumber numberWithInteger:gameID_TheHunt],
				   [NSNumber numberWithInteger:gameID_TheCat],
				   [NSNumber numberWithInteger:gameID_TheHockey],
				   [NSNumber numberWithInteger:gameID_TheSpaceFlight],
				   [NSNumber numberWithInteger:gameID_TheSpaceExplorers],
				   nil];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	// Override point for customization after app launch   
	
	// setup game Id together with current game id (may be different)
	[self setupGameId];
	
	// setup pro version (purchases)
	[self setupProVersion];
	
	// setup view controllers
	[self setupViewControllers];
	
//	fullFeatures = TRUE;	// TEST
//	fullSkins = TRUE;	// TEST
//	if (fullFeatures) {
	[self setupOpenFeint];
//	}
	
	// setup / recover game model elements, do it before reading game state
	[self setupGameModel];
	
	// for recovery case: update the game mode, read from delegate
	[gameViewController updateMode:[[projectileWorker delegate] mode]];
	
	// read game state from user defaults
	gameState = [[[NSUserDefaults standardUserDefaults] objectForKey:kGameStateKey] integerValue];
	// make sure the game state value is valid
	if (gameState < stateReady || gameState >= stateTotal) {
		gameState = stateReady;
	}
	// update to user defaults
	NSDictionary *stateDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:gameState] forKey:kGameStateKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:stateDict];
	
	// the "unpausing" state should be replaced with "paused"
	if (gameState == stateUnpausing) gameState = statePaused;
	
	// why not... let's try to recover to replay mode, it also allows to avoid gameover/replay/popo bug
	if (gameState == stateReplaying) gameState = stateReplay;
	
	// recovery case: one last moment, if number of penalties is over the top
	// then recovery in gameOver state
	if ([projectileObserver gameIsOver]) gameState = stateGameOver;
	
#if 0		// Let the lite version have pause and autrosave
	// if this is a lite version, then default game state to game over
	if (gameId == gameID_TheEggsLite) gameState = stateGameOver;
#endif	
	
	// update to view
	[gameViewController updatePause:(gameState == statePaused ? TRUE : FALSE)];
	[gameViewController updatePauseCount:[NSArray arrayWithObjects:[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:(-1)], nil]];
	
	// we've just read a game state, so update it to view controller again
	[gameViewController displayControlsForState:gameState];
	
	// catcher position
	NSInteger catcherPosition = [[NSUserDefaults standardUserDefaults] integerForKey:kCatcherPositionKey];
	NSDictionary *catcherPosDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:catcherPosition] forKey:kCatcherPositionKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:catcherPosDic];
	[gameViewController catcherAction:[NSNumber numberWithInteger:catcherPosition]];
	
	// read the sound settings from user defaults
	soundOn = [[[NSUserDefaults standardUserDefaults] objectForKey:kSoundOnKey] boolValue];
	// register sound settings with user defs
	NSDictionary *soundDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:soundOn] forKey:kSoundOnKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:soundDict];
	// update sound settings to view
	[gameViewController updateSound:soundOn];
	
	// read the replay settings from user defaults
	replayOn = [[[NSUserDefaults standardUserDefaults] objectForKey:kReplayOnKey] boolValue];
	// register sound settings with user defs
	NSDictionary *replayDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:soundOn] forKey:kReplayOnKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:replayDict];
	// update sound settings to view
	[gameViewController updateReplay:replayOn];	
	
	// read nickName and emailKey form user defaults
	// if nothing read, then init with @""
	// read country as well, if nil, set with current locale region selection
	nickName = [[NSUserDefaults standardUserDefaults] objectForKey:kNickNameKey];
	if (nickName == nil) nickName = @"";
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:nickName forKey:kNickNameKey]];
	
	emailKey = [[NSUserDefaults standardUserDefaults] objectForKey:kEmailKeyKey];
	if (emailKey == nil) emailKey = @"";
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:emailKey forKey:kEmailKeyKey]];
	
	countryCode = [[NSUserDefaults standardUserDefaults] objectForKey:kCountryCodeKey];
	if (countryCode == nil) {
		countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
	}
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:countryCode forKey:kCountryCodeKey]];
	
	[window makeKeyAndVisible];
	
	// initialize random number generator
	unsigned seed = (unsigned) [[NSDate  date] timeIntervalSinceReferenceDate];
	srandom(seed); 
	
	// sync all updated user defaults
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// setup countries display list
	[self setupCountriesDisplayList];
	
	// setup games id list (for all-in-one collection)
	[self setupGamesIdList];
}

- (void)dealloc {
    [gameViewController release];
	[aboutViewController release];
	[aboutNavigationController release];
	[projectileWorker release];
	[projectileObserver release];
	[helperWorker release];
	[statsModeI release];
	[statsModeII release];
	[nickName release];
	[emailKey release];
	[countryCode release];
	[countriesDisplayList release];
	[countriesIndexLetters release];
	[gamePrefixesDic release];
    [window release];
    [super dealloc];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// pause game, save all settings and game progress
	// pause the game
	if (gameState == stateRunning) {
		[self gamePause:nil];
	}
	
	// sound setting
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:soundOn] forKey:kSoundOnKey];
	
	// replay setting
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:replayOn] forKey:kReplayOnKey];	
	
	// game state
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:gameState] forKey:kGameStateKey];
	
	// catcher position
	[[NSUserDefaults standardUserDefaults] setInteger:gameViewController.catcherPosition forKey:kCatcherPositionKey];
	
	// helper worker (same key for encoding and user defaults)
	[[NSUserDefaults standardUserDefaults] setObject:[self getEncodedDataForObject:helperWorker forKey:kHelperWorkerKey] forKey:kHelperWorkerKey];	
	
	// projectile worker (same key for encoding and user defaults)
	[[NSUserDefaults standardUserDefaults] setObject:[self getEncodedDataForObject:projectileWorker forKey:kProjectileWorkerKey] forKey:kProjectileWorkerKey];
	
	// projectile observer (same key for encoding and user defaults)
	[[NSUserDefaults standardUserDefaults] setObject:[self getEncodedDataForObject:projectileObserver forKey:kProjectileObserverKey] forKey:kProjectileObserverKey];
	
	// stats (top 10) for modes A and B
	[[NSUserDefaults standardUserDefaults] setObject:[self getEncodedDataForObject:statsModeI forKey:kStatsModeIKey] forKey:kStatsModeIKey];
	[[NSUserDefaults standardUserDefaults] setObject:[self getEncodedDataForObject:statsModeII forKey:kStatsModeIIKey] forKey:kStatsModeIIKey];
	
	// save nickname, email/key and country
	[[NSUserDefaults standardUserDefaults] setObject:nickName forKey:kNickNameKey];
	[[NSUserDefaults standardUserDefaults] setObject:emailKey forKey:kEmailKeyKey];
	[[NSUserDefaults standardUserDefaults] setObject:countryCode forKey:kCountryCodeKey];
	
	// save current game type
	[[NSUserDefaults standardUserDefaults] setInteger:currentGameId forKey:kCurrentGameIdKey];
	
	// full features
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:fullFeatures] forKey:kFullFeaturesKey];
	
//	if (fullFeatures) {
	[OpenFeint shutdown];
//	}
	
	// full skins
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:fullSkins] forKey:kFullSkinsKey];
	
	// submit on upgrade
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:submitOnUpgrade] forKey:kSubmitOnUpgradeKey];	
}


#pragma mark -
#pragma mark Debuggin controls
- (void)suspendProjectileWorker:(id)sender; {
	[projectileWorker suspend];
	[helperWorker suspend];
}

- (void)resumeProjectileWorker:(id)sender {
	[projectileWorker resume];
	[helperWorker resume];
}

- (void)resetProjectileWorker:(id)sender {
	[projectileWorker reset];
}

- (void)restartProjectileWorker:(id)sender {
	[projectileWorker restart];
}

- (void)toggleCatchAllFlag:(id)sender {
	projectileObserver.catchAll = !projectileObserver.catchAll;
}

#pragma mark Stats
- (void)updateStatsForMode:(NSInteger)mode {
	if (projectileObserver.points == 0) return;	// ignore 0 points stats
	
	NSMutableArray *stats = (mode == gameModeI ? statsModeI : statsModeII);
	StatsEntry *lastEntry = [stats lastObject];
	if (!lastEntry	// empty stats
		|| stats.count < STATS_CAPACITY	// stats not full
		|| projectileObserver.points > lastEntry.points
		|| projectileObserver.points == lastEntry.points 
		&& projectileObserver.pauseCnt < lastEntry.pauses) 
	{
		// make new stats entry
		StatsEntry *newEntry = [[StatsEntry alloc] initWithProjectileObserver:projectileObserver mode:[[projectileWorker delegate] mode]];
		
		if (stats.count >= STATS_CAPACITY) {	// over capacity, remove last
			[stats removeLastObject];
		}
		// add new entry
		[stats addObject:newEntry];
		[newEntry release];
		
		// sort the stats array
		[stats sortUsingSelector:@selector(statsComparator:)];
	}
}

- (void)submitPoints:(NSInteger)points forMode:(NSInteger)mode {
	if (mode == gameModeI) {
		// update score to leaderboard (may depend on game id)
		[OFHighScoreService setHighScore:points forLeaderboard:@"<YOUR-LB-ID>" onSuccess:OFDelegate() onFailure:OFDelegate()];
		
		if (fullFeatures) {
			// unlock achievements (if any)
			if (points >= 1000) {
				// unlock "Eggstaordinary!" achievement            
				[OFAchievementService unlockAchievement:@"<YOUR-ACH-ID>"];
			}
			if (points >= 1500) {
				// unlock "Eggsclusive!" achievement            
				[OFAchievementService unlockAchievement:@"<YOUR-ACH-ID>"];				
			}			
			if (points >= 2000) {
				// unlock "Eggs Master" achievement
				[OFAchievementService unlockAchievement:@"<YOUR-ACH-ID>"];				
			} 
		}
	} else if (mode == gameModeII) {    // game mode II
		// update score to leaderboard (may depend on game id)
		[OFHighScoreService setHighScore:projectileObserver.points forLeaderboard:@"<YOUR-LB-ID>" onSuccess:OFDelegate() onFailure:OFDelegate()];
		
		if (fullFeatures) {
			// unlock achievements (if any)
			if (points >= 1000) {
				// unlock "Eggstaordinary!" achievement            
				[OFAchievementService unlockAchievement:@"<YOUR-ACH-ID>"];
			}
			if (points >= 1500) {
				// unlock "Eggsclusive!" achievement            
				[OFAchievementService unlockAchievement:@"<YOUR-ACH-ID>"];				
			}			
			if (points >= 2000) {
				// unlock "Eggs Master" achievement
				[OFAchievementService unlockAchievement:@"<YOUR-ACH-ID>"];				
			}    
		}
	}       
}

#pragma mark View flipping
- (void)flipFromView:(UIView *)fromView 
			  toView:(UIView *)toView 
		   direction:(NSInteger)direction 
{
	NSString *animationID = [NSString stringWithFormat:@"viewFlipAnimationID"];
	
	[UIView beginAnimations:animationID context:NULL];
	[UIView setAnimationDuration:0.75];	
	[UIView setAnimationTransition:(direction > 0 ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:window cache:YES];
	
	// do the actual view changing
	UIView *superView = [fromView superview];
	if (superView) {	// safety code
		[fromView removeFromSuperview];
		[superView addSubview:toView];
		//[superView addSubview:fromView];
	}
	//	[UIView setAnimationDelegate:[params objectAtIndex:2]];
	//		[UIView setAnimationDidStopSelector:@selector(viewAnimationDidStop:finished:context:)];
	//	[UIView setAnimationDidStopSelector:NSSelectorFromString([params objectAtIndex:3])];
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Game controls
- (void)gameStart:(NSInteger)mode {
    // ignore if game is already in progress
    if (gameState == stateRunning || gameState == statePaused) return;
	
    // ignore if game is in replay mode
    if (gameState == stateReplay || gameState == stateReplaying) return;
	
    // set the game mode
    [[projectileWorker delegate] setMode:mode];
	
	// update game mode view
	[gameViewController updateMode:mode];
	
	// reset and start the workers
	@try {
		// reset (the order is important, reset observer after workers)
		[projectileWorker reset];
		[helperWorker reset];
		[projectileObserver reset];
		
		[projectileWorker suspend];
		[helperWorker suspend];
		
		// start (use resume, cause it is good for restarting sleeping threads)
		[projectileWorker start];   // projectile worker
		[helperWorker start];   // helper worker
		
		gameState = stateRunning;   // udpate game state
		[gameViewController displayControlsForState:gameState]; // update game controls
	}
	@catch (NSException * e) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:e.name 
															message:e.description 
														   delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
												  otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)gameOver:(id)sender {
    // stop/suspend everyone, change game state
    [projectileWorker suspend];
    [helperWorker suspend];	// same as stop
    gameState = stateGameOver;
	
    //update controls for new state
    [gameViewController displayControlsForState:gameState];
	
    [self updateStatsForMode:[[projectileWorker delegate] mode]]; // update stats
	
	// TEST
	//projectileObserver.points = 1100;
	
	[self submitPoints:projectileObserver.points forMode:[[projectileWorker delegate] mode]];


}

- (void)resumeGame:(id)param {
	// fix the resume after crash issue here
	if ([projectileObserver gameIsOver]) {
		[self gameOver:nil];
		return;
	}
	
	// resume game (its workers)
	[projectileWorker resume];
	[helperWorker resume];
	
	gameState = stateRunning;
	
	// update indicator view
	[gameViewController updatePause:FALSE];
	
	// update controls for new state
	[gameViewController displayControlsForState:gameState];
}

- (void)gamePause:(id)sender {
    if (gameState != stateRunning) return;
	
	// pause the game (its workers)
	[projectileWorker suspend];
	[helperWorker suspend];
	
	gameState = statePaused;    // udpate game state 
	
	// update indicator view
	[gameViewController updatePause:TRUE];
	
	// update controls for new state
	[gameViewController displayControlsForState:gameState];
	
	projectileObserver.pauseCnt++;	// increase pause count
}

- (void)gameResume:(id)sender {
	if (gameState != statePaused) return;
	
	gameState = stateUnpausing;
	
	// update controls for new state
	[gameViewController displayControlsForState:gameState];
	
	for (int i = 0; i < 4; i++) {
		[gameViewController performSelector:@selector(updatePauseCount:) 
								 withObject:[NSArray arrayWithObjects:
											 [NSNumber numberWithInteger:(3 - i)], 
											 [NSNumber numberWithInteger:[[projectileWorker delegate] queuedTrajectory:i]],
											 nil]
								 afterDelay:(i * 0.5)];		
	}
	
	[self performSelector:@selector(resumeGame:) withObject:nil afterDelay:2.0];
}

- (void)gameSoundOn:(id)on {
	// allow sound property changing even in replay mode
	// JUST A NOTE: if (gameState == stateReplay || gameState == stateReplaying) return; // TO DO: consider playing a denial sound here
	soundOn = [on boolValue];
	[gameViewController updateSound:soundOn];
}

- (void)gameReplayOn:(id)on {
    // for now, allow changing replay option in replay mode 
    // maybe for some game views the replay button will be hidden completely
    // JUST A NOTE: if (gameState == stateReplay || gameState == stateReplaying) return;    // TO DO: consider playing a denial sound here
    replayOn = [on boolValue];
    [gameViewController updateReplay:replayOn];
}

- (void)displayGameInfo:(id)show {
	// no need to pause here, the game is already paused on touch down event
	//[self gamePause:nil];
	
	// the game may be unpausing at the moment, ignore touch for unappropriate states
	// this check also guarantees that info touch will be ignored in replay mode
	if (gameState != statePaused && gameState != stateReady && gameState != stateGameOver) { 
		// can't show info in this state
		return;
	}
	
	//show/hide info view here	
	BOOL showFlag = [show boolValue];
	UIView *fromView = (showFlag ? gameViewController.view : aboutNavigationController.view);
	UIView *toView = (!showFlag ? gameViewController.view : aboutNavigationController.view);
	NSInteger direction = (showFlag ? -1 : 1);
	[self flipFromView:fromView toView:toView direction:direction];
}

- (void)openFeintAction:(id)sender {
	// no need to pause here, the game is already paused on touch down event
//	if (fullFeatures) {
	[OpenFeint launchDashboard];
//	}
}

#ifdef DISKOTEKA_90
- (void)displayDiskotekaPromo:(id)show {
	if (gameState != statePaused && gameState != stateReady && gameState != stateGameOver) { 
		// can't show info in this state
		return;
	}
	
	//show/hide info view here	
	BOOL showFlag = [show boolValue];
	UIView *fromView = (showFlag ? gameViewController.view : diskotekaViewController.view);
	UIView *toView = (!showFlag ? gameViewController.view : diskotekaViewController.view);
	NSInteger direction = (showFlag ? -1 : 1);
	[self flipFromView:fromView toView:toView direction:direction];	
}
#endif

#pragma mark -
#pragma mark Replay mode controls
- (void)enterReplayModeAction:(id)sender {
    if (gameState != stateRunning) return;
	
    // need to block all controls except replay controls, do it by setting replay game state
    gameState = stateReplay;
	
	// just the right time to suspend helper worker
	[helperWorker suspend];
	
    // backup projectile observer's state
    [projectileObserver backupState];
	
    // display replay controls/views here
    // delegate this work to game view controller, so it can vary it's implementation
    [gameViewController displayControlsForState:gameState];
	
    // that's it, now the replay can be started using one of displayed controls
}

- (void)replayActionThread:(id)sender {
    // do the replay loop here checking game state each iteration
	
	// may be detached as a thread, so need autorelease pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	stopReplaying = NO;
	NSInteger i = 0;
    for (TimeFrame *timeFrame in projectileObserver.replayData.timeFrames) {
        // if replaying has been cancelled, the stop
        if (stopReplaying) {
            break;
        }
		
#if 0//DEBUGFULL	
		printf("\n\nreplay tick no:%d", i);
		[timeFrame.projectileWorkerDelegate printOut];
#endif
		
		// replay the tick with a small pause
		[NSThread sleepForTimeInterval:0.5];
		[projectileObserver notifyTick:timeFrame];
		
        // if replaying has been cancelled, the stop
        if (stopReplaying) {
            break;
        }
		
        // increase it
		i++;
    }
	
    // replaying stopped, back to "replay" status
    gameState = stateReplay;
	
    // update the game controls for new state
    [gameViewController displayControlsForState:gameState];
	
	[pool release];	// so long, autorelease pool
}

- (void)startReplayAction:(id)sender {
    if (gameState != stateReplay) return;
    
    // start the replay
    gameState = stateReplaying;
	
	// update the game controls for new state
    [gameViewController displayControlsForState:gameState];
	
	// this is a main thread which updates UI, so go to another thread to do replaying and give control back to main thread
	[NSThread detachNewThreadSelector:@selector(replayActionThread:) toTarget:self withObject:sender];
}

- (void)stopExitReplayAction:(id)sender {
	if (gameState == stateReplay) {
		[self exitReplayModeAction:sender];
	} else if (gameState == stateReplaying) {
		[self stopReplayAction:sender];
	}
}

- (void)stopReplayAction:(id)sender {
    if (gameState != stateReplaying) return;
	
	stopReplaying = YES;
	/*	
	 // stop the replay (the state will be checked in next iteration of startReplayAction)
	 gameState = stateReplay;
	 
	 // update the game controls for new state
	 [viewController displayControlsForState:gameState];
	 */
}

- (void)exitReplayModeAction:(id)sender {
	if (gameState != stateReplay) return;
    // replay is over, change game state
    gameState = stateRunning;
	
    // update the game controls for new state
    // delegate this work to game view controller, so it can vary it's implementation
    [gameViewController displayControlsForState:gameState];
	
    // restore projectile observer's state
    [projectileObserver restoreState];
	
	// let the helper go
	[helperWorker resume];
	
    // resume the game after crash
    [projectileObserver resumeAfterCrash];
}

#pragma mark -
#pragma mark Properties and settings
- (NSString *)currentGamePrefix {
	return [gamePrefixesDic objectForKey:[NSNumber numberWithInteger:currentGameId]];	
}

- (NSString *)gamePrefixForId:(NSInteger)theGameId {
	return [gamePrefixesDic objectForKey:[NSNumber numberWithInteger:theGameId]];
}

- (NSString *)currentSoundPrefix {
	return [self soundPrefixForId:currentGameId];
}

- (NSString *)soundPrefixForId:(NSInteger)theGameId {
	if (theGameId == gameID_BullsAndBears) return @"Bulls_and_Bears-";
	return @"";
}

- (NSString *)gameDescription {
	if (gameId == gameID_TheCatching) {
		return NSLocalizedString(@"The Catching Description", @"The Catching Description");
	} else if (gameId == gameID_TheWolf) {
		return NSLocalizedString(@"The Wolf Description", @"The Wolf Description");
	} else if (gameId == gameID_TheEggsLite) {
		return NSLocalizedString(@"The Eggs Lite Description", @"The Eggs Lite Description");	
	} else if (gameId == gameID_TheEggsPro) {
		return NSLocalizedString(@"The Eggs Pro Description", @"The Eggs Pro Description");
	}
	
	return NSLocalizedString(@"Soviet Catcher Description", @"Soviet Catcher Description");
}

#pragma mark -
#pragma mark System message handlers
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	if (gameState == stateRunning) {
		[self gamePause:nil];
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//	if (fullFeatures) {
	[OpenFeint applicationDidBecomeActive];
//	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	if (gameState == stateRunning) {
		[self gamePause:nil];
	}	
	
//	if (fullFeatures) {
	[OpenFeint applicationWillResignActive];
//	}
}

@end
