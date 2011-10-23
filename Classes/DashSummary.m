//
//  DashSummary.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 5/27/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "DashSummary.h"


@implementation DashSummary

-(id)init
{
	self = [super init];
	globalDict = [[NSMutableDictionary alloc]init];
	return self;
}
+(DashSummary *)instance
{
	static DashSummary *instance;
	@synchronized(self)
	{
		if(!instance)
			instance = [[DashSummary alloc]init];
	}
	return instance;
}

-(NSMutableDictionary *)getDict
{
	return globalDict;
}

-(void)clearDict
{
	if(globalDict != nil)
	{
		globalDict = nil;
		globalDict = [[NSMutableDictionary alloc]init];
	}
}
		
		

@end
