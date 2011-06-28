//
//  TheEggsProAboutViewController.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 3/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "The_EggsAppDelegate.h"
#import "AboutViewController.h"
#import <StoreKit/StoreKit.h>

@interface TheEggsProAboutViewController : AboutViewController <UIAlertViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver> {
	IBOutlet UIImageView *currentSkinIcon;
	IBOutlet UILabel *currentSkinLabel;
	IBOutlet UILabel *currentSkinMsgLabel;
	IBOutlet UILabel *needRestartLabel;
	IBOutlet UIView *needRestartView;
	IBOutlet UIButton *skinsButton;
	
	IBOutlet UILabel *featuresLabel;
	IBOutlet UIButton *featuresButton;
	
	IBOutlet UIActivityIndicatorView *indicatorView;
	
	UIAlertView *paymentsAlert;
	UIAlertView *puchaseAlert;
	UIAlertView *requestFailedAlert;

	SKProduct *currentProduct;
	
	i4nGoalieAppDelegate *appDelegate;
}

@property (retain) SKProduct *currentProduct;

- (IBAction)skinsButtonAction:(id)sender;
- (IBAction)featuresButtonAction:(id)sender;

@end
