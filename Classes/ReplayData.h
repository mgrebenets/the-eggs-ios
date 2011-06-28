//
//  ReplayData.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 3/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimeFrame;

@interface ReplayData : NSObject <NSCoding> {
	NSInteger framesLimit;
	NSMutableArray *timeFrames;
}

@property (nonatomic, readonly) NSMutableArray *timeFrames;

//- (void)replay;
//- (void)stop;
- (id)initWithFramesLimit:(NSInteger)limit;
- (void)clear;
- (void)addFrame:(TimeFrame *)frame;

@end
