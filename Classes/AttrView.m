//
//  AttrView.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 1/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AttrView.h"


@implementation AttrView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		label = [[UILabel alloc] initWithFrame:frame];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
    }
    return self;
}

- (void)layoutSubviews {
	label.frame = self.bounds;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)setValueWithInteger:(NSInteger)value {
	[self setValueWithString:[NSString stringWithFormat:@"%d", value]];
}

- (void)setValueWithString:(NSString *)value {
	label.text = value;
}


- (void)dealloc {
	[label release];
    [super dealloc];
}


@end
