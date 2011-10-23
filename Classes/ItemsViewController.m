//
//  ItemsViewController.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 2/21/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "ItemsViewController.h"
#import "YourOrderTableViewController.h"
#import "NameListViewController.h"
#import "CustomOrderViewController.h"
#import "Constants.h"
#import "JSON.h"
#import "Order.h"
#import "DrinkOrders.h"
#import "URLConnection.h"
#import "SavedDrinksList.h"
#import "Utils.h"
#import "Tracker.h"

#import "ViewCurrentOrdersTableView.h"

@implementation ItemsViewController
@synthesize drink_btn,custom_btn,your_order_btn,favorite_btn;
//CoreData
@synthesize fetchedResultsController, managedObjectContext;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [[Tracker sharedTracker]trackPageView:@"/app_ItemsViewController"];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendOrder:)];
}

-(void)sendOrder:(id)sender
{
	//printf("send Order");
	[[Tracker sharedTracker]trackPageView:@"/app_ItemsViewController_sendOrder"];
	Order *order = [Order sharedOrder];
	//This is the data that got returned from the server when we first went to view the run.. Called  getOrder.php from CurrentRunViewController
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/placeorder.php",baseDomain]]
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:60.0];
	
	[request setHTTPMethod:@"POST"];
	
	SBJSON *parser = [[SBJSON alloc] init];
	NSMutableString* theString = [NSMutableString string];
	
	DrinkOrders *drink_orders = [DrinkOrders instance];
	NSMutableArray *drink_orders_array  = [drink_orders getArray];
		
	for(int i=0;i<[drink_orders_array count];i++)
	{
		NSDictionary *drink_dict = [drink_orders_array objectAtIndex:i];    
		NSString *drink_str = [parser stringWithObject:drink_dict];
		if([drink_orders_array count] >1)
			[theString appendString:[NSString stringWithFormat:@"json=%@",drink_str]];
		else
			[theString appendString:drink_str];

	}
	[parser release];
	
	if(theString != NULL && ![theString isEqualToString:@""])
	{
		NSString *post_str = [NSString stringWithFormat:@"device_id=%@&order=%@&run_id=%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],[Utils urlencode:theString],[[[order currentOrder]objectForKey:@"run"]objectForKey:@"id"]];
		[request setHTTPBody:[post_str dataUsingEncoding:NSUTF8StringEncoding]]; 
		URLConnection *conn = [[URLConnection alloc]init];
		conn.tag =@"submitOrder";
		[conn setDelegate:self];
		[conn initWithRequest:request];
        
        NSLog(@"request URL %@",[request URL]);
        printf("\n");
        NSLog(@"post_str %@",post_str);
        
	}
    else
        [Utils showAlert:@"No Orders Added"withMessage:@"Please add a order" inView:self.view];
    
	//NSLog(@"order id %@",[[[order currentOrder]objectForKey:@"run"]objectForKey:@"id"]);
 
}
- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data
{
	
    [[Tracker sharedTracker]trackPageView:@"/app_ItemsViewController_orderAdded"];
	NSLog(@"data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    
	[Utils showAlert:@"Order Added" withMessage:nil inView:self.view];
	
	DrinkOrders *drink_orders = [DrinkOrders instance];
	[drink_orders clearArray];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    /*
    ViewCurrentOrdersTableView *current_run_view = [[ViewCurrentOrdersTableView alloc]initWithNibName:nil bundle:nil];
	current_run_view.title = @"Orders";
	//Since were adding a new onto this view, we need to push to the new view, and hide the RunViewController
	//That way, we can change views based on if there are orders or not
	UINavigationController *navController = self.navigationController;
	NSMutableArray *controllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
	[controllers removeLastObject];
	navController.viewControllers = controllers;
	[navController pushViewController:current_run_view animated: NO];
	[current_run_view release];
     */
    
    [self.navigationController popViewControllerAnimated:YES];

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) {
		
		DrinkOrders *drink_orders = [DrinkOrders instance];
		NSMutableArray *drink_orders_array  = [drink_orders getArray];
		
		for(int i=0;i<[drink_orders_array count];i++)
		{
			[SavedDrinksList writeDataToFile:[drink_orders_array objectAtIndex:i]];
		}
	}
	
	//Remove the order from memory
	//[[DrinkOrders instance] clearArray];
	
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}
-(IBAction)showDrinkList
{
    [[Tracker sharedTracker]trackPageView:@"/app_ItemsViewController_showDrinkList_btn_clicked"];
	NameListViewController *orderView   = [[NameListViewController alloc]initWithNibName:@"NameListViewController" bundle:nil];
	orderView.orderType = @"Drinks";
	//Pass the Dictionary we got from the server
	UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:orderView];
	[self.navigationController presentModalViewController:nav animated:YES];
	[orderView release];
	[nav release];
	
}
-(IBAction)showCustomList
{
    [[Tracker sharedTracker]trackPageView:@"/app_ItemsViewController_showCustomList_btn_clicked"];
	CustomOrderViewController *customOrder   = [[CustomOrderViewController alloc]initWithNibName:@"CustomOrderViewController" bundle:nil];
	UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:customOrder];
	[self.navigationController presentModalViewController:nav animated:YES];
	[customOrder release];
	[nav release];
}
-(IBAction)showYourOrderList
{
    [[Tracker sharedTracker]trackPageView:@"/app_ItemsViewController_showYourOrderList_btn_clicked"];
	YourOrderTableViewController *showOrder   = [[YourOrderTableViewController alloc]initWithNibName:nil bundle:nil];
	showOrder.type = NULL;
	[self.navigationController pushViewController:showOrder animated:YES];
	[showOrder release];
}
-(IBAction)showFavoritesList
{
    [[Tracker sharedTracker]trackPageView:@"/app_ItemsViewController_showFavoritesList_btn_clicked"];
	YourOrderTableViewController *showOrder   = [[YourOrderTableViewController alloc]initWithNibName:nil bundle:nil];
	showOrder.type = @"favorites";
	[self.navigationController pushViewController:showOrder animated:YES];
	[showOrder release];
	
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void)dealloc {
    [super dealloc];
}


@end
