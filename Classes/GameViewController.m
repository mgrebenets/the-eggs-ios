//
//  GameViewController.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/11/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "GameViewController.h"
#import "The_EggsAppDelegate.h"
#import "ViewTransformer.h"
#import <QuartzCore/QuartzCore.h>
#import "SoundEffect.h"

/* This class has default implementation common for all nintendo-like games
 * There's no need to make custom classes for nintendo-like games
 * Other games like "Bulls & Bears" must inherit this class and overload 
 * specific methods 
 */

// direction enum (matches the trajectory ids)
enum {
	bottomLeft = 0,
	topLeft,
	topRight,
	bottomRight,
	catcherPosTotal
};

@implementation GameViewController

@synthesize appDelegate;
@synthesize catcherPosition;

#pragma mark Auxiliary methods for delegate properties
- (NSInteger)currentGameState {
	return  [appDelegate gameState];
}

#pragma mark Debug control actions
- (IBAction)suspend:(id)sender {
	[appDelegate suspendProjectileWorker:nil];
}

- (IBAction)resume:(id)sender {
	[appDelegate resumeProjectileWorker:nil];
}

- (IBAction)reset:(id)sender {
	[appDelegate resetProjectileWorker:nil];
}

- (IBAction)restart:(id)sender {
	[appDelegate restartProjectileWorker:nil];
}

- (IBAction)catchAllAction:(id)sender {
	[appDelegate toggleCatchAllFlag:nil];	
}

#pragma mark Catcher control actions
- (void)catcherAction:(NSNumber *)direction {
	// allow changing position of catcher, the block should be put in button controllers
	catcherPosition = [direction integerValue];
	if (catcherPosition < 0 || catcherPosition >= catcherPosTotal) return;
	
	for (UIView *catcherView in catcherViews) {
		catcherView.hidden = YES;
	}
	
	((UIView *)[catcherViews objectAtIndex:2 + catcherPosition]).hidden = NO;
	((UIView *)[catcherViews objectAtIndex:catcherPosition / 2]).hidden = NO;
}

- (IBAction)topLeftAction:(id)sender {
	// ignore in replay mode
	if ([self currentGameState] == stateReplay || [self currentGameState] == stateReplaying) return;
	[self catcherAction:[NSNumber numberWithInteger:topLeft]];
}

- (IBAction)bottomLeftAction:(id)sender {
	// ignore in replay mode
	if ([self currentGameState] == stateReplay || [self currentGameState] == stateReplaying) return;

	[self catcherAction:[NSNumber numberWithInteger:bottomLeft]];
}

- (IBAction)topRightAction:(id)sender {
	// ignore in replay mode
	if ([self currentGameState] == stateReplay || [self currentGameState] == stateReplaying) return;
	[self catcherAction:[NSNumber numberWithInteger:topRight]];
}

- (IBAction)bottomRightAction:(id)sender {
	// ignore in replay mode
	if ([self currentGameState] == stateReplay || [self currentGameState] == stateReplaying) return;	
	[self catcherAction:[NSNumber numberWithInteger:bottomRight]];
}

#pragma mark Game control actions
- (void)gameStartAction:(NSInteger)mode {
    [appDelegate gameStart:mode];
}

- (IBAction)gameAAction:(id)sender {
    [self gameStartAction:gameModeI];
}

- (IBAction)gameBAction:(id)sender {
    [self gameStartAction:gameModeII];
}

- (IBAction)gamePauseAction:(id)sender {
	NSInteger gameState = [self currentGameState];
	if (gameState == stateRunning) {
		[appDelegate gamePause:nil];
	} else if (gameState == statePaused) {
		[appDelegate gameResume:nil];
	}
	// for other states, like "game over" or "replay" the action is just ignored
	// probably it'd be appropriate to play some blocking sound here
}

- (IBAction)gameSoundAction:(id)sender {
	BOOL soundOn = [appDelegate soundOn];
	[appDelegate gameSoundOn:[NSNumber numberWithBool:!soundOn]];
}

- (IBAction)gameReplayAction:(id)sender {
	BOOL replayOn = [appDelegate replayOn];
	[appDelegate gameReplayOn:[NSNumber numberWithBool:!replayOn]];
}

- (IBAction)buttonTouchDownAction:(id)sender {
	[appDelegate gamePause:nil];
}

- (IBAction)gameInfoAction:(id)sender {
    [appDelegate displayGameInfo:[NSNumber numberWithBool:YES]];
}

- (IBAction)gameStatsAction:(id)sender {
    [appDelegate openFeintAction:self];	
}

#ifdef DISKOTEKA_90
- (IBAction)diskotekaAction:(id)sender {
	[appDelegate displayDiskotekaPromo:[NSNumber numberWithBool:YES]];
}
#endif


#pragma mark Replay control methods and actions
- (IBAction)gameReplayStartAction:(id)sender {
	[appDelegate startReplayAction:sender];
}

- (IBAction)gameReplayStopExitAction:(id)sender {
	[appDelegate stopExitReplayAction:sender];
}

#pragma mark Display controls for specific state
// overload this method in subclasses to customize controls appearance
- (void)displayControlsForState:(NSInteger)state {
    // customize the views and controls for given game state
    // this is a "narrow" game view implementaion, so only cases related to replay mode are important
	
	// navigation controls
	[self displayNavigationControlsForState:state];
	
	// pause controls
	[self displayPauseControlsForState:state];
	
    // replay controls
    [self displayReplayControlsForState:state];
}

- (void)displayNavigationControlsForState:(NSInteger)state {
	// nothing for narrow game
}

- (void)displayPauseControlsForState:(NSInteger)state {
	// narrow view
	pauseIconView.hidden = !(state == statePaused || state == stateUnpausing);
}

// overload this method in subclasses to customize controls appearance
- (void)displayReplayControlsForState:(NSInteger)state {
    // show/hide replay mode controls
    BOOL showReplayControls = (state == stateReplay || state == stateReplaying);
    replayLabelView.hidden = !showReplayControls;
    replayStartButton.hidden = !showReplayControls;
    replayStopExitButton.hidden = !showReplayControls;
	
    // find a way to customize button images, to allow all subclasses use same implentation
    // by simply varying custom elements (i.e. images)
    
    // update replay mode controls
	NSString *replayPrefix = [self prefixForElement:elemReplay];
    if (state == stateReplay) {
        // stop/exit button --> exit state
		[replayStopExitButton setImage:[UIImage imageNamed:[replayPrefix stringByAppendingString:@"btn-replay-exit.png"]] forState:UIControlStateNormal];
        // start replay button --> enabled state
		[replayStartButton setImage:[UIImage imageNamed:[replayPrefix stringByAppendingString:@"btn-replay-start.png"]] forState:UIControlStateNormal];			
    } else if (state == stateReplaying) {
		// stop/exit button --> stop state
		[replayStopExitButton setImage:[UIImage imageNamed:[replayPrefix stringByAppendingString:@"btn-replay-stop.png"]] forState:UIControlStateNormal];
        // start replay button --> disabled state
		[replayStartButton setImage:[UIImage imageNamed:[replayPrefix stringByAppendingString:@"btn-replay-start-da.png"]] forState:UIControlStateNormal];	
    }    
}


#pragma mark User Interface and sounds setup
- (void)setupSounds {
	// overload this function in subclasses
	crashSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"crashSound" ofType:@"wav"]];
	
	pauseCountSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resetSound" ofType:@"wav"]];
	
	resetSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resetSound" ofType:@"wav"]];	
}

- (void)setupUserInterface {
	// compose view arrays here
	
	// catcher views
	catcherViews = [[NSArray alloc] initWithObjects:catcherLeftView, catcherRightView, catcherLBottomView, catcherLTopView, catcherRTopView, catcherRBottomView, nil];
	
	// penalty views
	penaltyViews = [[NSArray alloc] initWithObjects:penaltyView1, penaltyView2, penaltyView3, nil];
	
	// left crash views
	leftCrashViews = [[NSArray alloc] initWithObjects:crashLeftView, savedLeftView0, savedLeftView1, savedLeftView2, savedLeftView3, nil];
	
	// right crash views
	rightCrashViews = [[NSArray alloc] initWithObjects:crashRightView, savedRightView0, savedRightView1, savedRightView2, savedRightView3, nil];
	
	// digit views
	digitViews = [[NSArray alloc] initWithObjects:digitView0, digitView1, digitView2, digitView3, nil];
	
	// trajectory views
	trajectoryViews = [[NSArray alloc] initWithObjects:
					   // trajectory 0
					   [[NSArray alloc] initWithObjects:projectileView00, projectileView01, projectileView02, projectileView03, projectileView04, nil],
					   // trajectory 1
					   [[NSArray alloc] initWithObjects:projectileView10, projectileView11, projectileView12, projectileView13, projectileView14, nil],
					   // trajectory 2
					   [[NSArray alloc] initWithObjects:projectileView20, projectileView21, projectileView22, projectileView23, projectileView24, nil],
					   // trajectory 3
					   [[NSArray alloc] initWithObjects:projectileView30, projectileView31, projectileView32, projectileView33, projectileView34, nil],
					   // nil element
					   nil];
	
	// unpause views
	unpauseViews = [[NSArray alloc] initWithObjects:unpauseView0, unpauseView1, unpauseView2, unpauseView3, nil];
	
	// update catcher views on startup, so the catcher will emerge on the screen
	[self catcherAction:[NSNumber numberWithInteger:catcherPosition]];
	
	// display controls for the current game state
	NSInteger gameState = [appDelegate gameState];
	[self displayControlsForState:gameState];
}


#pragma mark
#pragma mark Interface for projectile observer
#pragma mark

#pragma mark Auxiliaries
- (NSString *)prefixForElement:(NSInteger)element {
	// this is for "narow" game
	NSString *appPrefix = [[appDelegate currentGamePrefix] stringByAppendingString:@"-"];
	if (element == elemDigit) return appPrefix;
	else if (element == elemPauseCnt) return appPrefix;
	return @"";
}

- (float)getAlphaForElement:(NSInteger)element inState:(NSInteger)state {
	return 1.0;
}

#pragma mark Updates Points
- (void)updatePoints:(id)param {
	NSInteger points = [param integerValue];
	
	// clear old points
	for (UIImageView *digitView in digitViews) {
		digitView.hidden = YES;
		digitView.image = nil;  // no image (2009.01.20)
	}
	
	// points are limited to 4 digits, from 0 to 9999
	// make a string from input number, then parse the string by bytes
	NSNumber *aNumber = [[NSNumber alloc] initWithInteger:points];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	NSString *numberStr = [formatter stringFromNumber:aNumber];
	[formatter release];
	[aNumber release];
	
	// now when we have a string, we can parse it into bytes (digits) and update an image view for each digit
	for (int i =  0; i < numberStr.length; i++) {
		// get a substring for a range of 1 symbol
		// use app prefix and auxiliary methods here
		NSRange range = NSMakeRange(i, 1);
		NSString *charStr = [numberStr substringWithRange:range];
		NSString *imageName = [NSString stringWithFormat:@"%@digit-%@.png", [self prefixForElement:elemDigit], charStr];
		
		((UIImageView *)[digitViews objectAtIndex:(numberStr.length - i - 1)]).image = [UIImage imageNamed:imageName];
		((UIView *)[digitViews objectAtIndex:(numberStr.length - i - 1)]).hidden = NO;
	}
}

#pragma mark Update Penalties
- (void)updatePenalties:(id)param {
	NSInteger penalties = [param integerValue];
	// clear old penalties if penalties count is 0
	if (penalties == 0) {
		for (UIView *penaltyView in penaltyViews) {
			penaltyView.hidden = YES;
		}
		
		return;
	}
	
	// update penalties, the half points blink, by changing their hidden property
	for (int i = penalties, idx = 0; i > 0; i -= 2) {
		((UIView *)[penaltyViews objectAtIndex:idx]).hidden = (i == 1 ? !(((UIView *)[penaltyViews objectAtIndex:idx]).hidden) : NO);
		idx++;
	}
	
	// hide "extra" penalties (need for replay mode)
	for (int i = penaltyViews.count - 1; i >= 0 ; i--) {
		if (penalties <= i * 2) {
			((UIView *)[penaltyViews objectAtIndex:i]).hidden = YES;
		}
	}
}

#pragma mark Reset Penalties
- (float)resetPenaltiesTime {
	return (0.1 + 0.5 * 4);	// "narrow" and "wide" games
}

- (void)resetBlink:(id)param {
	NSInteger wholePenalties = [param integerValue] / 2 + [param integerValue] % 2;
	int i = 0;
	for (UIView *penView in penaltyViews) {
		if (i < wholePenalties) {
			penView.hidden = !penView.hidden;
		}
		// next view
		i++;
	}
	
	// 2009.01.20 also blink score digits
	for (UIImageView *digitView in digitViews) {
		if (digitView.image != nil) {
			digitView.hidden = !digitView.hidden;
		}
	}
	
	[resetSound play];
}

- (void)showDigits:(id)param {
	for (UIImageView *digitView in digitViews) {
		if (digitView.image != nil) {
			digitView.hidden = NO;
		}
	}
}

- (void)resetPenalties:(id)param {
	NSInteger penalties = [param integerValue];
	NSInteger wholePenalties = penalties / 2 + penalties % 2;
	
	int i = 0;
	for (UIView *penView in penaltyViews) {
		if (i < wholePenalties) {
			penView.hidden = NO;
		} else {
			penView.hidden = YES;
		}
		// next view
		i++;
	}
	
	// blink 5 times
	for (int i = 0; i < 5; i++) {
		[self performSelector:@selector(resetBlink:) withObject:param afterDelay:(0.1 + 0.5 * i)];
	}
	// show the score
	[self performSelector:@selector(showDigits:)withObject:nil afterDelay:0.1 + 0.5 * 4 + 0.1];
}

#pragma mark Update Trajectories and Projectiles
- (void)clearTrajectories:(id)param {
	for (NSArray *trajectory in trajectoryViews) {
		for (UIView *projectile in trajectory) {
			projectile.hidden = YES;
		}
	}
}

- (void)updateProjectileOn:(NSInteger)trajId 
				   atIndex:(NSInteger)projIdx 
					hidden:(BOOL)hidden
{
	UIView *projectileView = ((UIView *)[[trajectoryViews objectAtIndex:trajId] objectAtIndex:projIdx]);
	projectileView.hidden = hidden;	
//	if (/*animateTransitions*/ FALSE) { // so sense
//		CATransition *animation = [CATransition animation];	
//		[animation setType:kCATransitionFade];
//		[animation setDuration:0.1];
//		[[projectileView layer] addAnimation:animation forKey:@"projectileUpdate"];
//	}	
}

#pragma mark Update Helper
- (void)updateHelper:(id)hidden {
	helperView.hidden = [hidden boolValue];

	if (animateTransitions) {
		CATransition *animation = [CATransition animation];	
		[animation setType:kCATransitionFade];
		[animation setDuration:0.5];
		[[helperView layer] addAnimation:animation forKey:@"helperUpdate"];
	}
}

- (void)helperCrashAnimate:(id)start {
	// nothing here
}

#pragma mark Animate Crash
- (float)animateCrashTime:(BOOL)saved {
	return (saved ? 1.9 : 1.5);
}

- (void)displayCrash:(id)params {
	NSInteger crashId = [[params objectAtIndex:0] integerValue];
	NSArray *crashViews = (crashId < 2 ? leftCrashViews : rightCrashViews);
	
	// hide the last projectile in crashed trajectory
	((UIView *)[[trajectoryViews objectAtIndex:crashId] lastObject]).hidden = YES;
	
	// show the crash view
	((UIView *)[crashViews objectAtIndex:0]).hidden = NO;
	
	if (((i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate]).soundOn) { 
		[crashSound play];
	}
}

- (void)updateCrash:(id)params {
	NSInteger crashId = [[params objectAtIndex:0] integerValue];
	NSArray *crashViews = (crashId < 2 ? leftCrashViews : rightCrashViews);
	NSInteger index = [[params objectAtIndex:1] integerValue];
	if (index > 1) ((UIView *)[crashViews objectAtIndex:(index - 1)]).hidden = YES;
	((UIView *)[crashViews objectAtIndex:index]).hidden = NO;
	
	if (((i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate]).soundOn) {
		[crashSound play];	// TO DO: use settins
	}
}

- (void)clearCrash:(id)param {
	// don't bother at all, just clear both left and right
	// left
	for (UIView *crashView in leftCrashViews) {
		crashView.hidden = YES;
	}
	// right
	for (UIView *crashView in rightCrashViews) {
		crashView.hidden = YES;
	}	
}

- (void)animateCrash:(id)params {
	BOOL saved = [[params objectAtIndex:1] boolValue];
	float delay = 0.0;
	
	[self performSelector:@selector(displayCrash:) withObject:params afterDelay:delay];
	
	// if half point is lost (saved) display saved views in sequence
	if (saved) {
		delay += 0.4;
		// display saved projectile
		for (int idx = 0; idx < 4; idx++) {
			[self performSelector:@selector(updateCrash:) withObject:[NSArray arrayWithObjects:[params objectAtIndex:0], [NSNumber numberWithInteger:(idx + 1)], nil]
					   afterDelay:delay];
			
			delay += 0.2;
		}
	} else {
		delay += 1.0;
	}
	
	// clear the crash views
	[self performSelector:@selector(clearCrash:) withObject:nil afterDelay:delay];
	
}

#pragma mark Update Sound
- (void)updateSound:(BOOL)soundOn {
	soundIconView.hidden = !soundOn;
}

#pragma mark Update Pause
- (void)updatePause:(BOOL)paused {
	// hide pause on view
	pauseIconView.hidden = !paused;
	// always set unpause views as hidden
	for (UIView *unpauseView in unpauseViews) {
		unpauseView.hidden = YES;
	}
}

#pragma mark Update Replay
- (void)updateReplay:(BOOL)replayOn {
	// update replay icon visibility
	replayIconView.hidden = !replayOn;
	
}

- (void)updatePauseCount:(id)params {
	NSInteger pauseCnt = [[params objectAtIndex:0] integerValue];
	pauseCountView.hidden = YES;
	if (pauseCnt > 0) {
		// use current application prefix
		pauseCountView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@pause-cnt-%d.png", [self prefixForElement:elemPauseCnt], pauseCnt]];
		pauseCountView.hidden = NO;
	}
	// update the unpause views
	NSInteger unpauseIdx = [[params objectAtIndex:1] integerValue];
	NSInteger idx = 0;
	for (UIView *unpauseView in unpauseViews) {
		unpauseView.hidden = (unpauseIdx == idx++ ? NO : YES);
	}
	// play the sound
	if (((i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate]).soundOn) {
		[pauseCountSound play];
	}
}

#pragma mark Update Mode
- (void)updateMode:(NSInteger)mode {
	gameALabelView.hidden = YES;
	gameBLabelView.hidden = YES;
	if (mode == gameModeI) {
		gameALabelView.hidden = NO;
	} else if (mode == gameModeII) {
		gameBLabelView.hidden = NO;
	}
}


#pragma mark Initializationa and view even handlers
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        // set default catcher position
		// it will be read and set by the app delegate from user defaults later
		catcherPosition = 0;
		animateTransitions = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	//[super viewWillAppear:animated];
	//[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	// TEST
	//return;
	
	gameBButton.hidden = !appDelegate.fullFeatures;
	gameBButtonLabel.hidden = !appDelegate.fullFeatures;
	//statsButton.hidden = !appDelegate.fullFeatures;
	//statsButtonLabel.hidden = !appDelegate.fullFeatures;
	replayButton.hidden = !appDelegate.fullFeatures;
	replayButtonLabel.hidden = !appDelegate.fullFeatures;
	
#ifdef DISKOTEKA_90
	diskotekaButton.hidden = YES;
#endif
}
#if 0	// DISABLE
- (void)viewDidLoad {
    [super viewDidLoad];
	
	gameBButton.hidden = !appDelegate.fullFeatures;
	gameBButtonLabel.hidden = !appDelegate.fullFeatures;
	//statsButton.hidden = !appDelegate.fullFeatures;
	//statsButtonLabel.hidden = !appDelegate.fullFeatures;
	replayButton.hidden = !appDelegate.fullFeatures;
	replayButtonLabel.hidden = !appDelegate.fullFeatures;
	
	// rotate contents to landscape view
    [ViewTransformer rotateToLandscapeRight:self.view];	
}
#endif

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[appDelegate release];
	[catcherViews release];
	[penaltyViews release];
	[leftCrashViews release];
	[rightCrashViews release];
	[digitViews release];
	[trajectoryViews release];
	[unpauseViews release];
	[crashSound release];
	[pauseCountSound release];
	[resetSound release];
    [super dealloc];
}

@end
