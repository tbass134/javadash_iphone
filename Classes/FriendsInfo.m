//
//  FriendsInfo.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/9/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "FriendsInfo.h"
#import "Utils.h"
#import "FlurryAnalytics.h"
#import "DataService.h"

@implementation FriendsInfo
//CoreData
@synthesize fetchedResultsController, managedObjectContext;
@synthesize delegate;

-(BOOL)insertFriendData:(NSDictionary *)dict{
	
    [FlurryAnalytics logEvent:@"Friend Added"];
	BOOL success = NO;
	//printf("insertFriendData");
	//[Utils printDict:dict];
	//printf("\n");
	
	NSManagedObjectContext *context = [self managedObjectContext];    
	NSEntityDescription *friendsEntity = [NSEntityDescription entityForName:@"Friends" inManagedObjectContext:context];
	NSManagedObject *friends = [NSEntityDescription insertNewObjectForEntityForName:[friendsEntity name] inManagedObjectContext:context];
	
	[friends setValue:[dict objectForKey:@"FIRSTNAME"] forKey:@"first_name"];
	[friends setValue:[dict objectForKey:@"LASTNAME"] forKey:@"last_name"];
	[friends setValue:[dict objectForKey:@"TOKEN"] forKey:@"device_id"];
	if([dict objectForKey:@"NUMBER"] != NULL)
		[friends setValue:[dict objectForKey:@"NUMBER"] forKey:@"phone_number"];
	
	if([dict objectForKey:@"EMAIL"] != NULL)
		[friends setValue:[dict objectForKey:@"EMAIL"] forKey:@"email"];
	
	if([dict objectForKey:@"IMAGE"] != NULL)
		[friends setValue:[dict objectForKey:@"IMAGE"] forKey:@"image"];
    
    if([dict objectForKey:@"ENABLE_EMAIL"] != NULL)
		[friends setValue:[NSNumber numberWithBool:[[dict objectForKey:@"ENABLE_EMAIL"]boolValue]] forKey:@"enable_email"];
	
	
	int friendId = [friends hash];
	[friends setValue:[NSNumber numberWithInt:friendId] forKey:@"id"];
	
	NSError *error = nil;
	if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	else {
		success = YES;
	}
    
    if(success)
    {
        //Send the user data to the server
        //[self sendFriendDataToServer:dict];
        
    }
	
	return success;
}
-(BOOL)removeFriend:(NSManagedObject *)friend
{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:friend];
    // Commit the change.
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        return NO;
    }
    return YES;
    
}
-(void)sendFriendDataToServer:(NSDictionary *)friend_dict
{
    [Utils printDict:friend_dict];
    NSString *userName = [Utils urlencode:[NSString stringWithFormat:@"%@ %@",[friend_dict objectForKey:@"FIRSTNAME"], [friend_dict objectForKey:@"LASTNAME"]]];
    
    
     BOOL userWasAdded = [[DataService sharedDataService]addUser:[Utils urlencode:userName]
                                                        deviceID:[friend_dict objectForKey:@"TOKEN"]
                                                           email:[friend_dict objectForKey:@"EMAIL"] 
                                                    emailEnabled:[[friend_dict objectForKey:@"ENABLE_EMAIL"]boolValue]
                                                      facebookID:0
                                                      enablePush:nil];
    if(userWasAdded)
    {
        printf("Friend Data sent to server");
        [[self delegate] friendDataLoaded:YES withTag:nil andData:nil];
    }
    
  }
-(void)readFriendsData{
	NSManagedObjectContext *context = [self managedObjectContext];    
	NSEntityDescription *friendEnity = [NSEntityDescription entityForName:@"Friends" inManagedObjectContext:context];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:friendEnity];
	
	NSArray *friends = [context executeFetchRequest:fetchRequest error:nil];
	
	id friend;
	NSEnumerator *it = [friends objectEnumerator];
	while((friend = [it nextObject]) != nil) {        
		//NSLog(@"FirstName: %@", [friend valueForKey:@"first_name"]);
		//NSLog(@"LastName: %@", [friend valueForKey:@"last_name"]);
		//NSLog(@"Number: %@", [friend valueForKey:@"phone_number"]);
		//NSLog(@"Token: %@", [friend valueForKey:@"device_id"]);
		//printf("\n");
	}
	[fetchRequest release];
}
-(BOOL)checkforFriends
{
	NSManagedObjectContext *context = [self managedObjectContext];  
	NSEntityDescription *friendEnity = [NSEntityDescription entityForName:@"Friends" inManagedObjectContext:context];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:friendEnity];
	
	NSArray *friends = [context executeFetchRequest:fetchRequest error:nil];
	[fetchRequest release];
	if([friends count]>0)
		return YES;
	else {
		return NO;
	}
	
}
-(BOOL)checkforFriendAdded:(NSDictionary *)dict
{
    //[Utils printDict:dict];
	BOOL success = NO;	
	NSArray *friends_array = [self getAllFriends];

	for(int i=0;i<[friends_array count];i++)
	{
        if([[[friends_array objectAtIndex:i]valueForKey:@"first_name"]isEqualToString:[dict objectForKey:@"FIRSTNAME"]]
		   && [[[friends_array objectAtIndex:i]valueForKey:@"last_name"]isEqualToString:[dict objectForKey:@"LASTNAME"]] 
		   && [[[friends_array objectAtIndex:i]valueForKey:@"device_id"]isEqualToString:[dict objectForKey:@"TOKEN"]])
        {
			success = YES;
            break;
        }
		
	}
	return	success;
}
//This is different becuase the Dictionary returned is slightly different
-(BOOL)checkFriendAdded:(NSDictionary *)dict
{
    BOOL success = NO;	
	NSArray *friends_array = [self getAllFriends];
    
	for(int i=0;i<[friends_array count];i++)
	{
        if([[[friends_array objectAtIndex:i]valueForKey:@"device_id"]isEqualToString:[dict objectForKey:@"deviceid"]])
        {
			success = YES;
            break;
        }
		
	}
	return	success;
 
}
-(BOOL)checkIfContactAdded
{
	//this will only check to see if the UserDefaults have the first name,last name and #
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTNAME"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"LASTNAME"])
		return YES;
	else
		return NO;
}

-(NSArray *)getAllFriends
{
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init]autorelease];
	NSManagedObjectContext *context = [self managedObjectContext];    
	NSEntityDescription *friendsEntity = [NSEntityDescription entityForName:@"Friends" inManagedObjectContext:context];
	[fetchRequest setEntity:friendsEntity];
	
	NSError *error;
	return [context executeFetchRequest:fetchRequest error:&error];
}


@end
