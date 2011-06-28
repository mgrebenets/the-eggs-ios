//
//  WideGameViewController.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 2/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "The_EggsAppDelegate.h"
#import "WideGameViewController.h"


@implementation WideGameViewController


#pragma mark
#pragma mark Override superclass methods
#pragma mark

#pragma mark Auxiliaries
- (NSString *)prefixForElement:(NSInteger)element {
	// this is for "wide" game, no prefixes except for sound
	NSString *appPrefix = [[appDelegate currentGamePrefix] stringByAppendingString:@"-"];
	if (element == elemSound) return appPrefix;
	return @"";
}

- (float)getAlphaForElement:(NSInteger)element inState:(NSInteger)state {
	if (element == elemPause) {
		return (state == elemStateOn ? 1.0 : 0.3);
	}
	return 1.0;
}

#pragma mark Update Sound
- (void)updateSound:(BOOL)soundOn {
	// update sound button
	NSString *soundPrefix = [self prefixForElement:elemSound];
	[soundButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@btn-sound-%@.png", soundPrefix, (soundOn ? @"on": @"off")]] 
				  forState:UIControlStateNormal];
	// ask super to do what it does
	[super updateSound:soundOn];
}

#pragma mark Update Pause
- (void)updatePause:(BOOL)paused {	
	// update pause button
	NSString *pausedPrefix = [self prefixForElement:elemPause];
	[pauseButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@btn-pause-%@.png", pausedPrefix, (paused ? @"on": @"off")]] 
				 forState:UIControlStateNormal];
	// update button alpha
	pauseButton.alpha = [self getAlphaForElement:elemPause inState:(paused ? elemStateOn : elemStateOff)];
	pauseLabelView.hidden = !paused;
	// ask super to do what it usually does
	[super updatePause:paused];
}

#pragma mark Update Replay
- (void)updateReplay:(BOOL)replayOn {
	// update replay button
	NSString *replayPrefix = [self prefixForElement:elemReplay];
	[replayButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@btn-replay-%@.png", replayPrefix, (replayOn ? @"on": @"off")]] 
				 forState:UIControlStateNormal];
	[super updateReplay:replayOn];
}

#pragma mark Display controls
// overload this method in subclasses to customize controls appearance
- (void)displayControlsForState:(NSInteger)state {
    // customize the views and controls for given game state
    // this is a "wide" game view implementaion, so there's a lot to do

    // change the whole controls appearance considering current game status
	
    // hide gameA, gameB buttons when not in ready or game over state (show otherwise)
    gameAButton.hidden = (state != stateReady && state != stateGameOver);
	if (appDelegate.fullFeatures) {
		gameBButton.hidden = (state != stateReady && state != stateGameOver);
	} else {
		gameBButton.hidden = YES;
	}


	
    // replay on/off and sound on/off buttons just stay where they are (always visible)
	// just to make sure (could forgot to enable in IB)
	soundButton.hidden = NO;
	replayButton.hidden = !appDelegate.fullFeatures || NO;
	
	// navigation controls
	[self displayNavigationControlsForState:state];
	
	// pause controls
	[self displayPauseControlsForState:state];
	
    // replay controls
    [self displayReplayControlsForState:state];
}

- (void)displayNavigationControlsForState:(NSInteger)state {
	// wide game navigation controlls
    BOOL replayModeOn = (state == stateReplay || state == stateReplaying);
    infoButton.hidden = replayModeOn;     // hide info button when in replay mode
	//statsButton.hidden = !appDelegate.fullFeatures || replayModeOn;	    // hide stats button when in replay mode
}

- (void)displayPauseControlsForState:(NSInteger)state {
	// hide pause button when in ready or game over state or in replay mode (show otherwise)
	BOOL replayModeOn = (state == stateReplay || state == stateReplaying);
    pauseButton.hidden = (state == stateReady || state == stateGameOver || replayModeOn);
	// update pause controls
	[self updatePause:(state == statePaused || state == stateUnpausing)];
}

#pragma mark
#pragma mark General Handlers
#pragma mark
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}


@end
