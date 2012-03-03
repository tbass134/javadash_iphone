//
//  CoffeeRunSampleViewController.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 12/14/10.
//  Copyright 2010 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoffeeRunSampleAppDelegate.h"
#import "FriendsInfo.h"

@interface CoffeeRunSampleViewController : UIViewController<NSFetchedResultsControllerDelegate> {

	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	CoffeeRunSampleAppDelegate *delegate;
	
	UIView *mainView;
	
	IBOutlet UIButton *start_run_btn;
	IBOutlet UIButton *view_order_btn;
	
	
	IBOutlet UIButton *info_btn;
	IBOutlet UIButton *settings_btn;
	
	IBOutlet UINavigationController *nav;
	NSUserDefaults *prefs;
	FriendsInfo *friends;
	
    
}
//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (retain,nonatomic) UIButton *start_run_btn;
@property (retain,nonatomic) UIButton *view_order_btn;
@property (retain,nonatomic) UIButton *info_btn;
@property (retain,nonatomic) UIButton *settings_btn;

//@property (retain,nonatomic) UIButton *friends_btn;
@property (retain,nonatomic) IBOutlet UINavigationController *nav;
-(void)getContactInfo;
-(void)checkForOrders;

-(IBAction)startRun:(id)sender;
-(IBAction)viewOrder:(id)sender;

-(void)startRun;

-(IBAction)viewInfo:(id)sender;


-(void)cancelCurrentRun;
@end

