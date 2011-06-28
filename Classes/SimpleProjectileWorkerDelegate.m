//
//  SimpleProjectileWorkerDelegate.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SimpleProjectileWorkerDelegate.h"


@implementation SimpleProjectileWorkerDelegate

#pragma mark ProjectileWorkerDelegate protocol implementation

@synthesize mode, activeTrajId, points;

#pragma mark Debugging protocol implementation
- (void)printOut {
	printf("%s", [[self debugMsg] UTF8String]);
}

- (NSString *)debugMsg {
	NSString *trajectoriesMsg = @"";
	NSString *trajectoriesQueueMsg = @"";
	for (int i = 0; i < trajectoriesNumber; i++) {
		trajectoriesMsg = [NSString stringWithFormat:@"%@\n\t%@", trajectoriesMsg, [self bitsString:trajectories[i]]];
		trajectoriesQueueMsg = [NSString stringWithFormat:@"%@, %d", trajectoriesQueueMsg, trajectoriesQueue[i]];		
	}
	
	NSString *msg = [NSString stringWithFormat:
					 @"\n\nSimpleProjectileWorkerDelegate::"
					 "\n\tmode: %d"
					 "\n\tpoints: %d"
					 "\n\ttrajectories num: %d"
					 "\n\ttrajectory len: %d"
					 "\n\tgap count: %d"
					 "\n\ttrajectories::%@"
					 "\n\ttrajectory queue idx: %d"
					 "\n\ttrajectory queue count: %d"
					 "\n\ttrajectories queue: %@",
					 mode, points, trajectoriesNumber, trajectoryLength,
					 gapCnt, trajectoriesMsg, trajectoryQueueIdx,
					 trajectoryQueueCnt,
					 trajectoriesQueueMsg];
	
	return msg;
}

- (void)printBits:(char)number {
	printf("%s", [[self bitsString:number] UTF8String]);
}

- (NSString *)bitsString:(char)number {
	NSString *bitsStr = @"";
	for (int i = 0; i < 8; i++) {
		bitsStr = [NSString stringWithFormat:@"%@%d", bitsStr, (number & (1 << 7) ? 1 : 0)];
		number <<= 1;
	}
	return bitsStr;
}

#pragma mark NSCopying protocol implementation
- (id)copyWithZone:(NSZone *)zone
{
	// first use shallow copy
	SimpleProjectileWorkerDelegate *delegateCopy = NSCopyObject(self, 0, zone);
	
	// now copy the data which could not be copied via shallow copy
	// trajectories
	delegateCopy->trajectories = malloc(trajectoriesNumber * sizeof *trajectories);
	memcpy(delegateCopy->trajectories, trajectories, trajectoriesNumber * sizeof *trajectories);
	// trajectories queue
	delegateCopy->trajectoriesQueue = malloc(trajectoriesNumber * sizeof *trajectoriesQueue);
	memcpy(delegateCopy->trajectoriesQueue, trajectoriesQueue, trajectoriesNumber * sizeof *trajectoriesQueue);
	
	// now we have a deep copy which can be returned as a result
    return delegateCopy;
}

#pragma mark General init methods
- (void)generalInit {
	lengthMask = 0xFF << trajectoryLength;	//10000000
	addNewMask = 0x3;	//00...011
	newProjectileMask = 0x1;	//00...01
	// last active position of living projectile, the very last is for fallen projectile
	lastActivePositionMask = 0x1 << (trajectoryLength - 2);	//00100000
	// empty trajectory mask: do not check fallen projectile
	emptyTrajectoryMask = 0xFF << (trajectoryLength - 1);	//11000000	
}

#pragma mark NSCoding protocol implementation
- (void)encodeWithCoder:(NSCoder *)coder {  //encode
	[coder encodeInteger:mode forKey:@"mode"];
	[coder encodeInteger:activeTrajId forKey:@"activeTrajId"];
	[coder encodeInteger:points forKey:@"points"];
	[coder encodeInteger:gapCnt forKey:@"gapCnt"];	
	[coder encodeInteger:trajectoriesNumber forKey:@"trajectoriesNumber"];
	[coder encodeInteger:trajectoryLength forKey:@"trajectoryLength"];
	
	// trajectories and queue
	[coder encodeBytes:trajectories length:(trajectoriesNumber * sizeof *trajectories) forKey:@"trajectories"];
	[coder encodeInteger:trajectoryQueueCnt forKey:@"trajectoryQueueCnt"];
	[coder encodeInteger:trajectoryQueueIdx forKey:@"trajectoryQueueIdx"];
	[coder encodeBytes:(unsigned char *)trajectoriesQueue length:(trajectoriesNumber * sizeof *trajectoriesQueue) forKey:@"trajectoriesQueue"];
}

- (id)initWithCoder:(NSCoder *)coder {  //decode
	mode = [coder decodeIntegerForKey:@"mode"];
	activeTrajId = [coder decodeIntegerForKey:@"activeTrajId"];
	points = [coder decodeIntegerForKey:@"points"];
	gapCnt = [coder decodeIntegerForKey:@"gapCnt"];
	trajectoriesNumber = [coder decodeIntegerForKey:@"trajectoriesNumber"];
	trajectoryLength = [coder decodeIntegerForKey:@"trajectoryLength"];
	[self generalInit];
	
	// trajectories, queue	
	NSUInteger length = 0;
	unsigned char *buf = (unsigned char *)[coder decodeBytesForKey:@"trajectories" returnedLength:&length];
	trajectories = malloc(trajectoriesNumber * sizeof *trajectories);
	if (buf) {
	    memcpy(trajectories, buf, length);
	}
	
	trajectoryQueueCnt = [coder decodeIntegerForKey:@"trajectoryQueueCnt"];
	trajectoryQueueIdx = [coder decodeIntegerForKey:@"trajectoryQueueIdx"];
	buf = (unsigned char *)[coder decodeBytesForKey:@"trajectoriesQueue" returnedLength:&length];
	trajectoriesQueue = malloc(trajectoriesNumber * sizeof *trajectoriesQueue);
	if (buf) { 
	    memcpy(trajectoriesQueue, buf, length);
	}
	
	return self;
}

- (void)dealloc {
#if 0//DEBUGFULL	
	NSLog(@"\nSimpleProjectileWorker:dealloc");
#endif	
	free(trajectories);
	free(trajectoriesQueue);
	[super dealloc];
}

- (id)init {
#if 0//DEBUGFULL		
	NSLog(@"\nSimpleProjectileWorker:init");
#endif	
	if (self = [super init]) {
		trajectoriesNumber = 4;
		trajectoryLength = 6;
		mode = 0;   // default mode, should be set from outside when game starts
		activeTrajId = 0;	// for tracking by projectile observer
		points = 0;
		gapCnt = 0;
		[self generalInit];	// general members init
		
#if 0//DEBUGFULL			
		printf("\nlengthMask:");
		[self printBits:lengthMask];
		printf("\naddNewMask:");
		[self printBits:addNewMask];
		printf("\nlastActivePositionMask:");
		[self printBits:lastActivePositionMask];
		printf("\nemptyTrajectoryMask:");
		[self printBits:emptyTrajectoryMask];
		printf("\n");
#endif
		
		// trajectories
		trajectories = malloc(trajectoriesNumber * sizeof *trajectories);
		memset(trajectories, 0x0, trajectoriesNumber * sizeof *trajectories);
		
		// trajectory queue
		trajectoryQueueIdx = -1;	// the very first operation will be "++"
		trajectoryQueueCnt = 0;
		trajectoriesQueue = malloc(trajectoriesNumber * sizeof *trajectoriesQueue);
		memset(trajectoriesQueue, 0xF, trajectoriesNumber * sizeof *trajectoriesQueue);
	}
	
	return self;
}

-(void)reset {
	// reset projectiles and gap count
	[self resetProjectiles];
	gapCnt = 0;
	activeTrajId = 0;
	points = 0;
}

- (void)resetProjectiles {
	// clear trajectories, trajectory queue count and index
	memset(trajectories, 0x0, trajectoriesNumber * sizeof *trajectories);
	memset(trajectoriesQueue, 0xF, trajectoriesNumber * sizeof *trajectoriesQueue);
	trajectoryQueueCnt = 0;
	trajectoryQueueIdx = -1;   
}

#pragma mark Auxiliary methods
- (NSInteger)curGap:(NSInteger)tick {	
	if (tick == 0) return 0;
	NSInteger gapMin = (points % 100 <= 5 ? 6 : 1);
	NSInteger gapMax = (points % 100 <= 20 ? 9 : 6);
	NSInteger gap;
	do {
		gap = random() % 10;
	} while(gap < gapMin && gap > gapMax);
	
	return (gap <= 1 ? 1 : gap);
}

- (NSInteger)modeCnt {
	NSInteger cnt = 0;
	for (int i = 0; i < trajectoriesNumber; i++) {
		if (trajectories[i] & (~emptyTrajectoryMask)) cnt++;
	}
	return cnt;
}

- (BOOL)canAddNew {
	NSInteger tightCount = 0;
	for (int i = 0; i < trajectoriesNumber; i++) {
		if (trajectories[i] & addNewMask) tightCount++;
	}
	
	return (tightCount == mode ? FALSE : TRUE);
}

- (NSInteger)nextTrajectoryId {
	if (trajectoryQueueCnt == 0) return -1;
	
	do {
		trajectoryQueueIdx = (trajectoryQueueIdx + 1) % trajectoryQueueCnt;
	} while (trajectoriesQueue[trajectoryQueueIdx] < 0);
	
	return trajectoriesQueue[trajectoryQueueIdx]; // don't forget to increase idx
}

- (void)queueTrajectory:(NSInteger)trajId {
	// add trajectory to the queue
#if 0//DEBUGFULL		
	printf("\nqueueTrajectory:%d\n[", trajId);
	for (int i = 0; i < trajectoriesNumber; printf("%d, ", trajectoriesQueue[i++]));
	printf("]");
#endif
	
	// check duplicates
	for (int i = 0; i < trajectoryQueueCnt; i++) {
		if (trajectoriesQueue[i] == trajId) {
#if 0//DEBUGFULL
			printf("\n\talready queued");
#endif			
			return;	// already queued
		}
	}
	
	// not yet queued: add
	trajectoriesQueue[trajectoryQueueCnt] = trajId;
	trajectoryQueueCnt++;	// increase count
	
	if (trajectoryQueueCnt > trajectoriesNumber) {
		NSException *e = [[NSException alloc] 
						  initWithName:@"TrajectoryQueueException" 
						  reason:@"Queue Limit Exceeded" 
						  userInfo:nil];
		@throw e;
		
	}
#if 0//DEBUGFULL		
	printf("\nqueueTrajectory:%d --> done\n[", trajId);
	for (int i = 0; i < trajectoriesNumber; printf("%d, ", trajectoriesQueue[i++]));
	printf("]");
#endif	
}

- (void)dequeueTrajectory:(NSInteger)trajId {
#if 0//DEBUGFULL	
	printf("\ndequeueTrajectory:%d\n[", trajId);
	for (int i = 0; i < trajectoriesNumber; printf("%d, ", trajectoriesQueue[i++]));
	printf("]");
#endif	
	// remove trajectory from the queue (also shift elements if needed)
	for (int i = 0; i < trajectoryQueueCnt; i++) {
		if (trajectoriesQueue[i] == trajId) {
			// found in queue, remove now
			// shift to the left
			for (int j = i; j < trajectoryQueueCnt - 1; j++) {
				trajectoriesQueue[j] = trajectoriesQueue[j + 1];
			}
			// clear last queue element
			trajectoriesQueue[trajectoryQueueCnt - 1] = 0xFF; // (-1)
			trajectoryQueueCnt--;	// decrease count

			// if dequeued element's index is less or equal to current index, then current index must
			// by cycled one position back (to the last position in case of 0th element)
			// this correction is required, because getNextTrajId makes increment (+1) first (do...while loop)
			if (i <= trajectoryQueueIdx) {
			    trajectoryQueueIdx = (trajectoryQueueIdx == 0 ? (trajectoriesNumber - 1) : (trajectoryQueueIdx - 1));
			}
			break;
		}
	}
#if 0//DEBUGFULL		
	printf("\ndequeueTrajectory:%d --> done\n[", trajId);
	for (int i = 0; i < trajectoriesNumber; printf("%d, ", trajectoriesQueue[i++]));
	printf("]");
#endif	
}

- (void)clearFallenProjectiles {
	for (int i = 0; i < trajectoriesNumber; i++) {
		trajectories[i] &= (~emptyTrajectoryMask);
	}
}

#pragma mark ProjectileWorkerDelegate protocol implementation
- (float)tickSpeed:(NSInteger)tick {
#if 0//DEBUG 
	return 0.25;
#endif
	float nextTick = 1.0;
	NSInteger pointsDiv = points % 1000;
	NSInteger pointsRem = points % 100;
	// just hardcode it for now
	if (mode == 3) {
		nextTick = (pointsDiv < 200 ? 0.6 : 0.5) - 0.1 * (points / 1000);
		if (pointsDiv < 200 && pointsRem > 5) {
			nextTick -= (pointsRem < 20 ? 0.1 : 0.15);
		} else if (pointsDiv >= 200 && pointsRem > 5) {
			nextTick -= (pointsRem < 20 ? 0.05 : 0.1);
		}
	} else {
		nextTick = 0.505 - 0.1 * (points / 1000);
		if (pointsRem > 10) {
			nextTick -= (pointsRem < 30 ? 0.05 : 0.1);
		}
		nextTick -= 0.005 * pointsDiv / 100;
	}
	
	return (nextTick <= 0.1 ? 0.1 : nextTick);
}

- (void)updateProjectiles:(NSInteger)tick {
#if 0//DEBUGFULL		
	printf("\n\nSimpleProjectileWorker:updateProjectiles:%d --> begin", tick);
	printf("\ngapCnt:%d curGap:%d", gapCnt, [self curGap:tick]);
	// save old trajectories, queue and queue params to compare later
	unsigned char *oldTrajectories = malloc(trajectoriesNumber * sizeof *oldTrajectories);
	memcpy(oldTrajectories, trajectories, trajectoriesNumber * sizeof *trajectories);
	unsigned char *oldQueue = malloc(trajectoriesNumber * sizeof *oldQueue);
	memcpy(oldQueue, trajectoriesQueue, trajectoriesNumber * sizeof *oldQueue);
	NSInteger oldQueueIdx = trajectoryQueueIdx;
	NSInteger oldQueueCnt = trajectoryQueueCnt;
#endif 
	
	[self clearFallenProjectiles];
	
	// find out which trajectory has to be updated
	activeTrajId = [self nextTrajectoryId];
	
#if 0//DEBUGFULL	
	printf("\ncleared fallen projectiles");	
	printf("\nactiveTrajId:%d", activeTrajId);
#endif	
	
	if (activeTrajId >= 0) {
		// move a projectiles on that trajectory
		// if last projectile will move to the last position (fall)
		// then update only that projectile and don't touch others
		if (trajectories[activeTrajId] & lastActivePositionMask) {
			// a projectile is about to fall, update only this projectile
			// on given trajectory
			trajectories[activeTrajId] &= ~lastActivePositionMask;	// remove from last active position
			trajectories[activeTrajId] |= (lastActivePositionMask << 1); // add to fallen position
		} else {
			// nobody falls now, so move all projectiles on this trajectory
			trajectories[activeTrajId] <<= 1;	// move projectiles
			trajectories[activeTrajId] &= (~lengthMask);	// clear moved out projectiles
		}
#if 0//DEBUGFULL		
		printf("\nactive trajectory: ");
		[self printBits:trajectories[activeTrajId]];
#endif		
	}
	
	// if it's time to add a new projectile, then look up
	// for trajectory, which will accept it (must have enough space to 
	// put new projectile, also the mode condition must be kept,
	// which means no more than "mode" trajectories can have projectiles
	// at one moment
	NSInteger addTo = -1;
	if (gapCnt >= [self curGap:tick] && [self canAddNew] || activeTrajId < 0) {
#if 0//DEBUGFULL			
		printf("\n\ttime to add new projectile");
#endif		
		gapCnt = -1; // reset gap count (the very next operation is "++")
		
		do {
			addTo = random() % trajectoriesNumber;
		} while (trajectories[addTo] & addNewMask // 2 first positions in traj are empty
				 || trajectories[addTo] == 0 && [self modeCnt] == mode // check mode
				 // already "mode" trajs busy, can't add to an empty one
				 );
#if 0//DEBUGFULL	
		printf("\n\tfound destination trajectory:%d", addTo);
#endif		
		// set new projectile bit
		trajectories[addTo] |= newProjectileMask;
		
		// add this trajectory to trajectory queue (duplicates are checked)
		[self queueTrajectory:addTo];
	}
	
	if (activeTrajId >= 0) {
		// if active trajectory is empty (don't cout fallen projectiles), then dequeue it
		if ((trajectories[activeTrajId] & (~emptyTrajectoryMask)) == 0) {
			[self dequeueTrajectory:activeTrajId];
		}
	}
	
	gapCnt++; // increase new projectile gap count
	
#if 0//DEBUGFULL		
	printf("\nactiveTrajId:%d", activeTrajId);
	printf("\nall trajectories:\n");
	for (int i = 0; i < trajectoriesNumber; i++) {
		[self printBits:oldTrajectories[i]];
		printf(" --> ");
		[self printBits:trajectories[i]];
		if (i == activeTrajId) printf("   --CUR--");
		if (i == addTo) printf("   --NEW--");
		printf("\n");
	}
	
	printf("\ntrajectory queue idx: %d --> %d", oldQueueIdx, trajectoryQueueIdx);
	printf("\ntrajectory queue cnt: %d --> %d", oldQueueCnt, trajectoryQueueCnt);
	printf("\ntrajectoriesQueue:\n[");
	for (int i = 0; i < trajectoriesNumber; printf("%d, ", oldQueue[i++]));
	printf("] --> [");
	for (int i = 0; i < trajectoriesNumber; printf("%d, ", trajectoriesQueue[i++]));
	printf("]");
	
	free(oldTrajectories);
	free(oldQueue);
	
	printf("\nSimpleProjectileWorker:updateProjectiles:%d --> end\n", tick);
#endif	
	
	// update the active trajectory id, needed for a sound
	if (activeTrajId < 0 && addTo >=0 ) activeTrajId = addTo;
	
	// that's it, the projectiles are moved and added, queued and dequeued
}

- (NSInteger)trajectoriesNumber {
	return trajectoriesNumber;
}

- (NSInteger)trajectoryLength:(NSInteger)trajId {
	return trajectoryLength;
}

- (BOOL)hasProjectileOn:(NSInteger)trajId atIndex:(NSInteger)idx {
	if (trajectories[trajId] & (1 << idx)) return TRUE;
	return FALSE;
}

- (BOOL)hasProjectiles:(NSInteger)trajId {
	if (trajectories[trajId]) return TRUE;
	return FALSE;
}

- (BOOL)projectileFell:(NSInteger)trajId {
	return [self hasProjectileOn:trajId atIndex:(trajectoryLength - 1)];
}

- (NSInteger)projectilesNumber:(NSInteger)trajId {
	// TO DO:
	return 0;
}

- (NSInteger)queuedTrajectory:(NSInteger)queueIdx {
	if (queueIdx >= trajectoryQueueCnt) return -1;
	NSInteger orderIdx = (trajectoryQueueIdx + queueIdx) % trajectoryQueueCnt;;
	do {
		orderIdx = (orderIdx + 1) % trajectoryQueueCnt;	
	} while (trajectoriesQueue[orderIdx] < 0);
	return trajectoriesQueue[orderIdx];
}

@end
