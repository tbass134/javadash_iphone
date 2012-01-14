//
//  Order.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Order : NSObject {

	NSMutableDictionary *current_order;
}
+(Order *)sharedOrder;

- (void)setOrder:(NSMutableDictionary *)order;
-(NSMutableDictionary *)currentOrder;
-(void)clearOrder;

@end
