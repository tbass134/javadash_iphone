//
//  SavedDrinksList.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SavedDrinksList : NSObject {

	NSString *path;
}
+(void)getSavedDrinksPlist;
+(BOOL)writeDataToFile:(NSMutableDictionary *)data;
+(BOOL)removeFromList:(NSMutableDictionary *)data;
+(NSMutableArray *)getAllDrinks;




@end
