//
//  DiskotekaViewController.m
//  The Eggs
//
//  Created by Maksym Grebenets on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "DiskotekaViewController.h"
#import "The_EggsAppDelegate.h"

@implementation DiskotekaViewController

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    //[super viewDidLoad];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (IBAction)closeAction:(id)sender {
	i4nGoalieAppDelegate *appDelegate = (i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate displayDiskotekaPromo:[NSNumber numberWithBool:NO]];
}

- (IBAction)onsiteAction:(id)sender {
	// navigate to web site
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"http://www.superdiskoteka.ru"]];
}

- (IBAction)vkontakteAction:(id)sender {
	// navigate to web site
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"http://vkontakte.ru/club11693584"]];	
}



@end
