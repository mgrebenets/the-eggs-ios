//
//  TheCatchingAboutViewController.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 3/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TheEggsProAboutViewController.h"
#import "GamesListViewController.h"

#define kFullFeaturesProductId	@"<YOUR-FULL-FEATURES-PRODUCT-ID>"
#define kFullSkinsProductId	@"<YOUR-FULL-SKINS-PRODUCT-ID>"

@implementation TheEggsProAboutViewController

@synthesize currentProduct;

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	NSString *prefix = [appDelegate currentGamePrefix];
	
	// set the current game icon
	if (currentSkinIcon) {
		NSString *imageName = [prefix stringByAppendingString:@"-app-icon.png"];
		currentSkinIcon.image = [UIImage imageNamed:imageName];
	}
	
//	if (skinsButton) {
//		skinsButton.currentTitle = NSLocalizedString(@"More Skins", @"More Skins");
//	}
	
	// set current game title to the label
	if (currentSkinLabel) {
		currentSkinLabel.text = NSLocalizedString(prefix, prefix);
	}
	
	// show/hide "need restart" label
	if (needRestartLabel) {
		needRestartLabel.text = NSLocalizedString(@"Need Restart", @"Need Restart");
		needRestartLabel.hidden = !(appDelegate.currentGameId != appDelegate.oldGameId);
	}
	
	if (needRestartView) {
		needRestartView.hidden =  !(appDelegate.currentGameId != appDelegate.oldGameId);
	}

	currentSkinMsgLabel.text = NSLocalizedString(@"Current Skin", @"Current Skin");
	
	if (appDelegate.fullSkins) {
		[skinsButton setTitle:NSLocalizedString(@"Change Skin", @"Change Skin") forState:UIControlStateNormal];		
	} else {
		[skinsButton setTitle:NSLocalizedString(@"More Skins", @"More Skins") forState:UIControlStateNormal];
	}
	
	if (appDelegate.fullFeatures) {
		featuresButton.hidden = YES;
		// TODO: set featuresLabel text to "All Features Enabled"
	} else {
		featuresButton.hidden = NO;
		// TODO: set features label text to promotional message to get more features
	}
	
	[indicatorView stopAnimating];
	indicatorView.hidden = YES;	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {	// associate self with payment queue
	
	[super viewDidLoad];
	
	appDelegate = (i4nGoalieAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	// prepare alert views
	puchaseAlert = [[UIAlertView alloc] initWithTitle:@""
											   message:@""
											  delegate:self
									 cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
									 otherButtonTitles:NSLocalizedString(@"Buy", @"Buy"), nil];
	puchaseAlert.cancelButtonIndex = 0;
	
	paymentsAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"In-App Purchases Disabled", @"In-App Purchases Disabled") 
											   message:NSLocalizedString(@"In-App Purchases Disabled Message", @"In-App Purchases Disabled Message")
											  delegate:self
									 cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
									 otherButtonTitles:nil];

	requestFailedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Product Request Failed", @"Product Request Failed") 
											   message:NSLocalizedString(@"Product Request Failed Message", @"Product Request Failed Message")
											  delegate:self
									 cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
									 otherButtonTitles:nil];
	
	// "more skins" button
	UIImage *buttonImage = [UIImage imageNamed:@"btn-green.png"];
	UIImage *stretchedImage = [buttonImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];
	[skinsButton setBackgroundImage:stretchedImage forState:UIControlStateNormal];
//	skinsButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];

	// "more features" button
	[featuresButton setTitle:NSLocalizedString(@"More Features", @"More Features") forState:UIControlStateNormal];
	[featuresButton setBackgroundImage:stretchedImage forState:UIControlStateNormal];
//	featuresButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];	
	
	[indicatorView stopAnimating];
	indicatorView.hidden = YES;
	
	// add self as payment queue observer
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;	
}

- (void)dealloc {
    [paymentsAlert release];
    [puchaseAlert release];
	[requestFailedAlert release];
	[currentProduct release];
    [super dealloc];
}

#pragma mark Action handlers
- (IBAction)skinsButtonAction:(id)sender {
	if (ignoreTouch) return;
	
	if (appDelegate.fullSkins)  {
		// skins already purchased, so navigate to skins list
		GamesListViewController *gamesListViewController = [[GamesListViewController alloc] initWithStyle:UITableViewStylePlain];
		// push it and release
		[self.navigationController pushViewController:gamesListViewController animated:YES];
		[gamesListViewController release];
		return;
	}
	
	// check if payments are enabled
	if (![SKPaymentQueue canMakePayments]) {
		[paymentsAlert show];
		return;
	}
	
	[indicatorView startAnimating];
	ignoreTouch = TRUE;
	
	// request product information
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kFullSkinsProductId]]; 
	request.delegate = self;
	[request start];
}

- (IBAction)featuresButtonAction:(id)sender {
	if (ignoreTouch) return;
	
	if (appDelegate.fullFeatures)  return; //ignore, there's been a mistake
	
	// check if payments are enabled
	if (![SKPaymentQueue canMakePayments]) {
		[paymentsAlert show];
		return;
	}
	
	[indicatorView startAnimating];
	ignoreTouch = TRUE;
	
	// request product information
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kFullFeaturesProductId]]; 
	request.delegate = self;
	[request start];
}

#pragma mark UIAlertViewDelegate implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == puchaseAlert) {
        // features purchase
        if (buttonIndex == puchaseAlert.cancelButtonIndex) {
			ignoreTouch = NO;
			self.currentProduct = nil;
			return; // no purchase
		}
		
		[indicatorView startAnimating];
		indicatorView.hidden = NO;
		
		SKPayment *payment = [SKPayment paymentWithProduct:currentProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
		self.currentProduct = nil;
    } else if (alertView == paymentsAlert) {
		ignoreTouch = NO;
	} else if (alertView == requestFailedAlert) {
		ignoreTouch = NO;
	}
}

#pragma mark -
#pragma mark SKRequestDelegate implementation
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	// TODO: check response

	[indicatorView stopAnimating];
	
	if (response.products.count == 0) {
		[requestFailedAlert show];		
	} else {
		self.currentProduct = [response.products objectAtIndex:0];
		NSLog(@"%@", currentProduct.localizedTitle);
		NSLog(@"%@", currentProduct.localizedDescription);
		puchaseAlert.title = currentProduct.localizedTitle;
		puchaseAlert.message = currentProduct.localizedDescription;
		[puchaseAlert show];
	}
	
	[request autorelease];	
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver implementation

#pragma mark SKPaymentTransactionObserver delegate implementation
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    // TODO: in our case only one transaction normally, check transaction type and state
    // TODO: if purchased --> confirmation message, else --> failed message
    
	
	NSLog(@"updated transactions: %d", transactions.count);
	for (SKPaymentTransaction *transaction in transactions) {
		NSLog(@"State: %d", transaction.transactionState);
		NSLog(@"Id: %d", transaction.transactionIdentifier);
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased:
			case SKPaymentTransactionStateRestored:
				NSLog(@"Purchased or restored");
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];				
				[indicatorView stopAnimating];
				ignoreTouch = NO;
				
				// TODO: enable content
				if ([transaction.payment.productIdentifier isEqual:kFullFeaturesProductId]) {
					NSLog(@"Purchased features");
					appDelegate.fullFeatures = YES;
					featuresButton.hidden = YES;
				} else if ([transaction.payment.productIdentifier isEqual:kFullSkinsProductId]) {
					NSLog(@"Purchased skins");
					appDelegate.fullSkins = YES;
					[skinsButton setTitle:NSLocalizedString(@"Change Skin", @"Change Skin") forState:UIControlStateNormal];		
				}
				break;
			case SKPaymentTransactionStateFailed:
				NSLog(@"Failed");
				// any message here? --> NO
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];				
				[indicatorView stopAnimating];
				ignoreTouch = NO;
				break;
			default:
				NSLog(@"Transaction is still in progress");
				break;
		}
		

	}
}

@end
