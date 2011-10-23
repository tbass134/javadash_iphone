//
//  Singleton.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 5/27/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "Singleton.h"
@implementation Singleton

- (id)init
{
	if ( self = [super init] )
	{
		self.keys = [[NSMutableDictionary alloc] init];
	}
	return self;
	
}

+ (Singleton *)sharedSingleton
{
	@synchronize shared
	{
		if ( !shared || shared == NULL )
		{
			// allocate the shared instance, because it hasn't been done yet
			shared = [[Singleton alloc] init];
		}
		
		return shared;
	}
}

- (void)dealloc
{
	NSLog(@"Deallocating singleton...");
	[keys release];
	
	[super dealloc];
}

@end
