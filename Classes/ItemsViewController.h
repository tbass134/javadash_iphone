//
//  ItemsViewController.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 2/21/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ItemsViewController : UIViewController<NSFetchedResultsControllerDelegate> {

	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

	
	
	IBOutlet UIButton *drink_btn;
	IBOutlet UIButton *custom_btn;
	IBOutlet UIButton *your_order_btn;
	IBOutlet UIButton *favorite_btn;
}
@property(nonatomic,retain)UIButton *drink_btn;
@property(nonatomic,retain)UIButton *custom_btn;
@property(nonatomic,retain)UIButton *your_order_btn;
@property(nonatomic,retain)UIButton *favorite_btn;

//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(IBAction)showDrinkList;
-(IBAction)showCustomList;
-(IBAction)showYourOrderList;
-(IBAction)showFavoritesList;

@end
