//
//  Order.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Order.h"

static Order *sharedInstance = nil;

@implementation Order
+(Order *)sharedOrder
{
	@synchronized (self) {
		if (sharedInstance == nil) {
			[[self alloc] init]; // assignment not done here, see allocWithZone
		}
	}
	
	return sharedInstance;
}
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  // This is sooo not zero
}

- (id)init
{
	@synchronized(self) {
		[super init];	
		current_order = nil; //need to load the data here
		return self;
	}
}

- (void)setOrder:(NSMutableDictionary *)order
{
	@synchronized(self) {
		if (current_order != order) {
			[current_order release];
			current_order = [order retain];
		}
	}
}

- (NSMutableDictionary *)currentOrder
{
	@synchronized(self) {
		return current_order;
	}	
}

-(void)clearOrder
{
    [current_order removeAllObjects];
    current_order = nil;
}
-(void)clearOrders
{
    if([[current_order objectForKey:@"run"]objectForKey:@"orders"] != NULL)
        [[[current_order objectForKey:@"run"]objectForKey:@"orders"] removeAllObjects];
}
//Loading Data methods
@end
