//
//  FriendsInfo.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/9/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

@protocol FriendLoadedDelegate <NSObject>
@required
- (void)friendDataLoaded:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data;
@end

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FriendsInfo : NSObject {

    id <FriendLoadedDelegate> delegate;
	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
}
//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (retain) id delegate;

-(BOOL)insertFriendData:(NSDictionary *)dict;
-(void)sendFriendDataToServer:(NSDictionary *)friend_dict;
-(void)readFriendsData;
-(BOOL)checkforFriends;
-(BOOL)checkforFriendAdded:(NSDictionary *)dict;
-(BOOL)checkIfContactAdded;
-(NSArray *)getAllFriends;
@end
