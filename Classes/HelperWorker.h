//
//  HelperWorker.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 17/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameViewController;

@interface HelperWorker : NSObject <NSCoding> {
	float toggleTimeout;
	BOOL hidden;
	BOOL suspended;
	BOOL sleeping;
	
	GameViewController *observerViewController;
}

- (void)start;
- (void)stop;
- (void)reset;
- (void)suspend;
- (void)resume;

@property (nonatomic, retain) GameViewController *observerViewController;
@property (nonatomic, readonly) BOOL hidden;

@end


