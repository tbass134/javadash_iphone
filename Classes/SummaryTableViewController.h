//
//  SummaryTableViewController.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 5/27/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsInfo.h"
#import <CoreData/CoreData.h>
#import "AdWhirlDelegateProtocol.h"
@class AdWhirlView;

@interface SummaryTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate,AdWhirlDelegate> {

	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	UIBarButtonItem *done_btn;
	NSMutableArray *cells;
	NSMutableDictionary *dash_summary;
	FriendsInfo *friends;
    IBOutlet UITableView *tableView;
    AdWhirlView *adView;
	
}
//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain)IBOutlet UITableView *tableView;
@property (nonatomic,retain) AdWhirlView *adView;

-(BOOL)hasOrder;
-(void)reloadData;

-(void)goMapView;
-(void)goTimeView;
-(void)goFriendsView;
-(void)checkForOrders;
@end
