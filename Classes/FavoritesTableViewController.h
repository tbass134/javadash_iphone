//
//  FavoritesTableViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/7/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MBProgressHUD.h"
@interface FavoritesTableViewController : UITableViewController<MBProgressHUDDelegate> {

    MBProgressHUD *HUD;
	NSMutableArray *favorites_array;
    NSArray *yelp_id_array;
    
	
	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    
    NSMutableData *_yelpResponseData;
}
@property (nonatomic, retain) NSMutableArray *favorites_array;
@property (nonatomic, retain) NSArray *yelp_id_array;


//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)loadYelp:(NSString *)yelp_id;
@end
