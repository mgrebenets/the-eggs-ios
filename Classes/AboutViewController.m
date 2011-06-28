//
//  AboutViewController.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 1/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "The_EggsAppDelegate.h"
#import "ViewTransformer.h"

@implementation AboutViewController


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = NSLocalizedString(@"About", @"About View Title");
		ignoreTouch = FALSE;
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// header view (title/version/by)
	if (headerTextView) {
		NSString *bundleDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
		NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
		NSString *headerText = [NSString stringWithFormat:@"%@\n%@ %@\n%@ i4nApps", bundleDisplayName, [NSLocalizedString(@"Version", @"Version") lowercaseString], bundleVersion, [NSLocalizedString(@"By", @"By") lowercaseString]];
		headerTextView.text = headerText;
	}	
	
	i4nGoalieAppDelegate *delegate = (i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate];
	// description
	if (descriptionTextView) {
		descriptionTextView.text = [delegate gameDescription];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

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

#pragma mark Actions
- (IBAction)closeAction:(id)sender {
	if (ignoreTouch) return;
	// ask app delegate to flip to game view (gameInfo selector with false show flag)
	[(i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate] displayGameInfo:[NSNumber numberWithBool:NO]];
}

- (IBAction)i4nAppsUrl:(id)sender {
	if (ignoreTouch) return;
	// open URL www.i4napps.com
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"http://www.i4napps.com"]];
}

@end
