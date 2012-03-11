//
//  FavoriteLocations.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/8/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "FavoriteLocations.h"


@implementation FavoriteLocations
//@synthesize path;
+(BOOL)writeDataToFile:(NSString *)str
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"LocationFavorites.plist"];
	
    BOOL success = NO;
    NSMutableArray *plist = [NSMutableArray arrayWithContentsOfFile:path];
    if (plist == nil) plist = [NSMutableArray array];
    [plist addObject:str];
    success = [plist writeToFile:path atomically:YES];

	return success;
}
+(NSMutableArray *)getLastFavoriteLocation
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"LocationFavorites.plist"];
	
	NSMutableArray *plist = [NSMutableArray arrayWithContentsOfFile:path];
	return [plist objectAtIndex:[plist count]-1];
}
+(NSMutableArray *)getAllFavoriteLocations
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"LocationFavorites.plist"];
	
	NSMutableArray *plist = [NSMutableArray arrayWithContentsOfFile:path];
	return plist;
}
+(BOOL)removeFromList:(NSString *)str
{

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"LocationFavorites.plist"];
	
    NSMutableArray *plist = [NSMutableArray arrayWithContentsOfFile:path];
    
    //Loop to find id
    for(int i=0;i<[plist count];i++)
    {
     if([str isEqualToString:[plist objectAtIndex:i]])
     {
         [plist removeObjectAtIndex:i];
         break;
     }
       
    }    
    [plist removeObject:str];
        
    return [plist writeToFile:path atomically:YES];
		
}
@end
