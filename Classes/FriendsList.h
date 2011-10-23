//
//  RunDetails.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 1/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@interface FriendsList : UIViewController<UIPickerViewDelegate,UITableViewDelegate,UITableViewDataSource> {

	IBOutlet UITableView *tableView;
	IBOutlet UIButton *selected_friends_btn;
	
	NSMutableArray *friendsArray;

	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	NSArray *_friends_array;
	
	NSMutableArray *selected_friends;
	
	
}
@property (retain,nonatomic) IBOutlet UITableView *tableView;
@property (retain,nonatomic) IBOutlet IBOutlet UIButton *selected_friends_btn;
@property (retain,nonatomic) NSMutableArray *selected_friends;

//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *friends_array;

-(void)readFriendsData;
-(IBAction)addFriends;
@end
