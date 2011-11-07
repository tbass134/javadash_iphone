//
//  SummaryTableViewController.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 5/27/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "SummaryTableViewController.h"
#import "TapkuLibrary.h"

#import "MapViewController.h"
#import "FriendsList.h"
#import "SelectTimeView.h"
#import "FriendsTableListView.h"
#import "DashSummary.h"

#import "URLConnection.h"
#import "Constants.h"
#import "JSON.h"

#import "FriendsInfo.h"
#import "Order.h"
#import "Utils.h"

#import "CoffeeRunSampleViewController.h"


#define LOCATION_TEXT	@"Current Location"
#define TIME_TEXT		@"Run Time"
#define PEOPLE_TEXT		@"Attendees"

#define LOCATION_TAG 1
#define TIME_TAG 2
#define PEOPLE_TAG 3

@implementation SummaryTableViewController
//CoreData
@synthesize fetchedResultsController, managedObjectContext;
@synthesize  tableView;
@synthesize adView;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	dash_summary = [[[NSMutableDictionary alloc]init]retain];
	load = [[Loading alloc]init];
	
	
	friends = [[FriendsInfo alloc]init];
	friends.managedObjectContext = self.managedObjectContext;	

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	done_btn= [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(completeSummary:)];
	self.navigationItem.rightBarButtonItem = done_btn;
	
	
 

    cells = [[NSMutableArray alloc] init];
    static NSString *CellIdentifier = @"Cell";	

    TKLabelTextViewCell *location_cell = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    location_cell.editing = NO;
    location_cell.tag = LOCATION_TAG;
    location_cell.label.text = LOCATION_TEXT;
    location_cell.textView.text = @"";
    [cells addObject:location_cell];
    [location_cell release];

    TKLabelTextViewCell *time_cell = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    time_cell.editing = NO;
    time_cell.tag = TIME_TAG;
    time_cell.label.text = TIME_TEXT;
    time_cell.textView.text = @"";
    [cells addObject:time_cell];
    [time_cell release];

    TKLabelTextViewCell *attendees_cell = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    attendees_cell.editing = NO;
    attendees_cell.tag = PEOPLE_TAG;
    attendees_cell.label.text = PEOPLE_TEXT;
    attendees_cell.textView.text = @"";
    [cells addObject:attendees_cell];
    [attendees_cell release];

    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem = done_btn;

}
//This will make sure we have an order and if so, show the data
-(BOOL)hasOrder{
	BOOL success = NO;
	if([friends checkIfContactAdded])	{
		if([friends checkforFriends])
		{
			Order *order = [Order sharedOrder];
			if(![[[order currentOrder] objectForKey:@"run"]objectForKey:@"id"])
				success = YES;
			
			else
			{/*
				UIAlertView *override_current_run_alert = [[UIAlertView alloc]initWithTitle:@"Run already started" message:@"You are currently in a run, are you sure you want to start a new run?. If so, the previous one will be removed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
				[override_current_run_alert show];
				[override_current_run_alert release];
			  */
				success = NO;
				
			}
			
		}
		else {
			[Utils showAlert:@"No Friends" withMessage:@"In Order to user Java Dash to its fullest extent, you should find some friends. Press the 'BUMP' button to make some friends first" inView:self.view];
		}
	}
	else {
		[Utils showAlert:@"No Contact Added" withMessage:@"Please add your contact information to get started with using Java Dash" inView:self.view];
	}	
		
	return success;
}
-(void)reloadData{
	
	printf("reloadData");
	DashSummary *dash = [DashSummary instance];
	NSMutableDictionary *dash_dict = [dash getDict];
	//NSLog(@"dash_dict %@",dash_dict);
	
	if([dash_dict count]==0)
		return;
	
	
	
	NSString *_name = [[dash_dict objectForKey:@"selected_location"]objectForKey:@"name"];
	NSString *_address = [[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"address"]objectAtIndex:0];
	NSString *_cityState = [NSString stringWithFormat:@"%@,%@",[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"city"],[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"state_code"]];

	
	
	cells = [[NSMutableArray alloc] init];
	static NSString *CellIdentifier = @"Cell";	
	
	TKLabelTextViewCell *location_cell = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
	location_cell.tag = LOCATION_TAG;
	location_cell.label.text = LOCATION_TEXT;
	
	
	
	location_cell.textView.text = [NSString stringWithFormat:@"%@\n%@\n%@",_name,_address,_cityState];
	[cells addObject:location_cell];
	[location_cell release];
	
	TKLabelTextViewCell *time_cell = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
	time_cell.tag = TIME_TAG;
	time_cell.label.text = TIME_TEXT;
	time_cell.textView.text = [dash_dict objectForKey:@"selected_date"];
	[cells addObject:time_cell];
	[time_cell release];
	
	TKLabelTextViewCell *attendees_cell = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
	attendees_cell.tag = PEOPLE_TAG;
	attendees_cell.label.text = PEOPLE_TEXT;
	
	NSMutableString *users_str = [[NSMutableString alloc]init];
	for(int i=0;i<[[dash_dict objectForKey:@"selected_friends"] count];i++)
	{
		
		[users_str appendString:[NSString stringWithFormat:@"%@ %@",[[[dash_dict objectForKey:@"selected_friends"] objectAtIndex:i]valueForKey:@"first_name"],[[[dash_dict objectForKey:@"selected_friends"] objectAtIndex:i]valueForKey:@"last_name"]]];
	}
	
	attendees_cell.textView.text = users_str;
	
	[cells addObject:attendees_cell];
	[attendees_cell release];
	
	[self.tableView reloadData];
	
	
	}
-(void)completeSummary:(id)sender
{    
	DashSummary *dash = [DashSummary instance];
	
	NSMutableDictionary *dash_dict = [dash getDict]; 
	//NSLog(@"dash_dict %@", dash_dict);
	
	  if(dash_dict == NULL)
		return;
	
	
	NSString *_address = [[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"address"]objectAtIndex:0];
	NSString *_cityState = [NSString stringWithFormat:@"%@,%@",[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"city"],[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"state_code"]];

	NSString *address = [NSString stringWithFormat:@"%@\n%@",_address,_cityState];
	NSString *selected_yelp_id = [[dash_dict objectForKey:@"selected_location"] objectForKey:@"id"];
    NSString *image_url = @"";
    
    if([[dash_dict objectForKey:@"selected_location"] objectForKey:@"image_url"] != NULL)
        image_url = [Utils urlencode:[[dash_dict objectForKey:@"selected_location"] objectForKey:@"image_url"]];
    
	
    
	NSMutableArray *device_id_array = [[NSMutableArray alloc]init];
	for(int i=0;i<[[dash_dict objectForKey:@"selected_friends"] count];i++)
	{
		[device_id_array addObject:[[[dash_dict objectForKey:@"selected_friends"] objectAtIndex:i]valueForKey:@"device_id"]];
	}
	
	
	if(![[[NSUserDefaults standardUserDefaults]stringForKey:@"is_debug"]boolValue])
	{
		//Make sure we have data before we send it
		if([dash_dict objectForKey:@"selected_date"] == NULL || [dash_dict objectForKey:@"selected_location"] == NULL || [dash_dict objectForKey:@"selected_friends"] == NULL || address == NULL || selected_yelp_id == NULL)
		{
			[Utils showAlert:@"NO Data" withMessage:@"Please add info to Run" inView:self.view];
			return;
		}
	}
	//Send a push to all devices
	NSString *push_type = @"doOrder";
	NSString *runnerInfo = [NSString stringWithFormat:@"first_name=%@&last_name=%@&deviceid=%@&selected_date=%@&selected_name=%@&selected_address=%@&selected_url=%@&selected_yelp_id=%@",
							[[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"],
							[[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"],
							[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],
							[dash_dict objectForKey:@"selected_date"],
							[[dash_dict objectForKey:@"selected_location"] objectForKey:@"name"],
							address,
							image_url,
							selected_yelp_id,
							nil];
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/startrun.php",baseDomain]]
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:60.0];
	
	[request setHTTPMethod:@"POST"];
	NSString *post_str = [NSString stringWithFormat:@"device_tokens=%@&push_type=%@&%@",[device_id_array componentsJoinedByString:@","],push_type,runnerInfo];
    //NSLog(@"post_str %@",post_str);
	[request setHTTPBody:[post_str dataUsingEncoding:NSUTF8StringEncoding]]; 
	URLConnection *conn = [[URLConnection alloc]init];
	conn.tag =@"startRun";
	[conn setDelegate:self];
	[conn initWithRequest:request];
	

	[load showLoading:@"Sending Order" inView:self.view];

}
- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data
{
	//printf("Got Data");
	if([tag isEqualToString:@"startRun"])
	{
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Order Sent" message:@"Your order has been submitted" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[alert show];
		[alert release];
		
		
		//Clear the Order info since we dont need it anymore
		DashSummary *dash = [DashSummary instance];
		[dash clearDict];
		
		
		[self checkForOrders];
	}
	
	[load hideLoading];
	
	if([tag isEqualToString:@"GetOrders"])
	{
    }
}

-(void)checkForOrders
{
	
	//every time we go to this screen, we need to know if an order has been sent,
	//If so, change the Label
	int ts = [[NSDate date] timeIntervalSince1970];
    /*
	NSString *userName = [NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"],[[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"]];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getorders.php?deviceid=%@&name=%@&platform=%@&ts=%i",baseDomain,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],[Utils urlencode:userName],@"IOS",ts]]
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:60.0];
     */
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getorders.php?deviceid=%@&ts=%i",baseDomain,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],ts]]
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:60.0];
	URLConnection *conn = [[URLConnection alloc]init];
	conn.tag =@"GetOrders";
	[conn setDelegate:self];
	[conn initWithRequest:request];
	
	[load showLoading:@"Updating Order" inView:self.view];
	
}
	
/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {

	[self reloadData];
    [super viewDidAppear:animated];
}



-(void)viewWillAppear:(BOOL)animated
{
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [cells count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 120.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [cells objectAtIndex:indexPath.row];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	
	switch (indexPath.row) {
		case 0:
			[self goMapView];
			break;
		case 1:
			[self goTimeView];
			break;
		case 2:
			[self goFriendsView];
			break;
		default:
			break;
	}
}
-(void)goMapView
{
	MapViewController *mapView = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
	[self.navigationController pushViewController:mapView animated:YES];
	[mapView release];
}
-(void)goTimeView
{
	SelectTimeView *timeView = [[SelectTimeView alloc] initWithNibName:@"SelectTimeView" bundle:nil];
	[self.navigationController pushViewController:timeView animated:YES];
	[timeView release];
}
-(void)goFriendsView
{
	FriendsList *friendsView = [[FriendsList alloc] initWithNibName:@"RunDetails" bundle:nil];
	[self.navigationController pushViewController:friendsView animated:YES];
	[friendsView release];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[dash_summary release];
	[load release];
    [super dealloc];
}


@end

