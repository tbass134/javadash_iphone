//
//  FacebookViewController.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 10/16/11.
//  Copyright (c) 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLoginButton.h"
#import "TapkuLibrary.h"
#import <CoreData/CoreData.h>
#import "CoffeeRunSampleAppDelegate.h"

@interface FacebookViewController : UIViewController<UITableViewDelegate>
{
    IBOutlet FBLoginButton* _fbButton;
    IBOutlet UIButton* _getUserInfoButton;
    IBOutlet UITableView *table_view;
    NSMutableArray *urlArray;
    NSMutableArray *images;
    NSMutableArray *names;
    
    NSMutableArray *fb_array;
    NSDictionary *users_dict;
    
    NSArray *friends;
    
    UIBarButtonItem *done_btn;
    UIBarButtonItem *cancel_btn;
     UIBarButtonItem *followAll_btn;
    BOOL followAll_clicked;
    
    
    //Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	CoffeeRunSampleAppDelegate *delegate;
	


}
//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property(nonatomic,retain) IBOutlet UITableView *table_view;
-(IBAction)fbButtonClick:(id)sender;
-(IBAction)getUserInfo:(id)sender;

-(void)addUserToList:(NSDictionary *)user withImage:(UIImage *)image;
@end