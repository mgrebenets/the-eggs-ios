/*
 *  ProjectileWorkerDelegate.h
 *  i4nGoalie
 *
 *  Created by Maksym Grebenets on 12/12/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import "Debugging.h"

@protocol ProjectileWorkerDelegate <Debugging>

@required
- (float)tickSpeed:(NSInteger)tick;
- (void)reset;
- (void)resetProjectiles;
- (void)updateProjectiles:(NSInteger)tick;
- (NSInteger)trajectoriesNumber;
- (NSInteger)trajectoryLength:(NSInteger)trajId;
- (BOOL)hasProjectileOn:(NSInteger)trajId atIndex:(NSInteger)idx;
- (BOOL)hasProjectiles:(NSInteger)trajId;
- (BOOL)projectileFell:(NSInteger)trajId;
- (NSInteger)projectilesNumber:(NSInteger)trajId;
- (NSInteger)queuedTrajectory:(NSInteger)queueIdx;

@property (nonatomic) NSInteger mode;
@property (nonatomic, readonly) NSInteger activeTrajId;
@property (nonatomic) NSInteger points;

@optional

@end