//
//  StatsEntry.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectileObserver;

@interface StatsEntry : NSObject <NSCoding> {
	NSDate *date;
	NSInteger points;
	NSInteger pauses;
	NSInteger mode;
	NSString *application;
	NSString *version;
}

- (id)initWithProjectileObserver:(ProjectileObserver *)observer mode:(NSInteger)gameMode;
// comparator selector
- (NSComparisonResult)statsComparator:(StatsEntry *)stats;
// debug intfo str
- (NSString *)debugStr;

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSInteger points;
@property (nonatomic, readonly) NSInteger pauses;
@property (nonatomic, readonly) NSInteger mode;
@property (nonatomic, retain) NSString *application;
@property (nonatomic, readonly) NSString *version;


@end
