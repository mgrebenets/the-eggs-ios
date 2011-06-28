//
//  ProjectileWorker.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectileWorkerDelegate;
@class ProjectileObserver;

@interface ProjectileWorker : NSObject <NSCoding> {
	NSInteger tickCnt;
	BOOL suspended;
	BOOL sleeping;
	
	ProjectileWorkerDelegate *delegate;
	ProjectileObserver *observer;
}

- (void)start;
- (void)reset;
- (void)restart;
- (void)suspend;
- (void)resume;

@property (readonly) BOOL suspended;
@property (nonatomic, retain) ProjectileWorkerDelegate *delegate;
@property (nonatomic, retain) ProjectileObserver *observer;

@end
