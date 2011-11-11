//
//  DashSummary.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 5/27/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "DrinkOrders.h"


@implementation DrinkOrders

-(id)init
{
	self = [super init];
	globalArray = [[NSMutableArray alloc]init];
	return self;
}
+(DrinkOrders *)instance
{
	static DrinkOrders *instance;
	@synchronized(self)
	{
		if(!instance)
			instance = [[DrinkOrders alloc]init];
	}
	return instance;
}

-(NSMutableArray *)getArray
{
	return globalArray;
}
-(void)clearArray
{
    globalArray = nil;
    globalArray = [[NSMutableArray alloc]init];

}

@end
