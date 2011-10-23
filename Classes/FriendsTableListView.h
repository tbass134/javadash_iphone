//
//  FriendsTableListView.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 2/15/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FriendsTableListView : UITableViewController<UITableViewDataSource> {

	IBOutlet UITableView *tableView;
	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	NSArray *_friends_array;
	NSMutableArray *selected_friends;

	int lastIndexPath;
}
@property (retain,nonatomic) IBOutlet UITableView *tableView;
//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *friends_array;

-(void)readFriendsData;
@end
