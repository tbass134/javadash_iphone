//
//  CoffeeRunSampleViewController.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 12/14/10.
//  Copyright 2010 Dark Bear Interactive. All rights reserved.
//

#import "CoffeeRunSampleViewController.h"
#import "MapViewController.h"
#import "ViewCurrentOrdersTableView.h"
#import "ItemsViewController.h"
#import "Utils.h"
#import <MapKit/MapKit.h>
#import "Constants.h"
#import "JSON.h"
#import "Order.h"

#import "InfoViewController.h"

#import "SummaryTableViewController.h"
#define VIEW_ORDER @"View Order"
#define EDIT_ORDER @"Edit Order"
#define PLACE_ORDER @"Place Order"

@implementation CoffeeRunSampleViewController
//CoreData
@synthesize fetchedResultsController, managedObjectContext;

@synthesize info_btn,settings_btn;
@synthesize start_run_btn,view_order_btn;
@synthesize nav;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		delegate = [[UIApplication sharedApplication] delegate];
		prefs = [NSUserDefaults standardUserDefaults];
		
		
    }
    return self;
}
-(void)reloadData:(id)sender
{
	[self checkForOrders];
}
//Main Buttons
-(IBAction)startRun:(id)sender
{
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self cancelCurrentRun];
	}
	
}

-(IBAction)viewOrder:(id)sender
{
    
	
    //Only the person doing the dash sees View Order. The other people see PLace Order and then Edit Order on the order's they placed.
    //The person doing the dash cant edit because they can put in their own order
	printf("View Order");
	if([friends checkIfContactAdded])	{
		NSLog(@"view_order_btn.titleLabel.text %@",view_order_btn.titleLabel.text);
		
		Order *order = [Order sharedOrder];		
		if([order currentOrder] != NULL)
		{
			if([view_order_btn.titleLabel.text isEqualToString:	PLACE_ORDER])
			{
				ItemsViewController *currentRun = [[ItemsViewController alloc]initWithNibName:@"ItemsViewController" bundle:nil];
				//currentRun.run_data = run_dict;
				currentRun.managedObjectContext = self.managedObjectContext;
				[self.navigationController pushViewController:currentRun animated:YES];
				[currentRun release];
			}
			else if([view_order_btn.titleLabel.text isEqualToString:VIEW_ORDER])
			{
				
				ViewCurrentOrdersTableView *currentOrdersView = [[ViewCurrentOrdersTableView alloc]initWithNibName:nil bundle:nil];
				[self.navigationController pushViewController:currentOrdersView animated:YES];
				[currentOrdersView release];
				
			}
			else if([view_order_btn.titleLabel.text isEqualToString:EDIT_ORDER])
			{
				printf("Edit the Drink Order");
				ViewCurrentOrdersTableView *currentOrdersView = [[ViewCurrentOrdersTableView alloc]initWithNibName:nil bundle:nil];
				[self.navigationController pushViewController:currentOrdersView animated:YES];
				[currentOrdersView release];
			}
		}
		else {
			[Utils showAlert:@"No Orders available" withMessage:nil inView:self.view];
		}

	}
	else {
		[Utils showAlert:@"No Contact Added" withMessage:@"Please add your contact information to get started with using Java Dash" inView:self.view];
		[self getContactInfo];
	}

}


-(IBAction)viewInfo:(id)sender
{
	printf("view Info");
	
	InfoViewController *info = [[InfoViewController alloc]initWithNibName:@"InfoViewController" bundle:nil];
	info.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	UINavigationController * navigation = [[UINavigationController alloc]initWithRootViewController:info];

    [self.navigationController presentModalViewController:navigation animated:YES];
	[info release];
	[navigation release];

}

-(void)getContactInfo
{
	if(![friends checkIfContactAdded])	
	{
		NSLog(@"Show Address Book");
	}

}
-(void)checkForOrders
{
	if([friends checkIfContactAdded])
	{
		//every time we go to this screen, we need to know if an order has been sent,
		//If so, change the Label
		int ts = [[NSDate date] timeIntervalSince1970];
        /*
		NSString *userName = [NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"],[[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"]];
		NSLog(@"userName %@",[Utils urlencode:userName]);
		NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getorders.php?deviceid=%@&name=%@&platform=%@&ts=%i",baseDomain,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],[Utils urlencode:userName],@"IOS",ts]]
															   cachePolicy:NSURLRequestReturnCacheDataElseLoad
														   timeoutInterval:60.0];
         */
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getorders.php?deviceid=%@&ts=%i",baseDomain,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],ts]]
                                                               cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                           timeoutInterval:60.0];
		NSLog(@"url %@", [request URL]);
		URLConnection *conn = [[URLConnection alloc]init];
		conn.tag =@"GetOrders";
		[conn setDelegate:self];
		[conn initWithRequest:request];
		
		
	}
	else {
		[Utils showAlert:@"No Contact Added" withMessage:@"Please add your contact information to get started with using Java Dash" inView:self.view];
		[self getContactInfo];
	}

}
-(void)viewDidAppear:(BOOL)animated
{
	//[self checkForOrders];
}
- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data
{
	
	
	if(!success)
	{
		[Utils showAlert:@"Could not connect to server" withMessage:@"Please try again" inView:nil];
		return;
	}
	
	
	//NSLog(@"data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	//if we get a vaild order than instert your drink and send that to the server
	NSString * json_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	//NSLog(@"json_str %@",json_str);
	SBJSON *parser = [[SBJSON alloc] init];
	//Save it in the Singleton class
	Order *order = [Order sharedOrder];
	[order setOrder:[parser objectWithString:json_str error:nil]];
	NSDictionary *user_order = [order currentOrder];
	[parser release];
    [json_str release];
	
	if([tag isEqualToString:@"cancelRun"])
	{
		printf("Run Canceled");
		[Utils showAlert:@"Previous Run Canceled" withMessage:nil inView:self.view];
		[self startRun];
		return;
	}
	if(user_order == NULL)
	{
		view_order_btn.enabled = NO;
		[Utils showAlert:@"Error Loading Data" withMessage:@"Please try again" inView:nil];
		return;
	}
	if(![[user_order objectForKey:@"run"]objectForKey:@"id"])
	{
		view_order_btn.enabled = NO;
		[Utils showAlert:@"No Orders Available" withMessage:nil inView:nil];
		return;
	}
	
	[Utils printDict:user_order];

	if([user_order objectForKey:@"run"] != NULL)
	{
		view_order_btn.enabled = YES;
		//If this device started a run, change the button to show the summary of all people who have orders
		//Also need to check if there are any attenedes who have orders
		if([[[user_order objectForKey:@"run"] objectForKey:@"is_runner"] intValue] == 1)
		{
			printf("change title");
			[view_order_btn setTitle:VIEW_ORDER forState:UIControlStateNormal];
		}
		else
		{
			if([[user_order objectForKey:@"run"] objectForKey:@"orders"])
				[view_order_btn setTitle:EDIT_ORDER forState:UIControlStateNormal];
			else
				[view_order_btn setTitle:PLACE_ORDER forState:UIControlStateNormal];
		}
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"reloadData" object:nil];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData:)];

	friends = [[FriendsInfo alloc]init];
	friends.managedObjectContext = self.managedObjectContext;	
	NSLog(@"self.managedObjectContext %@",self.managedObjectContext);
	
		
	//[self readFriendsData];
	[self getContactInfo];
	
	if([friends checkIfContactAdded] && [[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"] != NULL)
		[self checkForOrders];	
	
}

/*
	Cancels the current run
*/

-(void)cancelCurrentRun
{
	Order *order = [Order sharedOrder];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/completerun.php?deviceid=%@&run_id=%@",
																							 baseDomain,
																							 [[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"]
																							 ,[[[order currentOrder] objectForKey:@"run"]objectForKey:@"id"]]]
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:60.0];
	
	URLConnection *conn = [[URLConnection alloc]init];
	
	NSLog(@"url %@", [request URL]);
	conn.tag =@"cancelRun";
	[conn setDelegate:self];
	[conn initWithRequest:request];

}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
} 




- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [friends release];
    [super dealloc];
}

@end
