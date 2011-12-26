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
#import "JSON.h"
#import "Order.h"
#import "URLConnection.h"
#import "DashSummary.h"

#import "EditOrderView.h"
#import "TapkuLibrary.h"
#import "URLConnection.h"
#import "DrinkOrders.h"
#import "SavedDrinksList.h"

//Place Order
#import "ItemsViewController.h"


#import "YourOrderTableViewController.h"
#import "NameListViewController.h"
#import "CustomOrderViewController.h"
#import "CoffeeDetailsView.h"
#import "MutipleOrdersTableView.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CURRENT_TAB_INDEX 1

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
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.navigationController.view addSubview:HUD];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
	
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(GetOrders) onTarget:self withObject:nil animated:YES];
}
-(void)GetOrders
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //every time we go to this screen, we need to know if an order has been sent,
	//If so, change the Label
    int ts = [[NSDate date] timeIntervalSince1970];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getorders.php?deviceid=%@&ts=%i",baseDomain,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],ts]]
														   cachePolicy:NSURLCacheStorageNotAllowed
													   timeoutInterval:60.0];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    if (response == nil) {
        if (requestError != nil) {
            if(self.navigationController.tabBarController.selectedIndex ==CURRENT_TAB_INDEX)
                [Utils showAlert:@"Could not connect to server" withMessage:@"Please try again" inView:self.view];
            //[self showNoOrdersView:YES];
        }
    }
    else
    {
        NSString * json_str = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        SBJSON *parser = [[SBJSON alloc] init];
        Order *order = [Order sharedOrder];
        [order setOrder:[parser objectWithString:json_str error:nil]];
        [parser release];
        [json_str release];

        [self performSelectorOnMainThread:@selector(updateOrders)
                               withObject:nil
                            waitUntilDone:NO];
    } 
    [pool release];
}
-(void)updateOrders
{
    Order *order = [Order sharedOrder];
    if(![[[order currentOrder] objectForKey:@"run"]objectForKey:@"id"])
    {
        printf("NO Orders");
        current_orders_table.hidden = YES;
        //[self showNoOrdersView:YES];
        return;
    }
    current_orders_table.hidden = NO;
    [self gotoScreen];

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
        printf("No Runs Available");
        //[self showNoOrdersView:YES];
		return;
	}
    DrinkOrders *drink_orders = [DrinkOrders instance];
    if([[drink_orders getArray]count]>0)
    {
         //[self viewCurrentOrders];
        [self initPlaceOrder];
    }
    else
        [self viewCurrentOrders];
    
    /* //Orginal
	if([user_order objectForKey:@"run"] != NULL)
	{		
        //[self showNoOrdersView:NO];
        [self viewCurrentOrders];
	}
     */
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    send_order = [[UIBarButtonItem alloc]initWithTitle:@"Send Order" style:UIBarButtonItemStyleDone target:self action:@selector(sendOrder:)];
    
    addOrder_btn = [[UIBarButtonItem alloc]
                     initWithTitle:@"Add to Order" style:UIBarButtonItemStylePlain target:self action:@selector(placeOrder:)];
    reload = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData:)];
    
    goback = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    
    self.navigationItem.rightBarButtonItem = reload;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"reloadData" object:nil];

    
    
    //Event listener to update order when an order has been editied
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrderEdited:) name:@"OrderEdited" object:nil];

   
    [super viewDidLoad];
}
-(void)reloadData:(id)sender
{
    [self checkForOrders];
}

#pragma mark ViewCurrentOrders
-(void)initViewCurrentOrders
{
	self.navigationItem.rightBarButtonItem = addOrder_btn;
    [self loadOrderData];
}
-(void)edit:(id)sender
{
    if(!isEditing)
    {
        [current_orders_table setEditing:YES  animated: YES];
        isEditing = YES;
    }
    else
    {
        [current_orders_table setEditing:NO  animated: YES];
        isEditing = NO;
    }
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
	printf("Order has been edited");
	
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.navigationController.view addSubview:HUD];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
	
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(GetOrders) onTarget:self withObject:nil animated:YES];}

-(void)loadOrderData
{
    printf("calling loadData\n");
    //Clear drink orders array
    DrinkOrders *drink_orders = [DrinkOrders instance];
    [drink_orders clearArray];

    
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
        order_ended = NO;
        addOrder_btn.enabled = YES;
    }
    else
    {
        order_ended = YES;
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
    NSLog(@"orders_count %i",orders_count);
	
	if(orders_count >0)
	{
        current_orders_table.hidden = NO;
        //[self showNoOrdersView:NO];

        if([[user_order objectForKey:@"is_runner"] intValue] == 0)
        {
            edit = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
            self.navigationItem.leftBarButtonItem = edit;
		}
        //Save this dictionary into Drink Orders sp we can edit it
		[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"];
		
		for(int i=0;i<orders_count;i++)
		{
			
			NSString *deviceID = [[[user_order objectForKey:@"orders"]objectAtIndex:i]objectForKey:@"deviceid"];
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
    {
        //[self showNoOrdersView:YES];
        current_orders_table.hidden = NO;
    }
    
	[current_orders_table reloadData];
    current_orders_table.delegate = self;
    current_orders_table.dataSource = self;
}
#pragma mark Show No Orders View
-(void)showNoOrdersView:(BOOL)show
{
    BOOL isShowing = [self.view.subviews containsObject:noOrdersView];
    NSLog(@"isShowing %d",isShowing);
    
    if(isShowing)
        [noOrdersView removeFromSuperview];
    
    if(show)
        [self.view addSubview:noOrdersView];
    else
        [noOrdersView removeFromSuperview];
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
    
	NSLog(@"indexPath.section %i",indexPath.section);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(order_ended)
    {
        [Utils showAlert:@"Order Has Ended" withMessage:@"You cannot edit an order that has been completed" inView:self.view];
        return;
    }
	
	if(indexPath.section ==1)
	{
		Order *order = [Order sharedOrder];
		
		NSString *order_device_id = [[[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:indexPath.row]objectForKey:@"deviceid"];
        
		//Make sure the user device id of the order matches the device id of the current user
		if([[[NSUserDefaults standardUserDefaults] valueForKey:@"_UALastDeviceToken"] isEqualToString:order_device_id])
		{
            
            NSDictionary *drink_dict = [[[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:indexPath.row]objectForKey:@"drink"];
            NSLog(@"drink_dict %@",drink_dict);
            
            NSLog(@"count %i",[drink_dict count]);
            NSLog(@"NSArray %d",[drink_dict isKindOfClass:[NSArray class]]);
            //NSLog(@"Custom Ordder %@",[drink_dict objectForKey:@"CustomOrder"]);
            
            if([drink_dict isKindOfClass:[NSDictionary class]])
            {
                if([drink_dict objectForKey:@"CustomOrder"] != nil)
                {
                    modalViewDidAppear = YES;
                    CustomOrderViewController *customOrder   = [[CustomOrderViewController alloc]initWithNibName:@"CustomOrderViewController" bundle:nil];
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:customOrder];
                    customOrder.edit_order_dict = drink_dict;
                    customOrder.selected_index = indexPath.row;
                    //[self.navigationController presentModalViewController:nav animated:YES];
                    [self.navigationController pushViewController:customOrder animated:YES];
                    [customOrder release];
                    [nav release];
                    return;
                     
                }
            }
        
                NSLog(@"count %i",[drink_dict count]);
                NSLog(@"NSArray %d",[drink_dict isKindOfClass:[NSArray class]]);
                
                
               if([drink_dict count] >1 && [drink_dict isKindOfClass:[NSArray class]])
               {
                    //Push the new mutiple Order Table View
                    MutipleOrdersTableView *mutiView   = [[MutipleOrdersTableView alloc]initWithNibName:@"MutipleOrdersTableView" bundle:nil];
                    mutiView.selected_index = indexPath.row;
                    [self.navigationController pushViewController:mutiView animated:YES];
                   
               }
               else
               {     
                   
                NSString *companyName = [Utils getCompanyName:[[[[order currentOrder]objectForKey:@"run"] objectForKey:@"location"]objectForKey:@"name"]];
                 
                 NSDictionary *options_dict = [[NSDictionary alloc]initWithObjectsAndKeys:companyName,@"companyName",[drink_dict objectForKey:@"drink_type"],@"drink_type",[drink_dict objectForKey:@"beverage"],@"beverage",[drink_dict objectForKey:@"drink"],@"drink",nil];
                 
                
                 CoffeeDetailsView *listView   = [[CoffeeDetailsView alloc]initWithNibName:nil bundle:nil];
                 listView.drink = options_dict;
                 listView.edit_order_dict = drink_dict;
                   listView.selected_index = indexPath.row;
                 [self.navigationController pushViewController:listView animated:YES];
                    
               }
            }
             
		}           
}
- (void) tableView: (UITableView *) tableView
commitEditingStyle: (UITableViewCellEditingStyle) editingStyle
 forRowAtIndexPath: (NSIndexPath *) indexPath {
    
    if(indexPath.section ==1)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
        //[_cues removeObjectAtIndex: indexPath.row];  // manipulate your data structure.
        
        if(order_ended)
            return;
                
        Order *order = [Order sharedOrder];

        NSDictionary *current_order = [[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:indexPath.row];
        //NSLog(@"current_order %@",current_order);
        [[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"] removeObject:current_order];

        //[current_orders_table deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
        //             withRowAnimation: UITableViewRowAnimationFade];

        //Call script to remove order
        [self loadOrderData];	

        }
    
    }
} // commitEditingStyle


#pragma mark Place Order
-(void)initPlaceOrder
{
	self.navigationItem.rightBarButtonItem = send_order;
    self.navigationItem.leftBarButtonItem = goback;
}
-(void)goBack:(id)sender
{
    modalViewDidAppear = NO;
    self.navigationItem.leftBarButtonItem = nil;
    if(place_over_view.superview)
        [place_over_view removeFromSuperview];
    [self.view addSubview:current_orders_view];
    
    [self initViewCurrentOrders];
    
}
-(void)sendOrder:(id)sender
{
    modalViewDidAppear = YES;
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.navigationController.view addSubview:HUD];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
	
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(sendOrders) onTarget:self withObject:nil animated:YES];
	//NSLog(@"order id %@",[[[order currentOrder]objectForKey:@"run"]objectForKey:@"id"]);
}
-(void)sendOrders
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    printf("send Order");
	Order *order = [Order sharedOrder];
	//This is the data that got returned from the server when we first went to view the run.. Called  getOrder.php from CurrentRunViewController
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/placeorder.php",baseDomain]]
														   cachePolicy:NSURLCacheStorageNotAllowed
													   timeoutInterval:60.0];
	
	[request setHTTPMethod:@"POST"];
	
	SBJSON *parser = [[SBJSON alloc] init];
	NSMutableString* theString = [NSMutableString string];
	
	DrinkOrders *drink_orders = [DrinkOrders instance];
	NSMutableArray *drink_orders_array  = [drink_orders getArray];
    NSLog(@"drink_orders_array %@",drink_orders_array);
    
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
		NSError *requestError;
        NSURLResponse *urlResponse = nil;
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
        if (response == nil) {
            if (requestError != nil) {
                
                [Utils showAlert:@"Could not connect to server" withMessage:@"Please try again" inView:self.view];
            }
        }
        else
        {
          
            [self performSelectorOnMainThread:@selector(orderAdded)
                                   withObject:nil
                                waitUntilDone:NO];
        } 

	}
    else
    {
        printf("No Orders Added");
    }
    [pool release];
}
-(void)orderAdded
{
    if(self.navigationController.tabBarController.selectedIndex ==CURRENT_TAB_INDEX)
        [Utils showAlert:@"Order Added" withMessage:nil inView:self.view];
    
    self.navigationItem.leftBarButtonItem = nil;
    DrinkOrders *drink_orders = [DrinkOrders instance];
    [drink_orders clearArray];
    
    NSMutableArray *drink_orders_array  = [drink_orders getArray];
    NSLog(@"drink_orders_array %@",drink_orders_array);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
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
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}
-(IBAction)showDrinkList
{
    modalViewDidAppear = YES;
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
    modalViewDidAppear = YES;
	CustomOrderViewController *customOrder   = [[CustomOrderViewController alloc]initWithNibName:@"CustomOrderViewController" bundle:nil];
	[self.navigationController pushViewController:customOrder animated:YES];
	[customOrder release];
}
-(IBAction)showYourOrderList
{
    modalViewDidAppear = YES;
	YourOrderTableViewController *showOrder   = [[YourOrderTableViewController alloc]initWithNibName:nil bundle:nil];
	showOrder.type = NULL;
	[self.navigationController pushViewController:showOrder animated:YES];
	[showOrder release];
}
-(IBAction)showFavoritesList
{
    modalViewDidAppear = YES;
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
    if(!modalViewDidAppear)
    {
        //If we havent gotten the data yet, load it
        Order *order = [Order sharedOrder];
        if([order currentOrder] == NULL)
            [self checkForOrders];
        else 
            [self gotoScreen];
    }

    modalViewDidAppear = NO;
   /* 
    if(current_orders_view.superview)
    {
        Order *order = [Order sharedOrder]; 
        
        int orders_count = [[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]count];
        
        if(orders_count >0)
            noOrdersView.hidden = YES;
        
        [self loadOrderData];
    }
    */
    
    CoffeeRunSampleAppDelegate *appDelegate  = (CoffeeRunSampleAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate showAdView];
}
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
	[[NSNotificationCenter defaultCenter] removeObserver:@"reloadData"];
    [super dealloc];
}


@end
