//
//  DrinkOrders.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 5/27/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrinkOrders : NSObject {

	NSMutableArray *globalArray;
}
+(DrinkOrders *)instance;

-(NSMutableArray *)getArray;
-(void)clearArray;
@end
