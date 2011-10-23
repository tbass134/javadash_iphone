//
//  Singleton.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 5/27/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Singleton : NSObject 
{
	
	NSMutableDictionary *keys;
	
}
@property (nonatomic, retain) NSMutableDictionary *keys;
+ (Singleton *)sharedSingleton;