    //
//  OrdersViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/14/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "OrdersViewController.h"
#import "Utils.h"
#import "JSON.h"
#import "Order.h"
#import "DashSummary.h"

#import "EditOrderView.h"
#import "TapkuLibrary.h"
#import "DrinkOrders.h"
#import "SavedDrinksList.h"
#import "DataService.h"




#import "YourOrderTableViewController.h"
#import "NameListViewController.h"
#import "CustomOrderViewController.h"
#import "CoffeeDetailsView.h"
#import "MutipleOrdersTableView.h"
#import "FlurryAnalytics.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CURRENT_TAB_INDEX 1

#define DEBUG 1

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
    /*
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.navigationController.view addSubview:HUD];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
	[HUD show:YES];
    */
    [self getOrders];
}
-(void)getOrders
{
    //[HUD hide:YES];
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"] == NULL)
        [Utils createUniqueDeviceID];
    
    //BOOL dataLoaded = [[DataService sharedDataService]getOrders];
    //if(dataLoaded)
    //{
        Order *order = [Order sharedOrder];
        if(![[[order currentOrder] objectForKey:@"run"]objectForKey:@"id"])
        {
            
            current_orders_table.hidden = YES;
            if(self.navigationItem.rightBarButtonItem == addOrder_btn)
                [self showNoOrdersView:YES withTitle:@"No Orders" andMessage:@"Click \"Add to Order\" to add an order"];
            else
                [self showNoOrdersView:YES withTitle:@"No Orders" andMessage:@""];
            return;
        }
        current_orders_table.hidden = NO;
        [self gotoScreen];

    /*}
    else
    {
        [self showNoOrdersView:YES withTitle:@"Could not connect to server" andMessage:nil];
    }*/
    
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
        [self showNoOrdersView:YES withTitle:@"No Runs Available" andMessage:nil];
        addOrder_btn.enabled = NO;
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
    self.navigationItem.leftBarButtonItem = nil;
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
    [self showNoOrdersView:NO withTitle:nil andMessage:nil];
    if(current_orders_view.superview)
        [current_orders_view removeFromSuperview];
    [self.view addSubview:place_over_view];
    [self initPlaceOrder];
}
-(void)OrderEdited:(id)sender
{
	
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.navigationController.view addSubview:HUD];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
	[HUD show:YES];
    [self getOrders];
}

-(void)loadOrderData
{
    //Clear drink orders array
    DrinkOrders *drink_orders = [DrinkOrders instance];
    [drink_orders clearArray];

    
    if(orders_cells != NULL)
    {
        [orders_cells removeAllObjects];
        orders_cells = nil;
        [current_orders_table reloadData];
    }
    
	NSDictionary *user_order = [[[[Order sharedOrder] currentOrder]objectForKey:@"run"]retain];
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
    NSDateFormatter *newFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [newFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [newFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDate *runDate = [newFormatter dateFromString:[user_order objectForKey:@"timestamp"]];
    
    if ([[NSDate date] compare:runDate] == NSOrderedAscending)
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
		TKLabelTextViewCell *cell1 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
        
        UIView *v = [[[UIView alloc] init] autorelease];
        v.backgroundColor = [UIColor colorWithRed:108.0f/255.0f green:58.0f/255.0f blue:23.0f/255.0f alpha:1];
        cell1.selectedBackgroundView = v;
		cell1.label.text = @"Runner";
        cell1.userInteractionEnabled = NO;
		cell1.textView.text = [user_order objectForKey:@"user_name"];
		[cells addObject:cell1];
		[cell1 release];
		
		TKLabelTextViewCell *cell2 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
        cell2.selectedBackgroundView = v;
		cell2.label.text = @"Location";
        // cell2.userInteractionEnabled = NO;
		
		cell2.textView.text = [NSString stringWithFormat:@"%@\n%@",[[user_order objectForKey:@"location"]objectForKey:@"name"],[[user_order objectForKey:@"location"]objectForKey:@"address"]];
		[cells addObject:cell2];
		[cell2 release];
		
		TKLabelTextViewCell *cell3 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
        cell3.selectedBackgroundView = v;
		cell3.label.text = @"Time";
		cell3.textView.text = [user_order objectForKey:@"timestamp"];
		
		[cell3 release];
	}
	orders_cells = [[NSMutableArray alloc] init];
    if([user_order objectForKey:@"orders"] == (id)[NSNull null])
    {
        printf("No Orders");
        [self showNoOrdersView:YES withTitle:@"No Orders" andMessage:@"Click \"Add to Order\" to add an order"];
        current_orders_table.hidden = NO;
        return;
        
    }
	int orders_count = [[user_order objectForKey:@"orders"]count];
    //NSLog(@"orders_count %i",orders_count);
	
	if(orders_count >0)
	{
        current_orders_table.hidden = NO;
        [self showNoOrdersView:NO withTitle:nil andMessage:nil];

        /*
        if([[user_order objectForKey:@"is_runner"] intValue] == 0)
        {
            edit = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
            self.navigationItem.leftBarButtonItem = edit;
		}
         */
        
        //Save this dictionary into Drink Orders sp we can edit it
		[[[[Order sharedOrder] currentOrder]objectForKey:@"run"]objectForKey:@"orders"];
		
		for(int i=0;i<orders_count;i++)
		{
			
			//NSString *deviceID = [[[user_order objectForKey:@"orders"]objectAtIndex:i]objectForKey:@"deviceid"];
			TKLabelTextViewCell *cell1 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
            
            UIView *v = [[[UIView alloc] init] autorelease];
            v.backgroundColor = [UIColor colorWithRed:108.0f/255.0f green:58.0f/255.0f blue:23.0f/255.0f alpha:1];
            cell1.selectedBackgroundView = v;
            
			NSString *name = [[[user_order objectForKey:@"orders"]objectAtIndex:i]objectForKey:@"name"];
			cell1.label.text = [NSString stringWithFormat:@"Order for: %@",name];
			NSMutableString *str = [[NSMutableString alloc]init];
			NSArray *current_drink = [[[user_order objectForKey:@"orders"]objectAtIndex:i]objectForKey:@"drink"];		
            if(current_drink == (id)[NSNull null])
            {
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
        current_orders_table.hidden = NO;
        [self showNoOrdersView:YES withTitle:@"No Orders" andMessage:@"Click \"Add to Order\" to add an order"];
    }
    
	[current_orders_table reloadData];
    current_orders_table.delegate = self;
    current_orders_table.dataSource = self;
}
#pragma mark Show No Orders View
-(void)showNoOrdersView:(BOOL)show withTitle:(NSString *)title andMessage:(NSString *)message;
{
    //if(!current_orders_view.superview)
    //    return;
    
    BOOL isShowing = [self.view.subviews containsObject:noOrdersView];
    //NSLog(@"isShowing %d",isShowing);
    
    if(isShowing)
        [noOrdersView removeFromSuperview];
    
    if(show)
    {
        [self.view addSubview:noOrdersView];
        NoOrdersTitle.text = title;
        NoOrdersMessage.text = message;
    }
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
        UIView *v = [[[UIView alloc] init] autorelease];
        v.backgroundColor = [UIColor colorWithRed:108.0f/255.0f green:58.0f/255.0f blue:23.0f/255.0f alpha:1];
        cell.selectedBackgroundView = v;

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
            //NSLog(@"drink_dict %@",drink_dict);
            
            //NSLog(@"count %i",[drink_dict count]);
            //NSLog(@"NSArray %d",[drink_dict isKindOfClass:[NSArray class]]);
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
        
                //NSLog(@"count %i",[drink_dict count]);
                //NSLog(@"NSArray %d",[drink_dict isKindOfClass:[NSArray class]]);
                
                
               if([drink_dict count] >1 && [drink_dict isKindOfClass:[NSArray class]])
               {
                   //Disabled for now
                   /*
                    //Push the new mutiple Order Table View
                    MutipleOrdersTableView *mutiView   = [[MutipleOrdersTableView alloc]initWithNibName:@"MutipleOrdersTableView" bundle:nil];
                    mutiView.selected_index = indexPath.row;
                    [self.navigationController pushViewController:mutiView animated:YES];
                   */
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
        
        if(order_ended)
            return;
                
        Order *order = [Order sharedOrder];
        NSDictionary *current_order = [[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:indexPath.row];
        [self removeOrder:current_order];
        }
    
    }
}


#pragma mark Place Order
-(void)initPlaceOrder
{
	self.navigationItem.rightBarButtonItem = send_order;
    send_order.enabled = NO;
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
-(void)removeOrder:(NSDictionary *)order
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    [self setremoveOrder:order];
    //[HUD showWhileExecuting:@selector(setremoveOrder:) onTarget:self withObject:order animated:YES];
}

-(void)setremoveOrder:(NSDictionary *)order
{
    [HUD hide:YES];
    BOOL removeOrder = [[DataService sharedDataService]deleteOrder:[order objectForKey:@"order_id"]];
    if(removeOrder)
    {
        [[[[[Order sharedOrder] currentOrder]objectForKey:@"run"]objectForKey:@"orders"] removeObject:order];
        [current_orders_table reloadData];
        //[self checkForOrders];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];

    }
    
   
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
        if(orders_cells != NULL)
        {
            [orders_cells removeAllObjects];
            orders_cells = nil;
            [current_orders_table reloadData];
        }
        
        //If we havent gotten the data yet, load it
        Order *order = [Order sharedOrder];
        if([order currentOrder] == NULL)
            [self checkForOrders];
        else 
            [self gotoScreen];
    }
    
    
    if(self.navigationItem.rightBarButtonItem == send_order)
    {
        if([[[DrinkOrders instance]getArray]count]>0)
        {
            send_order.enabled = YES;
        }
        else
        {
            send_order.enabled = NO;
        }
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
/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemsoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}
 */

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
