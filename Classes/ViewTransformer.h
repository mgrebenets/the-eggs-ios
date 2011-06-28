//
//  ViewTransformer.h
//  i4nPoker
//
//  Created by Maksym Grebenets on 11/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewTransformer : NSObject {

}

+ (void)rotateToLandscapeRight:(UIView *)view;
+ (void)rotateToLandscapeRightAndResize:(UIView *)view;

@end
