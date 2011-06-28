//
//  ViewTransformer.m
//  i4nPoker
//
//  Created by Maksym Grebenets on 11/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ViewTransformer.h"


@implementation ViewTransformer

+ (void)rotateToLandscapeRight:(UIView *)view {
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	if (orientation == UIInterfaceOrientationLandscapeRight) {
        CGAffineTransform transform = view.transform;

		UIScreen *screen = [UIScreen mainScreen];
		// Translate the view to the center of the screen
		transform = CGAffineTransformTranslate(transform, 
											   ((screen.bounds.size.width) - (view.bounds.size.width))/2, 
											   ((screen.bounds.size.height) - (view.bounds.size.height))/2);

		// Rotate the view 90 degrees around its new center point.
        transform = CGAffineTransformRotate(transform, (M_PI / 2.0));

        view.transform = transform;
	}
}

+ (void)rotateToLandscapeRightAndResize:(UIView *)view {
	[ViewTransformer rotateToLandscapeRight:view];
	view.bounds = CGRectMake(0, 0, 480, 320);	
}

@end
