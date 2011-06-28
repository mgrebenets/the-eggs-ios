/*
 *  Debugging.h
 *  i4nGoalie
 *
 *  Created by Maksym Grebenets on 3/21/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

@protocol Debugging

@optional
- (void)printOut;
- (NSString *)debugMsg;
- (void)printBits:(char)number;
- (NSString *)bitsString:(char)number;

@end