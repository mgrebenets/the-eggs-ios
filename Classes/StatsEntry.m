//
//  StatsEntry.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 12/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StatsEntry.h"
#import "ProjectileObserver.h"

@implementation StatsEntry
@synthesize points, pauses, mode, version, date, application;

#pragma mark NSCoding protocol implementation
- (void)encodeWithCoder:(NSCoder *)coder {  //encode
	[coder encodeObject:date forKey:@"date"];
	[coder encodeInteger:points forKey:@"points"];
	[coder encodeInteger:pauses forKey:@"pauses"];
	[coder encodeInteger:mode forKey:@"mode"];	
	[coder encodeObject:application forKey:@"application"];
	[coder encodeObject:version forKey:@"version"];
}

- (id)initWithCoder:(NSCoder *)coder {  //decode
	date = [[coder decodeObjectForKey:@"date"] retain];
	points = [coder decodeIntegerForKey:@"points"];
	pauses = [coder decodeIntegerForKey:@"pauses"];
	mode = [coder decodeIntegerForKey:@"mode"];
	application = [[coder decodeObjectForKey:@"application"] retain];	
	if (!application) {
		application = NSLocalizedString(@"Unknown", @"Unknown");
	}
	version = [[coder decodeObjectForKey:@"version"] retain];	
	if (!version) {
            version = NSLocalizedString(@"Unknown", @"Unknown");
	}
	return self;
}

#pragma mark Init / dealloc methods
- (void)dealloc {
	[date release];
	//[application release];
	//[version release];
	[super dealloc];
}

// init method
- (id)init {
	if (self = [super init]) {
		date = [[NSDate date] copy];
		points = 0;
		pauses = 0;
		mode = 0;
		application = NSLocalizedString(@"Unknown", @"Unknown");
		version = NSLocalizedString(@"Unknown", @"Unknown");
	}	
	return self;
}

- (id)initWithProjectileObserver:(ProjectileObserver *)observer mode:(NSInteger)gameMode {
	if (self = [super init]) {
		date = [[NSDate date] copy];
		points = observer.points;
		pauses = observer.pauseCnt;
		mode = gameMode;
		application = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
		version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	}
	return self;
}

#pragma mark Comparator
- (NSComparisonResult)statsComparator:(StatsEntry *)stats {
	if (points != stats.points) {
		return (points < stats.points ? NSOrderedDescending : NSOrderedAscending);
	} 
	
	// same points: compare pause counts
	if (pauses != stats.pauses) {
		return (pauses > stats.pauses ? NSOrderedDescending : NSOrderedAscending);
	}
	
	// same points and pauses -- compare by date using NSDate's compare method
	return [date compare:stats.date];
}

#pragma mark Debug str method
- (NSString *)debugStr {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];	
	NSString *str = [NSString stringWithFormat:@"date:%@, points:%d, pauses:%d, mode:%d, app:%@, ver:%@", [formatter stringFromDate:date], points, pauses, mode, application, version];
	[formatter release];
	return str;
}

@end
