//
//  AboutViewController.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 1/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController {
	IBOutlet UITextView *headerTextView;
	IBOutlet UITextView *descriptionTextView;
	BOOL ignoreTouch;
}

- (IBAction)closeAction:(id)sender;
- (IBAction)i4nAppsUrl:(id)sender;

@end
