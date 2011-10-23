//
//  FriendsInfo.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/9/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FriendsInfo : NSObject {

	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
}
//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(BOOL)insertFriendData:(NSDictionary *)dict;
-(void)readFriendsData;
-(BOOL)checkforFriends;
-(BOOL)checkforFriendAdded:(NSDictionary *)dict;
-(BOOL)checkIfContactAdded;
-(NSArray *)getAllFriends;
@end
