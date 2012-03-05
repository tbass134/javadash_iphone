//
//  RunViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/9/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FriendsInfo.h"
#import "MBProgressHUD.h"
@interface RunViewController : UIViewController<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,MBProgressHUDDelegate> {

	
	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    
    UIBarButtonItem *reloadDataBtn;
    UIBarButtonItem *showOptionsBtn;
    UIBarButtonItem *startRunBtn;
    MBProgressHUD *HUD;
    
    
    //View Run
    IBOutlet UIView *view_run_view;
	IBOutlet UIImageView *yelp_img;
	IBOutlet UITextView *run_info_txt;
	IBOutlet UITextView *run_time_txt;
	IBOutlet UITableView *view_run_table;
	
	NSMutableArray *orders_cells;
    
    NSTimer *run_countdown_timer;
    NSDate *run_date;
    
    //Start Run
    IBOutlet UIView *start_run_view;
    IBOutlet UITableView *start_run_table;
	NSMutableArray *cells;
	NSMutableDictionary *dash_summary;
	FriendsInfo *friends;
    BOOL orderEnded;
    
    //No Runs
    IBOutlet UIView *noRuns_view;
    IBOutlet UILabel *NoOrdersTitle;
    IBOutlet UILabel *NoOrdersMessage;
}

//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//View Run
@property(nonatomic,retain)IBOutlet UIImageView *yelp_img;
@property(nonatomic,retain)IBOutlet UITextView *run_info_txt;
@property(nonatomic,retain)IBOutlet UITextView *run_time_txt;
@property(nonatomic,retain)IBOutlet UITableView *table_view;




-(void)GetOrders;
-(void)checkForOrders;
-(void)startRun;
-(void)viewRun;
-(void)gotoScreen;

//View Run
-(void)initShowRun;
-(void)completeRun;

//Start Run
-(void)initStartRun;
-(BOOL)hasOrder;
-(void)reloadStartRunData;
-(void)submitDash:(NSDictionary *)dash_dict;



-(void)goMapView;
-(void)goTimeView;
-(void)goFriendsView;
-(void)checkForOrders;
-(BOOL)isRunDataFilledOut;

-(void)loadYelpImage:(NSString *)img_str;
-(void)displayPhoto:(UIImage *)photo;
-(void)displayDefaultPhoto;

-(void)startTimer;
-(void)stopTimer;

-(void)showNoOrdersView:(BOOL)show withTitle:(NSString *)title andMessage:(NSString *)message;

@end
