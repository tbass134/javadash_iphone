//
//  FavoriteLocations.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/8/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FavoriteLocations : NSObject {

	//NSString *path;
}
//å@property(nonatomic,retain)NSString *path;
+(void)getFavoritesPlist;
+(BOOL)writeDataToFile:(NSMutableDictionary *)data;
+(NSMutableArray *)getLastFavoriteLocation;
+(NSMutableArray *)getAllFavoriteLocations;
+(BOOL)removeFromList:(NSMutableDictionary *)data;
@end
