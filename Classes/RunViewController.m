    //
//  RunViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/9/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "RunViewController.h"


#import "Utils.h"
#import "Constants.h"
#import "JSON.h"
#import "Order.h"
#import "URLConnection.h"
#import "DashSummary.h"

#import "Order.h"
#import "DrinkOrders.h"
#import "AsyncImageView2.h"
#import "TapkuLibrary.h"

#import "Constants.h"
#import "TapkuLibrary.h"

#import "MapViewController.h"
#import "SelectTimeView.h"
#import "FriendsList.h"
#import "CoffeeRunSampleAppDelegate.h"
#import "FlurryAnalytics.h"
#import "UIImageView+WebCache.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

#define LOCATION_TEXT	@"Current Location"
#define TIME_TEXT		@"Run Time"
#define PEOPLE_TEXT		@"Attendees"

#define LOCATION_TAG 1
#define TIME_TAG 2
#define PEOPLE_TAG 3

#define DEBUG 1


@implementation RunViewController
//CoreData
@synthesize fetchedResultsController, managedObjectContext;
//View Run
@synthesize yelp_img,run_info_txt,run_time_txt,table_view;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

-(void)reloadData:(id)sender
{
	[self checkForOrders];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded    
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}
#pragma mark checkForOrders
-(void)checkForOrders{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.navigationController.view addSubview:HUD];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
	
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(GetOrders) onTarget:self withObject:nil animated:YES];
}
-(void)GetOrders{
    
    //every time we go to this screen, we need to know if an order has been sent,
	//If so, change the Label
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int ts = [[NSDate date] timeIntervalSince1970];
    
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getorders.php?deviceid=%@&ts=%i",baseDomain,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],ts]]
														   cachePolicy:NSURLCacheStorageNotAllowed
													   timeoutInterval:60.0];

    #ifdef DEBUG
    NSLog(@"request %@",[request URL]);
    #endif
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
        [[Order sharedOrder]clearOrder];
        //if we get a vaild order than instert your drink and send that to the server
        NSString * json_str = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        #ifdef DEBUG
        NSLog(@"json_str %@",json_str);
        #endif
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
-(void)updateOrders{
    if(![self isRunDataFilledOut])
        startRunBtn.enabled = NO;
    else
        startRunBtn.enabled = YES;
    
    Order *order = [Order sharedOrder];
    if([order currentOrder] == NULL)
    {
        [Utils showAlert:@"Error Loading Data" withMessage:@"Please try again" inView:self.view];
        return;
    }
    if([[order currentOrder] objectForKey:@"run"]!= (id)[NSNull null])
    {
        if(![[[order currentOrder] objectForKey:@"run"]objectForKey:@"id"])
        {
            //[Utils showAlert:@"No Orders Available" withMessage:nil inView:self.view];
            //make sure the other view is not showing
            if(view_run_view.superview)
                [view_run_view removeFromSuperview];
            
            
            [self.view addSubview:start_run_view];
            [self startRun];
            
            //if(self.adView != nil)
            //   [self.view bringSubviewToFront:self.adView];
            return;
        }
        printf("calling gotoScreen");
        [self gotoScreen];
    }

}
#pragma mark -
-(void)startRun
{
    printf("startRun");
    //make sure the other view is not showing
    if(view_run_view.superview)
        [view_run_view removeFromSuperview];
    [self.view addSubview:start_run_view];
    [self initStartRun];
    
	
}
-(void)viewRun
{
    //make sure the other view is not showing
    if(start_run_view.superview)
        [start_run_view removeFromSuperview];
    [self.view addSubview:view_run_view];
    [self initShowRun];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"reloadData" object:nil];
        
    reloadDataBtn =  [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData:)];

    showOptionsBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showOptions:)];
    
    startRunBtn =[[UIBarButtonItem alloc]initWithTitle:@"Start Run" style:UIBarButtonItemStyleDone target:self action:@selector(completeSummary:)];
    
    self.navigationItem.rightBarButtonItem = reloadDataBtn;
    
    if(![self isRunDataFilledOut])
        startRunBtn.enabled = NO;
    else
        startRunBtn.enabled = YES;
    

	Order *order = [Order sharedOrder];
	if([order currentOrder] == NULL)
		[self checkForOrders];
	else
		[self gotoScreen];
	 
    [super viewDidLoad];
}


-(void)gotoScreen
{
	Order *order = [Order sharedOrder];
	NSDictionary *user_order = [[order currentOrder]retain];
	
	[Utils printDict:user_order];
	if([user_order objectForKey:@"run"] != NULL)
	{
		if([[[order currentOrder] objectForKey:@"run"]objectForKey:@"id"])
		{
            printf("VIEW RUN");
            [self viewRun];
		}
		else
		{
			//if there is a run already started, populate the Orders class with the info			
			printf("START RUN");
			[self startRun];
			
		}
	}
    [user_order release];
    
}

#pragma mark View Run
-(void)initShowRun
{

    self.navigationItem.rightBarButtonItem = showOptionsBtn;
    Order *order = [Order sharedOrder];
	NSDictionary *user_order = [[order currentOrder]objectForKey:@"run"];
    
	if([[user_order objectForKey:@"location"] objectForKey:@"image"] != NULL || ![[[user_order objectForKey:@"location"] objectForKey:@"image"] isEqualToString:@""])
    {        
        [yelp_img setImageWithURL:[[user_order objectForKey:@"location"] objectForKey:@"image"] placeholderImage:[UIImage imageNamed:@"no-image.gif"]];
    }
    
    
    
	run_info_txt.text = [NSString stringWithFormat:@"%@\n%@",[[user_order objectForKey:@"location"]objectForKey:@"name"],[[user_order objectForKey:@"location"]objectForKey:@"address"]];
    
    
    
    NSDateFormatter *newFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [newFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [newFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDate *runDate = [newFormatter dateFromString:[user_order objectForKey:@"timestamp"]];
    
    
    
    
    //NSLog(@"runDate %@",[runDate addTimeInterval: -(60*60*5)]); //this works but cant use it since it hardcodes the tz offset
    
    
    NSLog(@"runDate %@",runDate);
    NSLog(@"current date %@ ",[NSDate date]);
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    int unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:[NSDate date] toDate:runDate options:0];
    run_time_txt.text = [NSString stringWithFormat:@"Days:%02d Hours:%02d Mins:%02d Seconds:%02d", components.day, components.hour, components.minute, components.second ];
    
    if(components.day<=0 && components.hour <=0 && components.minute <=0 && components.second <=0)
    {
        run_time_txt.text = @"Order Ended";
        orderEnded = YES;
        [self stopTimer];
    }

    
    
    
    //run_date = [[newFormatter2 dateFromString:[user_order objectForKey:@"timestamp"]]retain];
    
    //HACK
    //NSDate *adjustedDate = [run_date addTimeInterval: (60*60*12)];
    //run_date = [adjustedDate retain];
       
    return;
    
    orderEnded = NO;
    if ([[NSDate date] compare:run_date] == NSOrderedAscending)
        [self startTimer];
    else
    {
        orderEnded = YES;
        run_time_txt.text = @"Order Ended";
    }
    
    if(orders_cells != NULL)
    {
        [orders_cells removeAllObjects];
        orders_cells = nil;
    }
    
    //if(!orderEnded)
      //  self.navigationItem.rightBarButtonItem = showOptionsBtn;
    
	//Only show the orders if this device is the runner
	if([[user_order objectForKey:@"is_runner"] intValue] == 1)
	{
        
        //showOptionsBtn.enabled = YES;
		orders_cells = [[NSMutableArray alloc] init];
        
		if([user_order objectForKey:@"orders"] == (id)[NSNull null])
        {
            printf("No Orders");
            return;
            
        }
        
		int orders_count = [[user_order objectForKey:@"orders"]count];
		static NSString *CellIdentifier = @"Cell";	
		if(orders_count >0)
		{
            
			//Save this dictionary into Drink Orders sp we can edit it
			[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"];
			
			for(int i=0;i<orders_count;i++)
			{
                
                if ([[[user_order objectForKey:@"orders"]objectAtIndex:i]objectForKey:@"drink"] == (id)[NSNull null])
                {
                    continue;
                } 
				TKLabelTextViewCell *cell1 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
				NSString *name = [[[user_order objectForKey:@"orders"]objectAtIndex:i]objectForKey:@"name"];
				cell1.label.text = [NSString stringWithFormat:@"Order for: %@",name];
				
				NSMutableString *str = [[NSMutableString alloc]init];
				NSArray *current_drink = [[[user_order objectForKey:@"orders"]objectAtIndex:i]objectForKey:@"drink"];		
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
	}
   // els 
    //    showOptionsBtn.enabled = NO;
    view_run_table.delegate = self;
    view_run_table.dataSource = self;
    [view_run_table reloadData];
}

// snippet from BDDateTransformer.m //
- (id)transformedValue:(NSDate *)date
{
    // Initialize the formatter.
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    // Initialize the calendar and flags.
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create reference date for supplied date.
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *suppliedDate = [calendar dateFromComponents:comps];
    
    // Iterate through the eight days (tomorrow, today, and the last six).
    int i;
    for (i = -1; i < 7; i++)
    {
        // Initialize reference date.
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        [comps setDay:[comps day] - i];
        NSDate *referenceDate = [calendar dateFromComponents:comps];
        // Get week day (starts at 1).
        int weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
        
        if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == -1)
        {
            // Tomorrow
            return [NSString stringWithString:@"Tomorrow"];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0)
        {
            // Today's time (a la iPhone Mail)
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            return [formatter stringFromDate:date];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1)
        {
            // Today
            return [NSString stringWithString:@"Yesterday"];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame)
        {
            // Day of the week
            NSString *day = [[formatter weekdaySymbols] objectAtIndex:weekday];
            return day;
        }
    }
    
    // It's not in those eight days.
    NSString *defaultDate = [formatter stringFromDate:date];
    return defaultDate;
}
-(void)startTimer {
	
	if (run_countdown_timer) {
		[run_countdown_timer invalidate];
		run_countdown_timer=nil;
	}
    
	run_countdown_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];	
}

-(void)stopTimer {
	
    if (run_countdown_timer){ [run_countdown_timer invalidate];
		run_countdown_timer=nil;}
}

- (void)updateTimer:(NSTimer *)myTimer{
    if(run_date != NULL)
    {

        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        int unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *components = [gregorian components:unitFlags fromDate:[NSDate date] toDate:run_date options:0];
        run_time_txt.text = [NSString stringWithFormat:@"Days:%02d Hours:%02d Mins:%02d Seconds:%02d", components.day, components.hour, components.minute, components.second ];
        
        if(components.day<=0 && components.hour <=0 && components.minute <=0 && components.second <=0)
        {
            run_time_txt.text = @"Order Ended";
            orderEnded = YES;
            [self stopTimer];
        }
    }
    
}
-(void)showOptions:(id)sender{
    
    NSDictionary *user_order = [[[Order sharedOrder] currentOrder]objectForKey:@"run"];
    NSString *title;
    
    if([[user_order objectForKey:@"is_runner"] intValue] == 1)
        title = @"Complete Dash";
    else
        title = @"Leave Dash";
    
	UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:title,nil];
	[sheet showFromTabBar:self.tabBarController.tabBar];
	[sheet release];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	// the user clicked one of the OK/Cancel buttons
    NSDictionary *user_order = [[[Order sharedOrder] currentOrder]objectForKey:@"run"];
    
   	if (buttonIndex == 0)
	{
         if([[user_order objectForKey:@"is_runner"] intValue] == 1)
         {
             HUD = [[MBProgressHUD alloc] initWithView:self.view];
             [self.navigationController.view addSubview:HUD];
             HUD.delegate = self;
             [HUD showWhileExecuting:@selector(completeRun) onTarget:self withObject:nil animated:YES];  
         }
        else
        {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.navigationController.view addSubview:HUD];
            HUD.delegate = self;
            [HUD showWhileExecuting:@selector(leaveRun) onTarget:self withObject:nil animated:YES];
        }
    }
}
#pragma mark CompleteRun
-(void)completeRun{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Order *order = [Order sharedOrder];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/completerun.php?deviceid=%@&run_id=%@",
                                                                                             baseDomain,
                                                                                             [[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"]
                                                                                             ,[[[order currentOrder] objectForKey:@"run"]objectForKey:@"id"]]]
                                                           cachePolicy:NSURLCacheStorageNotAllowed
                                                       timeoutInterval:60.0];
    
    
    #ifdef DEBUG
    NSLog(@"request %@",[request URL]);
    #endif
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
        //if we get a vaild order than instert your drink and send that to the server
        NSString * json_str = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        #ifdef DEBUG
        NSLog(@"json_str %@",json_str);
        #endif
        SBJSON *parser = [[SBJSON alloc] init];
        Order *order = [Order sharedOrder];
        [order setOrder:[parser objectWithString:json_str error:nil]];
        [parser release];
        [json_str release];
        [self performSelectorOnMainThread:@selector(updatecompleteRun)
                               withObject:nil
                            waitUntilDone:NO];
    } 

    [pool release];    
}
-(void)updatecompleteRun{
    [Utils showAlert:nil withMessage:@"Order Completed" inView:self.view];
    //[self checkForOrders];
    
    //Clear the drink orders array
    DrinkOrders *drink_orders = [DrinkOrders instance];
    [drink_orders clearArray];
    
    [self checkForOrders];
}
#pragma mark -
#pragma mark  
-(void)leaveRun{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Order *order = [Order sharedOrder];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/leaverun.php?deviceid=%@&run_id=%@",
                                                                                             baseDomain,
                                                                                             [[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"]
                                                                                             ,[[[order currentOrder] objectForKey:@"run"]objectForKey:@"id"]]]
                                                           cachePolicy:NSURLCacheStorageNotAllowed
                                                       timeoutInterval:60.0];
    
    //conn.tag =@"leaveRun";
    
    #ifdef DEBUG 
    NSLog(@"URL %@",[request URL]);
    #endif
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
        [self performSelectorOnMainThread:@selector(updateleaveRun)
                               withObject:nil
                            waitUntilDone:NO];
    }
    [pool release];    
}
-(void)updateleaveRun{
     [self checkForOrders];
}
#pragma mark -

#pragma mark Start Run
-(void)initStartRun
{
    dash_summary = [[[NSMutableDictionary alloc]init]retain];
    
    if(self.navigationItem.rightBarButtonItem ==startRunBtn)
    {
        //Check if any sections are filled out.
        //if so, enable startRunBtn
        
        if(![self isRunDataFilledOut])
            startRunBtn.enabled = NO;
        else
            startRunBtn.enabled = YES;
        
        
    }

    
	friends = [[FriendsInfo alloc]init];
	friends.managedObjectContext = self.managedObjectContext;	
    self.navigationItem.rightBarButtonItem = startRunBtn;
    
    [self reloadStartRunData];
    [start_run_table reloadData];
    start_run_table.delegate = self;
    start_run_table.dataSource = self;
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
                success = NO;
		}
		else
			[Utils showAlert:@"No Friends" withMessage:@"In Order to user Java Dash to its fullest extent, you should find some friends. Press the 'BUMP' button to make some friends first" inView:self.view];
	}
	else 
		[Utils showAlert:@"No Contact Added" withMessage:@"Please add your contact information to get started with using Java Dash" inView:self.view];
    
	return success;
}
-(void)reloadStartRunData{
	
	DashSummary *dash = [DashSummary instance];
	NSMutableDictionary *dash_dict = [dash getDict];
    if(cells != nil)
    {
        [cells release];
        cells = nil;
    }
	cells = [[NSMutableArray alloc] init];
	static NSString *CellIdentifier = @"Cell";	
	
	TKLabelTextViewCell *location_cell = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
	location_cell.tag = LOCATION_TAG;
	location_cell.label.text = LOCATION_TEXT;
    if([[dash_dict objectForKey:@"selected_location"] count]>0)
    {
        NSString *_name = [[dash_dict objectForKey:@"selected_location"]objectForKey:@"name"];
        NSString *_address = [[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"address"]objectAtIndex:0];
        
        NSString *_cityState = [NSString stringWithFormat:@"%@,%@",[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"city"],[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"state_code"]];
        
        location_cell.textView.text = [NSString stringWithFormat:@"%@\n%@\n%@",_name,_address,_cityState];
    }
   if([dash_dict objectForKey:@"selected_location"] == NULL)
        location_cell.textView.text = @"Tap to choose location";

    
	[cells addObject:location_cell];
	[location_cell release];
	
	TKLabelTextViewCell *time_cell = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
	time_cell.tag = TIME_TAG;
	time_cell.label.text = TIME_TEXT;
    if([dash_dict count]>0)
    {
        if([dash_dict objectForKey:@"selected_date"]!= (id)[NSNull null])
        {
            NSDateFormatter *newFormatter = [[[NSDateFormatter alloc] init] autorelease];
            
            [newFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss ZZZ a"];
            NSString *dateString = [newFormatter stringFromDate:[dash_dict objectForKey:@"selected_date"]];
            time_cell.textView.text = dateString;
        }
	}
    if([dash_dict objectForKey:@"selected_date"] == NULL)
        time_cell.textView.text = @"Tap to select time";
    
    [cells addObject:time_cell];
	[time_cell release];
	
	TKLabelTextViewCell *attendees_cell = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
	attendees_cell.tag = PEOPLE_TAG;
	attendees_cell.label.text = PEOPLE_TEXT;
	
	NSMutableString *users_str = [[NSMutableString alloc]init];
    
    if([dash_dict count]>0)
    {
        for(int i=0;i<[[dash_dict objectForKey:@"selected_friends"] count];i++)
        {
            
            [users_str appendString:[NSString stringWithFormat:@"%@ %@\n",[[[dash_dict objectForKey:@"selected_friends"] objectAtIndex:i]valueForKey:@"first_name"],[[[dash_dict objectForKey:@"selected_friends"] objectAtIndex:i]valueForKey:@"last_name"]]];
        }

        if(users_str != (id)[NSNull null])
            attendees_cell.textView.text = users_str;
	}
    if([dash_dict objectForKey:@"selected_friends"] == NULL)
        attendees_cell.textView.text = @"Tap to add friends to run";
     
	[cells addObject:attendees_cell];
	[attendees_cell release];
    
    [start_run_table reloadData];
    start_run_table.delegate = self;
    start_run_table.dataSource = self;
	
}
#pragma mark Complete Summary
-(void)completeSummary:(id)sender
{    
	DashSummary *dash = [DashSummary instance];
	
	NSMutableDictionary *dash_dict = [dash getDict]; 
	
    if(dash_dict == NULL)
		return;
    
    NSString *_address = [[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"address"]objectAtIndex:0];
	NSString *_cityState = [NSString stringWithFormat:@"%@,%@",[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"city"],[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"state_code"]];
    
	NSString *address = [NSString stringWithFormat:@"%@\n%@",_address,_cityState];
	NSString *selected_yelp_id = [[dash_dict objectForKey:@"selected_location"] objectForKey:@"id"];
    NSString *image_url = @"";
    
    if([[dash_dict objectForKey:@"selected_location"] objectForKey:@"image_url"] != NULL)
        image_url = [[dash_dict objectForKey:@"selected_location"] objectForKey:@"image_url"];
    
	
    
	NSMutableArray *device_id_array = [[NSMutableArray alloc]init];
	for(int i=0;i<[[dash_dict objectForKey:@"selected_friends"] count];i++)
	{
		[device_id_array addObject:[[[dash_dict objectForKey:@"selected_friends"] objectAtIndex:i]valueForKey:@"device_id"]];
	}
	NSLog(@"device_id_array %@",device_id_array);
    
	
    //Make sure we have data before we send it
    if(![self isRunDataFilledOut])
    {
        [Utils showAlert:@"No Data" withMessage:@"Please add info to Run" inView:self.view];
        return;
    }
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.navigationController.view addSubview:HUD];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
	
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(submitDash:) onTarget:self withObject:dash_dict animated:YES];
}
-(void)submitDash:(NSDictionary *)dash_dict
{
    NSMutableArray *device_id_array = [[NSMutableArray alloc]init];
	for(int i=0;i<[[dash_dict objectForKey:@"selected_friends"] count];i++)
	{
		[device_id_array addObject:[[[dash_dict objectForKey:@"selected_friends"] objectAtIndex:i]valueForKey:@"device_id"]];
	}

    NSString *_address = [[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"address"]objectAtIndex:0];
	NSString *_cityState = [NSString stringWithFormat:@"%@,%@",[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"city"],[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"state_code"]];
    
	NSString *address = [NSString stringWithFormat:@"%@\n%@",_address,_cityState];
	NSString *selected_yelp_id = [[dash_dict objectForKey:@"selected_location"] objectForKey:@"id"];
    NSString *image_url = @"";
    
    if([[dash_dict objectForKey:@"selected_location"] objectForKey:@"image_url"] != NULL)
        image_url = [[dash_dict objectForKey:@"selected_location"] objectForKey:@"image_url"];

    
    //Send a push to all devices
	NSString *push_type = @"doOrder";
	NSString *runnerInfo = [NSString stringWithFormat:@"first_name=%@&last_name=%@&deviceid=%@&selected_date=%@&selected_name=%@&selected_address=%@&selected_url=%@&selected_yelp_id=%@&date_added=%@",
							[[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"],
							[[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"],
							[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],
							[dash_dict objectForKey:@"selected_date"],
							[[dash_dict objectForKey:@"selected_location"] objectForKey:@"name"],
							address,
							image_url,
							selected_yelp_id,
                            [NSDate date],
							nil];
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/startrun.php",baseDomain]]
														   cachePolicy:NSURLCacheStorageNotAllowed
													   timeoutInterval:60.0];
	
	[request setHTTPMethod:@"POST"];
	NSString *post_str = [NSString stringWithFormat:@"device_tokens=%@&push_type=%@&%@",[device_id_array componentsJoinedByString:@","],push_type,runnerInfo];
    #ifdef DEBUG
    NSLog(@"request %@",[request URL]);
    NSLog(@"post_str %@",post_str);
    #endif
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
        NSString * json_str = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        #ifdef DEBUG
        NSLog(@"json_str %@",json_str);
        #endif

        [self performSelectorOnMainThread:@selector(updatesubmitDash)
                               withObject:nil
                            waitUntilDone:NO];
    }

}
-(void)updatesubmitDash
{
    [FlurryAnalytics logEvent:@"Dash Started"];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Order Sent" message:@"Your order has been submitted" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    [alert show];
    [alert release];
    
    
    //Clear the Order info since we dont need it anymore
    DashSummary *dash = [DashSummary instance];
    [dash clearDict];
    [self checkForOrders];
}
-(BOOL)isRunDataFilledOut
{
    //Friends should be an option
    NSMutableDictionary *dash_dict = [[DashSummary instance] getDict]; 
    if([dash_dict objectForKey:@"selected_date"] == NULL || [dash_dict objectForKey:@"selected_location"] == NULL /*|| [dash_dict objectForKey:@"selected_friends"] == NULL*/)
        return NO;
    else
        return YES;
}
#pragma mark -

#pragma mark -
#pragma mark Table view data source

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(view_run_view.superview)
        cell = [orders_cells objectAtIndex:indexPath.row];
    
    if(start_run_view.superview)
        cell =  [cells objectAtIndex:indexPath.row];
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NULL;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return NULL;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int tableViewHeight;
    if(view_run_view.superview)
    {
        TKLabelTextViewCell *cell = [orders_cells objectAtIndex:[indexPath row]];
        NSString *text =  cell.textView.text;
        
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat height = MAX(size.height, 44.0f);
        tableViewHeight =  height + (CELL_CONTENT_MARGIN * 2);
    }
    if(start_run_view.superview)
        tableViewHeight =  100;
    
    return tableViewHeight;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count;
    //Show Run
    if(view_run_view.superview)
        count =  [orders_cells count];
    else if(start_run_view.superview)
        count =  [cells count];
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	[tableView deselectRowAtIndexPath:indexPath animated:YES]; 
	if(start_run_view.superview)
    {    
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
}
-(void)goMapView
{
	MapViewController *mapView = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil]autorelease];
	[self.navigationController pushViewController:mapView animated:YES];
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

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(void)viewDidAppear:(BOOL)animated
{
    if(start_run_view.superview)
    {
        [self reloadStartRunData];
    }
    
    if(self.navigationItem.rightBarButtonItem ==startRunBtn)
    {
        //Check if any sections are filled out.
        //if so, enable startRunBtn
        
        if(![self isRunDataFilledOut])
            startRunBtn.enabled = NO;
        else
            startRunBtn.enabled = YES;
        
        
    }
    
    CoffeeRunSampleAppDelegate *appDelegate  = (CoffeeRunSampleAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate showAdView];
    [self startTimer];
}
-(void)viewDidDisappear:(BOOL)animated
{
     [self stopTimer];
}
#pragma mark Load Yelp Image
-(void)loadYelpImage:(NSString *)img_str
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSURL *picture_url = [NSURL URLWithString:img_str];
    
    NSLog(@"picture_url %@",picture_url);
    if(picture_url != NULL)
    {
        UIImage * img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:picture_url]];
        
        [self performSelectorOnMainThread:@selector(displayPhoto:)
                               withObject:img
                            waitUntilDone:NO];
        
    }
    else
    {
        [self performSelectorOnMainThread:@selector(displayDefaultPhoto)
                               withObject:nil
                            waitUntilDone:NO];

    }
    [pool release];
}
-(void)displayPhoto:(UIImage *)photo
{
    //UIImage* _image = [UIImage imageWithData: data];
    CGSize sz = CGSizeMake(100, 100);
    UIImage *smallImage = [Utils imageWithImage:photo scaledToSize:sz];
    yelp_img.image = smallImage;
}
-(void)displayDefaultPhoto
{
    yelp_img.image = [UIImage imageNamed:@"blank_location.png"];
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
	
    [super dealloc];
}


@end
