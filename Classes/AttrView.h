//
//  AttrView.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 1/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AttrView : UIView {
	UILabel *label;	// TEMP
}

- (void)setValueWithInteger:(NSInteger)value;
- (void)setValueWithString:(NSString *)value;

@end
