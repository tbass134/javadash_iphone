    //
//  OrdersViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/14/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "OrdersViewController.h"
#import "Utils.h"
#import "Constants.h"
#import "Loading.h"
#import "JSON.h"
#import "Order.h"
#import "URLConnection.h"
#import "DashSummary.h"

#import "EditOrderView.h"
#import "TapkuLibrary.h"
#import "URLConnection.h"
#import "Tracker.h"
#import "DrinkOrders.h"
#import "SavedDrinksList.h"

//Place Order
#import "ItemsViewController.h"


#import "YourOrderTableViewController.h"
#import "NameListViewController.h"
#import "CustomOrderViewController.h"
#import "CoffeeDetailsView.h"


#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation OrdersViewController
//ViewCurrentOrders
@synthesize run_array;

//Place Order View
@synthesize drink_btn,custom_btn,your_order_btn,favorite_btn;
//CoreData
@synthesize fetchedResultsController, managedObjectContext;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

-(void)checkForOrders
{
	//every time we go to this screen, we need to know if an order has been sent,
	//If so, change the Label
    int ts = [[NSDate date] timeIntervalSince1970];
	NSString *userName = [NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"],[[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"]];
    
    NSString *email =[[NSUserDefaults standardUserDefaults]valueForKey:@"EMAIL"];
    BOOL enable_email = [[[NSUserDefaults standardUserDefaults]valueForKey:@"ENABLE_EMAIL"]boolValue];
    
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getorders.php?deviceid=%@&name=%@&email=%@&enable_email=%d&platform=%@&ts=%i",baseDomain,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],[Utils urlencode:userName],email,enable_email,@"IOS",ts]]
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
					
                                                       timeoutInterval:60.0];
#if debug
	NSLog(@"url %@", [request URL]);
#endif
	URLConnection *conn = [[URLConnection alloc]init];
	conn.tag =@"GetOrders";
	[conn setDelegate:self];
	[conn initWithRequest:request];
	
	[load showLoading:@"Loading" inView:self.view];
}

- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data
{
	[load hideLoading];
    if([tag isEqualToString:@"GetOrders"])
    {
        if(!success)
        {
            [Utils showAlert:@"Could not connect to server" withMessage:@"Please try again" inView:self.view];
            return;
        }
        
        //NSLog(@"data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        NSString * json_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        SBJSON *parser = [[SBJSON alloc] init];
        Order *order = [Order sharedOrder];
        [order setOrder:[parser objectWithString:json_str error:nil]];
        [parser release];
        [json_str release];
        if([order currentOrder] == NULL)
        {
            [Utils showAlert:@"Error Loading Data" withMessage:@"Please try again" inView:self.view];
            return;
        }
            
         if(![[[order currentOrder] objectForKey:@"run"]objectForKey:@"id"])
         {
             [Utils showAlert:@"No Orders Available" withMessage:nil inView:self.view];
             return;
         }
        [self gotoScreen];
    }
	
    if([tag isEqualToString:@"submitOrder"])
    {
        [[Tracker sharedTracker]trackPageView:@"/app_ItemsViewController_orderAdded"];        
        [Utils showAlert:@"Order Added" withMessage:nil inView:self.view];
        
        DrinkOrders *drink_orders = [DrinkOrders instance];
        [drink_orders clearArray];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
	}
}
-(void)viewCurrentOrders
{
    if(place_over_view.superview)
        [place_over_view removeFromSuperview];
    [self.view addSubview:current_orders_view];
    [self initViewCurrentOrders];
    
}
-(void)placeOrder
{
    if(current_orders_view.superview)
        [current_orders_view removeFromSuperview];
    [self initPlaceOrder];
}

-(void)gotoScreen
{
	Order *order = [Order sharedOrder];
	NSDictionary *user_order = [order currentOrder];
	if(![[user_order objectForKey:@"run"]objectForKey:@"id"])
	{
		[Utils showAlert:@"No Runs Available" withMessage:nil inView:self.view];
		return;
	}
	if([user_order objectForKey:@"run"] != NULL)
	{		
        [self viewCurrentOrders];
	}
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    noOrdersView.hidden = YES;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"reloadData" object:nil];

     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData:)];
    
    //Event listener to update order when an order has been editied
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrderEdited:) name:@"OrderEdited" object:nil];

	
    load = [[Loading alloc]init];
	//If we havent gotten the data yet, load it
	Order *order = [Order sharedOrder];
	if([order currentOrder] == NULL)
		[self checkForOrders];
	else 
		[self gotoScreen];

    [super viewDidLoad];
}
-(void)reloadData:(id)sender
{
    [self checkForOrders];
}

#pragma mark ViewCurrentOrders
-(void)initViewCurrentOrders
{
    addOrder_btn = [[[UIBarButtonItem alloc]
                   initWithTitle:@"Add to Order" style:UIBarButtonItemStylePlain target:self action:@selector(placeOrder:)]autorelease];
    
	self.navigationItem.rightBarButtonItem = addOrder_btn;
    [self loadOrderData];
    
}
-(void)placeOrder:(id)sender
{
    if(current_orders_view.superview)
        [current_orders_view removeFromSuperview];
    [self.view addSubview:place_over_view];
    [self initPlaceOrder];
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

-(void)loadOrderData
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
    
    //If the order is over, disable Add to Order Button
    NSDateFormatter *newFormatter2 = [[[NSDateFormatter alloc] init] autorelease];
    [newFormatter2 setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *run_date = [newFormatter2 dateFromString:[user_order objectForKey:@"timestamp"]];
    
    //HACK
    NSDate *adjustedDate = [run_date addTimeInterval: (60*60*12)];
    run_date = [adjustedDate retain];
    
    if ([[NSDate date] compare:run_date] == NSOrderedAscending)
    {
        addOrder_btn.enabled = YES;
    }
    else
    {
        addOrder_btn.enabled = NO;
    }

	
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
            [orders_cells addObject:cell1];
			[cell1 release];
		}
	}
    else
        noOrdersView.hidden = NO;
	[current_orders_table reloadData];
    current_orders_table.delegate = self;
    current_orders_table.dataSource = self;
}
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//NSLog(@"indexPath.section %i",indexPath.section);
	
	if(indexPath.section ==1)
	{
		Order *order = [Order sharedOrder];
		
		NSString *order_device_id = [[[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:indexPath.row]objectForKey:@"deviceid"];
        
		//Make sure the user device id of the order matches the device id of the current user
		if([[[NSUserDefaults standardUserDefaults] valueForKey:@"_UALastDeviceToken"] isEqualToString:order_device_id])
		{
            
            NSDictionary *drink_dict = [[[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:indexPath.row]objectForKey:@"drink"];
            
            /*
             "Add Shot of Espresso" = 1;
             Blend = Decaf;
             Size = Medium;
             Sweetener = Sugar;
             beverage = Caramel;
             drink = Latte;
             "drink_type" = Hot;
             timestamp = 1316480874;
             */
            
            
            NSString *companyName = [Utils getCompanyName:[[[[order currentOrder]objectForKey:@"run"] objectForKey:@"location"]objectForKey:@"name"]];
             
             NSDictionary *options_dict = [[NSDictionary alloc]initWithObjectsAndKeys:companyName,@"companyName",[drink_dict objectForKey:@"drink_type"],@"drink_type",[drink_dict objectForKey:@"beverage"],@"beverage",[drink_dict objectForKey:@"drink"],@"drink",nil];
             
            
             CoffeeDetailsView *listView   = [[CoffeeDetailsView alloc]initWithNibName:nil bundle:nil];
             listView.drink = options_dict;
             listView.edit_order_dict = drink_dict;
             [self.navigationController pushViewController:listView animated:YES];
                         
            
		}
        else
            [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
	}
}




#pragma mark Place Order
-(void)initPlaceOrder
{
    [[Tracker sharedTracker]trackPageView:@"/app_ItemsViewController"];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendOrder:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
}
-(void)goBack:(id)sender
{
    self.navigationItem.leftBarButtonItem = nil;
    if(place_over_view.superview)
        [place_over_view removeFromSuperview];
    [self.view addSubview:current_orders_view];
    [self initViewCurrentOrders];
    
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
	}
    else
        [Utils showAlert:@"No Orders Added"withMessage:@"Please add a order" inView:self.view];
    
	//NSLog(@"order id %@",[[[order currentOrder]objectForKey:@"run"]objectForKey:@"id"]);
    
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
-(void)viewDidAppear:(BOOL)animated
{
    if(current_orders_view.superview)
    {
        Order *order = [Order sharedOrder]; 
        
        int orders_count = [[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]count];
        
        if(orders_count ==0)
            noOrdersView.hidden = NO;
        else   
            noOrdersView.hidden = YES;
        
        [self loadOrderData];
    }
    
    CoffeeRunSampleAppDelegate *appDelegate  = (CoffeeRunSampleAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate showAdView];
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [load release];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:@"reloadData"];
    [super dealloc];
}


@end
