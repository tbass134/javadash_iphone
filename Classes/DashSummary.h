//
//  DashSummary.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 5/27/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DashSummary : NSObject {

	NSMutableDictionary *globalDict;
}
+(DashSummary *)instance;

-(NSMutableDictionary *)getDict;
-(id)init;
-(void)clearDict;

@end
