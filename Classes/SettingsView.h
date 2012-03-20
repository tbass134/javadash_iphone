//
//  SettingsView.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/9/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BumpAPI.h"
#import "Bumper.h"
#import "CoffeeRunSampleAppDelegate.h"
#import "FriendsInfo.h"
#import "MBProgressHUD.h"

@interface SettingsView : UIViewController<BumpAPIDelegate,UITableViewDelegate, UITableViewDataSource,MBProgressHUDDelegate> {

    IBOutlet UIView *mainView;
    IBOutlet UIScrollView *scrollView;
	IBOutlet UIButton *bump_btn;
    IBOutlet UIButton *remove_ads_btn;
	IBOutlet UITableView *table_view;
    IBOutlet UIImageView *profile_image;
    IBOutlet UILabel *profile_name;
    IBOutlet UILabel *no_friends_txt;
	MBProgressHUD *HUD;
	
	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	CoffeeRunSampleAppDelegate *delegate;
	
	BumpAPI *bumpObject;
	int packetsAttempted;
	FriendsInfo *friends;
	NSArray *friends_array;
    
}
//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (retain,nonatomic) UIButton *bump_btn;
@property (retain,nonatomic) UITableView *table_view;
@property (retain,nonatomic) NSArray *friends_array;


-(void)configBump;
-(void)startBump;
-(void)stopBump;
-(void)sendBumpData;
-(IBAction)testBump:(id)sender;
-(IBAction)removeAds:(id)sender;
-(IBAction)updateProfile:(id)sender;
-(IBAction)goFacebook:(id)sender;
-(IBAction)goHelp:(id)sender;
-(void)readFriendsData;
-(void)appPurchased;
@end
