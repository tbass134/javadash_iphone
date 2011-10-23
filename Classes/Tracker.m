//
//  Tracker.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 7/26/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "Tracker.h"
#import "GANTracker.h"

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;
static Tracker *sharedTracker = nil;

@implementation Tracker

+(Tracker *)sharedTracker
{
	@synchronized (self) {
		if (sharedTracker == nil) {
            
            [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-11548158-2"
                                                   dispatchPeriod:kGANDispatchPeriodSec
                                                         delegate:nil];

            
			[[self alloc] init]; // assignment not done here, see allocWithZone
		}
	}
	
	return sharedTracker;
}
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedTracker == nil) {
            sharedTracker = [super allocWithZone:zone];
            return sharedTracker;  // assignment and return on first allocation
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
		return self;
	}
}
-(void)trackEvent:(NSString *)eventName action:(NSString *)action label:(NSString *)label value:(int)value
{
    NSError *error;
    
    if (![[GANTracker sharedTracker] trackEvent:eventName
                                         action:action
                                          label:label
                                          value:value
                                      withError:&error]) {
        NSLog(@"error in trackEvent");
    }
     
     
}

-(void)trackPageView:(NSString *)name
{
    
     NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:name
                                         withError:&error]) {
        NSLog(@"error in trackPageview");
    }
     

}


@end
