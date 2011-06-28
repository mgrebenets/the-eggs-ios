//
//  GameViewController.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/11/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

// UI elements enumeration
enum {
	elemUndefined,
	elemSound,
	elemPause,
	elemReplay,
	elemDigit,
	elemPauseCnt
};

enum {
	elemStateNA,
	elemStateOn,
	elemStateOff
};

@class SoundEffect;
@class i4nGoalieAppDelegate;

@interface GameViewController : UIViewController {
	
	// App Delegate
	i4nGoalieAppDelegate *appDelegate;
	
	// trajectories
	// trajectory 0
	IBOutlet UIView *projectileView00;
	IBOutlet UIView *projectileView01;
	IBOutlet UIView *projectileView02;
	IBOutlet UIView *projectileView03;
	IBOutlet UIView *projectileView04;
	// trajectory 0
	IBOutlet UIView *projectileView10;
	IBOutlet UIView *projectileView11;
	IBOutlet UIView *projectileView12;
	IBOutlet UIView *projectileView13;
	IBOutlet UIView *projectileView14;
	// trajectory 0
	IBOutlet UIView *projectileView20;
	IBOutlet UIView *projectileView21;
	IBOutlet UIView *projectileView22;
	IBOutlet UIView *projectileView23;
	IBOutlet UIView *projectileView24;
	// trajectory 0
	IBOutlet UIView *projectileView30;
	IBOutlet UIView *projectileView31;
	IBOutlet UIView *projectileView32;
	IBOutlet UIView *projectileView33;
	IBOutlet UIView *projectileView34;
	
	// trajectory views array
	NSArray *trajectoryViews;
	
	
	// catcher views
	IBOutlet UIView *catcherLeftView;
	IBOutlet UIView *catcherRightView;
	IBOutlet UIView *catcherLTopView;
	IBOutlet UIView *catcherLBottomView;
	IBOutlet UIView *catcherRTopView;
	IBOutlet UIView *catcherRBottomView;
	NSArray *catcherViews;
	
	// helper view
	IBOutlet UIImageView *helperView;
	
	// penalty views
	IBOutlet UIView *penaltyView1;
	IBOutlet UIView *penaltyView2;
	IBOutlet UIView *penaltyView3;
	NSArray *penaltyViews;
	IBOutlet UIView *missedLabelView;
	
	// crash views (left)
	IBOutlet UIView *crashLeftView;
	IBOutlet UIView *savedLeftView0;
	IBOutlet UIView *savedLeftView1;
	IBOutlet UIView *savedLeftView2;
	IBOutlet UIView *savedLeftView3;
	NSArray *leftCrashViews;
	
	// crash views (left)
	IBOutlet UIView *crashRightView;
	IBOutlet UIView *savedRightView0;
	IBOutlet UIView *savedRightView1;
	IBOutlet UIView *savedRightView2;
	IBOutlet UIView *savedRightView3;
	NSArray *rightCrashViews;
	
	// digit views
	IBOutlet UIImageView *digitView0;
	IBOutlet UIImageView *digitView1;
	IBOutlet UIImageView *digitView2;
	IBOutlet UIImageView *digitView3;
	NSArray *digitViews;
	
	// game mode buttons
	IBOutlet UIButton *gameAButton;
	IBOutlet UIButton *gameBButton;
	IBOutlet UIView *gameBButtonLabel;
    
	// game mode label views
	IBOutlet UIView *gameALabelView;
	IBOutlet UIView *gameBLabelView;
	
	// sound on/off view
	IBOutlet UIView *soundIconView;
	IBOutlet UIButton *soundButton;
	
	// pause on/off view
	IBOutlet UIView *pauseIconView;
	IBOutlet UIImageView *pauseCountView;
	IBOutlet UIView *pauseLabelView;
	IBOutlet UIButton *pauseButton;
	
	// unpause views
	IBOutlet UIView *unpauseView0;
	IBOutlet UIView *unpauseView1;
	IBOutlet UIView *unpauseView2;
	IBOutlet UIView *unpauseView3;
	NSArray *unpauseViews;
	
	// info and stats button outlets
	IBOutlet UIButton *infoButton;
	IBOutlet UIButton *statsButton;
	IBOutlet UIView *statsButtonLabel;
	
#ifdef DISKOTEKA_90
	IBOutlet UIButton *diskotekaButton;
#endif
	
	// replay views
	IBOutlet UIView *replayIconView;
	IBOutlet UIButton *replayButton;
	IBOutlet UIView *replayButtonLabel;
	IBOutlet UIView *replayLabelView;
	IBOutlet UIButton *replayStartButton;
	IBOutlet UIButton *replayStopExitButton;
	
	// catcher position
	NSInteger catcherPosition;
	
	// animate transitions flag
	BOOL animateTransitions;
	
	// sounds
	SoundEffect *crashSound;
	SoundEffect *pauseCountSound;
	SoundEffect *resetSound;
}

#pragma mark Debug control actions
- (IBAction)suspend:(id)sender;
- (IBAction)resume:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)restart:(id)sender;
- (IBAction)catchAllAction:(id)sender;

#pragma mark Catcher control actions
- (void)catcherAction:(NSNumber *)direction;
- (IBAction)topLeftAction:(id)sender;
- (IBAction)bottomLeftAction:(id)sender;
- (IBAction)topRightAction:(id)sender;
- (IBAction)bottomRightAction:(id)sender;

#pragma mark Game control actions
- (IBAction)gameAAction:(id)sender;
- (IBAction)gameBAction:(id)sender;
- (IBAction)gamePauseAction:(id)sender;
- (IBAction)buttonTouchDownAction:(id)sender;
- (IBAction)gameInfoAction:(id)sender;
- (IBAction)gameSoundAction:(id)sender;
- (IBAction)gameReplayAction:(id)sender;
- (IBAction)gameStatsAction:(id)sender;	// open feint
- (IBAction)gameReplayStartAction:(id)sender;
- (IBAction)gameReplayStopExitAction:(id)sender;
#ifdef DISKOTEKA_90
- (IBAction)diskotekaAction:(id)sender;
#endif

#pragma mark Display control methods
- (void)displayControlsForState:(NSInteger)state;
- (void)displayNavigationControlsForState:(NSInteger)state;
- (void)displayPauseControlsForState:(NSInteger)state;
- (void)displayReplayControlsForState:(NSInteger)state;

#pragma mark UI and sounds setup
- (void)setupSounds;
- (void)setupUserInterface;

#pragma mark
#pragma mark Methods to be called by projectile observer or app delegate
#pragma mark
#pragma mark Points
- (void)updatePoints:(id)param;
#pragma mark Penalties
- (void)updatePenalties:(id)param;
- (float)resetPenaltiesTime;
- (void)resetPenalties:(id)param;
#pragma mark Trajectories
- (void)clearTrajectories:(id)param;
- (void)updateProjectileOn:(NSInteger)trajId atIndex:(NSInteger)projIdx hidden:(BOOL)hidden;
#pragma mark Helper
- (void)updateHelper:(id)hidden;
- (void)helperCrashAnimate:(id)start;
#pragma mark Crash
- (float)animateCrashTime:(BOOL)saved;
- (void)animateCrash:(id)params;
#pragma mark Sound on/off
- (void)updateSound:(BOOL)soundOn;
#pragma mark Pause on/off
- (void)updatePause:(BOOL)paused;
- (void)updatePauseCount:(id)params;
#pragma mark Replay on/off
- (void)updateReplay:(BOOL)replayOn;
#pragma mark Game mode
- (void)updateMode:(NSInteger)mode;

#pragma mark Auxiliary methods to configure UI
- (NSString *)prefixForElement:(NSInteger)element;
- (float)getAlphaForElement:(NSInteger)element inState:(NSInteger)state;

@property (nonatomic, retain) i4nGoalieAppDelegate *appDelegate;
@property (nonatomic, readonly) NSInteger catcherPosition;

@end

