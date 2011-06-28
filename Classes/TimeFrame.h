//
//  TimeFrame.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 3/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectileWorkerDelegate;

@interface TimeFrame : NSObject <NSCoding> {
	BOOL realTime;
	ProjectileWorkerDelegate *projectileWorkerDelegate;
	NSInteger activeTrajId;
	NSInteger catcherPosition;
	NSInteger points;
	NSInteger penalties;
	BOOL helper;
}

- (id)initWithDelegate:(ProjectileWorkerDelegate *)delegate 
			  realTime:(BOOL)rtime 
		  activeTrajId:(NSInteger)trajId
			   catcher:(NSInteger)catcher
				points:(NSInteger)pts
			 penalties:(NSInteger)pens
				helper:(BOOL)hlp;

@property (nonatomic, readonly) ProjectileWorkerDelegate *projectileWorkerDelegate;
@property (nonatomic, assign) BOOL realTime;
@property (nonatomic, assign) NSInteger activeTrajId;
@property (nonatomic, assign) NSInteger catcherPosition;
@property (nonatomic, assign) NSInteger points;
@property (nonatomic, assign) NSInteger penalties;
@property (nonatomic, assign) BOOL helper;  // just in case

@end
