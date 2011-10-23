//
//  ViewCurrentOrdersTableView.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/11/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "ViewCurrentOrdersTableView.h"
#import "EditOrderView.h"
#import "TapkuLibrary.h"
#import "Order.h"

#import "Constants.h"
#import "JSON.h"
#import "URLConnection.h"
#import "Utils.h"
#import "ItemsViewController.h"
#import "DrinkOrders.h"
#import "Tracker.h"

#import "CoffeeRunSampleAppDelegate.h"


#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f


@implementation ViewCurrentOrdersTableView
@synthesize run_array;
@synthesize tableView;
@synthesize adView;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];/Users/Antonio/Downloads/fp10.1_debug_archive.zip
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
    noOrdersView.hidden = YES;
	
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithTitle:@"Add to Order" style:UIBarButtonSystemItemAdd target:self action:@selector(placeOrder:)]autorelease];
	
	
	//Event listener to update order when an order has been editied
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrderEdited:) name:@"OrderEdited" object:nil];

    /*
    CGRect tableFrame =  self.tableView.frame;
    tableFrame.size.h = self.view.bounds.size.height;
    self.tableView.frame = tableFrame;
    */
	//[self loadData];
}
-(void)placeOrder:(id)sender
{
	ItemsViewController *currentRun = [[ItemsViewController alloc]initWithNibName:@"ItemsViewController" bundle:nil];
	//currentRun.run_data = run_dict;
	//currentRun.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:currentRun animated:YES];
	[currentRun release];
	
}
-(void)OrderEdited:(id)sender
{
	//printf("Order has been edited");
	
	int ts = [[NSDate date] timeIntervalSince1970];
	NSString *userName = [NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"],[[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"]];
	//NSLog(@"userName %@",[Utils urlencode:userName]);
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getorders.php?deviceid=%@&name=%@&platform=%@&i=%i",baseDomain,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],[Utils urlencode:userName],@"IOS",ts]]
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:60.0];
	//NSLog(@"url %@", [request URL]);
	URLConnection *conn = [[URLConnection alloc]init];
	conn.tag =@"GetOrders";
	[conn setDelegate:self];
	[conn initWithRequest:request];
	
	load = [[Loading alloc]init];
	[load showLoading:@"Loading" inView:self.view];
}
- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data
{
	if([tag isEqualToString:@"GetOrders"])
	{
		NSString * json_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		SBJSON *parser = [[SBJSON alloc] init];
		Order *order = [Order sharedOrder];
		[order setOrder:[parser objectWithString:json_str error:nil]];
        [parser release];
        [json_str release];
	}
	[load hideLoading];
	[load release];

}
-(void)loadData
{
    printf("calling loadData\n");
	Order *order = [Order sharedOrder];
	NSDictionary *user_order = [[order currentOrder]objectForKey:@"run"];
	//NSLog(@"user_order %@",user_order);
	
	
	run_array = [[NSMutableArray alloc]init];
	for (NSDictionary *items in user_order)
	{
		[run_array addObject:items];
	}
    
	//NSLog(@"count %i",[run_array count]);
	static NSString *CellIdentifier = @"Cell";	
	cells = [[NSMutableArray alloc] init];
	
	
	//If the device is a ATTENDEE, show the run info
	if([[user_order objectForKey:@"is_runner"] intValue] == 0)
	{
        printf("Its a runner\n");
		TKLabelTextViewCell *cell1 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
		cell1.label.text = @"Runner";
        cell1.userInteractionEnabled = NO;
		cell1.textView.text = [user_order objectForKey:@"user_name"];
		[cells addObject:cell1];
		[cell1 release];
		
		TKLabelTextViewCell *cell2 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
		cell2.label.text = @"Location";
       // cell2.userInteractionEnabled = NO;
		
		cell2.textView.text = [NSString stringWithFormat:@"%@\n%@",[[user_order objectForKey:@"location"]objectForKey:@"name"],[[user_order objectForKey:@"location"]objectForKey:@"address"]];
		[cells addObject:cell2];
		[cell2 release];
		
		TKLabelTextViewCell *cell3 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
		cell3.label.text = @"Time";
		cell3.textView.text = [user_order objectForKey:@"timestamp"];
		
		[cell3 release];
	}
	orders_cells = [[NSMutableArray alloc] init];
	int orders_count = [[user_order objectForKey:@"orders"]count];
	
    //NSLog(@"orders %@",[user_order objectForKey:@"orders"]);
    //NSLog(@"orders_count %i",orders_count);
	if(orders_count >0)
	{
        noOrdersView.hidden = YES;
        [[Tracker sharedTracker]trackPageView:@"/app_ViewCurrentOrdersView_hasOrder"];
		//Save this dictionary into Drink Orders sp we can edit it
		[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"];
		
		for(int i=0;i<orders_count;i++)
		{
			
			NSString *deviceID = [[[user_order objectForKey:@"orders"]objectAtIndex:i]objectForKey:@"deviceid"];
            //NSLog(@"deviceID %@",deviceID);
            //NSLog(@"_UALastDeviceToken  %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"_UALastDeviceToken"]);
			//if(![deviceID isEqualToString: [[NSUserDefaults standardUserDefaults] objectForKey:@"_UALastDeviceToken"]])
			//	break;
			TKLabelTextViewCell *cell1 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
			NSString *name = [[[user_order objectForKey:@"orders"]objectAtIndex:i]objectForKey:@"name"];
			cell1.label.text = [NSString stringWithFormat:@"Order for: %@",name];
			NSMutableString *str = [[NSMutableString alloc]init];
			NSArray *current_drink = [[[user_order objectForKey:@"orders"]objectAtIndex:i]objectForKey:@"drink"];		
            if(current_drink == (id)[NSNull null])
            {
                printf("its null");
                continue;
            }
            
			if([current_drink  isKindOfClass:[NSDictionary class]])
			{
				NSArray *keys = [current_drink allKeys];
				if([keys count]>0)
				{
					for(int j=0;j<[keys count];j++)
					{
						NSString *key = [keys objectAtIndex:j];
						NSString *value = [current_drink objectForKey:key];
                        //Dont show timestamp
                        if([key isEqualToString:@"timestamp"])
                            continue;
						[str appendString:[NSString stringWithFormat:@"%@: %@\n",key,value]];
					}
				}
			}
			else if([current_drink isKindOfClass:[NSArray class]])
			{
				int drinks_count = [current_drink count];
				for(int i=0;i<drinks_count;i++)
				{
					[str appendString:[NSString stringWithFormat:@"\nOrder #%i\n",i+1]];
					
					NSArray *keys = [[current_drink objectAtIndex:i] allKeys];
					for(int j=0;j<[keys count];j++)
					{
						NSString *key = [keys objectAtIndex:j];
						NSString *value = [[current_drink objectAtIndex:i]objectForKey:key];
                        //Dont show timestamp
                        if([key isEqualToString:@"timestamp"])
                            continue;
						[str appendString:[NSString stringWithFormat:@"%@: %@\n",key,value]];
					}
				}
			}
			cell1.textView.text = str;
            NSLog(@"str %@",str);
            [orders_cells addObject:cell1];
			[cell1 release];
		}
	}
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	//[self loadData];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    Order *order = [Order sharedOrder]; 
    
    int orders_count = [[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]count];
    
    if(orders_count ==0)
        noOrdersView.hidden = NO;
    else   
        noOrdersView.hidden = YES;
    
    [self loadData];
    
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
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
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(section ==0)
		return [cells count];
	else if(section ==1)
		return [orders_cells count];
	else {
		return 1;
	}


}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section ==0)
	{
		if(indexPath.row == 1){
			return 120.0;
		}
		return 44.0;
	}
	else
    {
        
        TKLabelTextViewCell *cell = [orders_cells objectAtIndex:[indexPath row]];
        NSString *text =  cell.textView.text;

        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat height = MAX(size.height, 44.0f);
        return height + (CELL_CONTENT_MARGIN * 2);
    }
}




// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if(indexPath.section ==0)
		return [cells objectAtIndex:indexPath.row];
	else
		return [orders_cells objectAtIndex:indexPath.row];
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
	NSLog(@"indexPath.section %i",indexPath.section);
	
	if(indexPath.section ==1)
	{
		Order *order = [Order sharedOrder];
		
		NSString *order_device_id = [[[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:indexPath.row]objectForKey:@"deviceid"];
		NSLog(@"order_device_id %@",order_device_id);
		NSLog(@"Token %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"_UALastDeviceToken"]);
		//Make sure the user device id of the order matches the device id of the current user
		if([[[NSUserDefaults standardUserDefaults] valueForKey:@"_UALastDeviceToken"] isEqualToString:order_device_id])
		{
			EditOrderView *editOrder = [[EditOrderView alloc] initWithNibName:nil bundle:nil];
			NSDictionary *user_order = [[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"];
			//editOrder.order_dict = [user_order objectAtIndex:indexPath.row];
			editOrder.table_index = indexPath.row;
			[self.navigationController pushViewController:editOrder animated:YES];
			[editOrder release];
		}
        else
            [tv deselectRowAtIndexPath:indexPath animated:YES]; 
	}
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
    [super dealloc];
}


@end

