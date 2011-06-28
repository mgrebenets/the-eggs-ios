//
//  SimpleProjectileWorkerDelegate.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectileWorkerDelegate.h"

@interface SimpleProjectileWorkerDelegate : NSObject <ProjectileWorkerDelegate, NSCoding, NSCopying> {

@private
	NSInteger mode;
	NSInteger activeTrajId;
	NSInteger points;
	NSInteger trajectoriesNumber;
	NSInteger trajectoryLength;
	NSInteger lengthMask;
	NSInteger addNewMask;
	NSInteger newProjectileMask;
	NSInteger lastActivePositionMask;
	NSInteger emptyTrajectoryMask;
	
	NSInteger gapCnt;	
	unsigned char *trajectories;
	NSInteger trajectoryQueueIdx;
	NSInteger trajectoryQueueCnt;
	signed char *trajectoriesQueue;
}

@end
