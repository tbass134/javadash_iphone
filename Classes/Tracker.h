//
//  Tracker.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 7/26/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tracker : NSObject

+(Tracker *)sharedTracker;
-(void)trackEvent:(NSString *)eventName action:(NSString *)action label:(NSString *)label value:(int)value;
-(void)trackPageView:(NSString *)name;
@end
