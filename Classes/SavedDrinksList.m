//
//  SavedDrinksList.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SavedDrinksList.h"


@implementation SavedDrinksList

+(void)getSavedDrinksPlist
{
    /*
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"SavedDrinks.plist"];
     */
}
+(BOOL)writeDataToFile:(NSMutableDictionary *)data
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"SavedDrinks.plist"];
	BOOL success = NO;
	printf("Add it to the list");
	NSMutableArray *plist = [NSMutableArray arrayWithContentsOfFile:path];
	if (plist == nil) plist = [NSMutableArray array];
    
    
    //Loop to find the same timestamp
    //This is used if the order has been updated, we need to deleted the one in the plist and add the new one
    for(int i=0;i<[plist count];i++)
    {
        if([[data objectForKey:@"timestamp"] isEqualToString:[[plist objectAtIndex:i]objectForKey:@"timestamp"]])
        {
            [plist removeObjectAtIndex:i];
            break;
        }
        
    }    
	[plist addObject:data];
	success = [plist writeToFile:path atomically:YES];

	return success;
}
+(BOOL)removeFromList:(NSMutableDictionary *)data
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"SavedDrinks.plist"];
    
	BOOL success = NO;
	NSMutableArray *plist = [NSMutableArray arrayWithContentsOfFile:path];
	//if (plist == nil) plist = [NSMutableArray array];
    
    for(int i=0;i<[plist count];i++)
    {
        if([[data objectForKey:@"timestamp"] isEqualToString:[[plist objectAtIndex:i]objectForKey:@"timestamp"]])
        {
            [plist removeObjectAtIndex:i];
            break;
        }
    }
	[plist removeObject:data];
	success =  [plist writeToFile:path atomically:YES];
	NSLog(@"success %d",success);
	return success;	
	
}

+(NSMutableArray *)getAllDrinks
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"SavedDrinks.plist"];
    
	NSMutableArray *plist = [NSMutableArray arrayWithContentsOfFile:path];
	return plist;	
}
@end
