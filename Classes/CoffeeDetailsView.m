    //
//  CoffeeDetailsView.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/14/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "CoffeeRunSampleAppDelegate.h"
#import "CoffeeDetailsView.h"
#import "OrdersViewController.h"
#import "Order.h"
#import "MyUISegmentController.h"
#import "DrinkOrders.h"
#import "Utils.h"
#import "SavedDrinksList.h"

#import "JSON.h"
#import "DataService.h"
#import "FlurryAnalytics.h"


#define UITEXTVIEWTAG 101
#define FAVESWITCHTAG 201
#define kOFFSET_FOR_KEYBOARD 50.0



@implementation CoffeeDetailsView
@synthesize drink;
@synthesize edit_order_dict;
@synthesize orderType;
@synthesize selected_index;
@synthesize editLocalOrder;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addOrder:)]autorelease];
	
    
    switch_array = [[NSMutableArray alloc]init];
    options_array = [[NSMutableArray alloc]init];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"CoffeeList2.plist"];
    plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
    
	coffee_dict =[[[plistDictionary objectForKey:[drink objectForKey:@"companyName"]]objectForKey:@"Drinks"]objectForKey:@"Drink Options"];    
   
	sections_array = [[NSMutableArray alloc]init];
	savedDrink = [[NSMutableDictionary alloc]init];
	
	scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:scroll];
	
	
    UIView *mainView = [[UIView alloc]init];
    mainView.userInteractionEnabled = YES;
	for (id theKey in coffee_dict) {
		[sections_array addObject:theKey];
        
        NSDictionary *option_dict = [coffee_dict objectForKey:theKey];
        if([[coffee_dict objectForKey:theKey] isKindOfClass:[NSArray class]])
        { 
        
            NSMutableArray *keys = [[NSMutableArray alloc]init];
            for(id key in option_dict)
            {
                [keys addObject:key];
            }
            
            
            UIView *seg_view = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,100
                                                                       )];
            UILabel *title_label = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 100, 20)];
            title_label.backgroundColor = [UIColor clearColor];
            title_label.font = [UIFont boldSystemFontOfSize:15];
            title_label.text = theKey;
            [seg_view addSubview:title_label];
            [title_label release];
            MyUISegmentController *oneRowControl = [[MyUISegmentController alloc]initWithFrame:CGRectMake(0, 20, 310, 1000)];
            oneRowControl.selected_key = theKey;
            //This is now a solid brown color.
            [oneRowControl setColorScheme:SCRSegmentColorSchemeBlackOpaque];
            
            if([keys count] ==2)
            {
                oneRowControl.rowCount = 1;
                oneRowControl.columnCount = 2;
            }
            else if([keys count] ==3)
            {
                oneRowControl.rowCount = 1;
                oneRowControl.columnCount = 3;
            }
            else if([keys count] ==4)
            {
                oneRowControl.rowCount = 2;
                oneRowControl.columnCount = 2;
            }
            else if([keys count] ==5)
            {
                oneRowControl.rowCount = 1;
                oneRowControl.columnCount = 5;
            }
            else if([keys count] ==6)
            {
                oneRowControl.rowCount = 2;
                oneRowControl.columnCount = 3;
            }

            else if([keys count] ==7)
            {
                oneRowControl.rowCount = 4;
                oneRowControl.columnCount = 3;
            }
            else if([keys count] ==8)
            {
                oneRowControl.rowCount = 2;
                oneRowControl.columnCount = 4;
            }
            else  if([keys count] ==15)          
            {
                oneRowControl.rowCount = 5;
                oneRowControl.columnCount = 3;
            }

            else  if([keys count] ==18)          
            {
                oneRowControl.rowCount = 9;
                oneRowControl.columnCount = 2;
            }

            else  if([keys count] ==20)           
            {
                oneRowControl.rowCount = 10;
                oneRowControl.columnCount = 2;
            }

            oneRowControl.segmentTitles = keys; 
            [keys release];
            CGRect oneRowControlFrame = oneRowControl.frame;
            oneRowControlFrame.size.height = oneRowControl.rowCount* 36;
            [seg_view addSubview:oneRowControl];
            

            CGRect updatedFrame = seg_view.frame;
            updatedFrame.size.height = 20 + oneRowControlFrame.size.height +10;
            seg_view.frame = updatedFrame;            
            
            [oneRowControl addTarget:self action:@selector(selectedIndexChanged:) forControlEvents:UIControlEventValueChanged];

            
            if(edit_order_dict != NULL)
            {
                    for(int i=0;i<[option_dict count];i++)
                    {
                    
                        if([[option_dict objectAtIndex:i] isEqualToString:[edit_order_dict objectForKey:theKey]])
                           {
                               oneRowControl.selectedIndex = i;
                               break;
                           }
                    }
            }
            
            [oneRowControl release];
            [mainView addSubview:seg_view];
            [seg_view release];
         
          ;}
	}
    for (id theKey in coffee_dict) {
        if(![[coffee_dict objectForKey:theKey] isKindOfClass:[NSArray class]])
        {
            UIView *switchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            UILabel *switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 200, 20)];
            switchLabel.font = [UIFont boldSystemFontOfSize:15];
            switchLabel.text = theKey;
            switchLabel.backgroundColor = [UIColor clearColor];
            [switchView addSubview:switchLabel];
            [switchLabel release];
            UISwitch *_switch = [[UISwitch alloc]initWithFrame:CGRectMake(0,25, 75, 100)];
            _switch.tag = 300 + switchTagInt;
            NSDictionary *tempDict = [[NSDictionary alloc]initWithObjectsAndKeys:theKey,@"theKey", nil];

            [switch_array addObject:tempDict];
            [switchView addSubview:_switch];
            [_switch release];
            [tempDict release];
            switchTagInt++;
            
            CGRect switchViewframe = switchView.frame;
            switchViewframe.size.height = switchView.frame.size.height +30;
            switchView.frame = switchViewframe;     
             
            [mainView addSubview:switchView];
            //[switchLabel release];
            [switchView release];
        }
    }

	//Add a text box for other options
    UIView *optionsView = [[UIView alloc]init];
	optionsView.frame  = CGRectMake(0, 0, self.view.frame.size.width, 70);
	UILabel *options_label = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 100, 20)];
	options_label.backgroundColor = [UIColor clearColor];
    options_label.font = [UIFont boldSystemFontOfSize:15];
	
	options_label.text = @"Options";
	[optionsView addSubview:options_label];
	[options_label release];
	
	UITextField *options_txt = [[UITextField alloc]initWithFrame:CGRectMake(5, 
																		  20,
																		  self.view.frame.size.width-5,
																		  50)];
    options_txt.placeholder = @"Add details to this order";
    options_txt.backgroundColor = [UIColor clearColor];
    options_txt.delegate = self;
    options_txt.tag = UITEXTVIEWTAG;
    
    if(edit_order_dict != NULL && ![[edit_order_dict objectForKey:@"Custom"] isEqualToString:@""])
    {
        options_txt.text = [edit_order_dict objectForKey:@"Custom"];
    }
    
	[optionsView addSubview:options_txt];
	[options_txt release];
     
    [mainView addSubview:optionsView];
	
    UIView *favView = [[UIView alloc]init];
    favView.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
	//add a switch to save as favorite
	UILabel *setFav_label = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 200, 20)];
	setFav_label.text = @"Set As Favorite";
	setFav_label.backgroundColor = [UIColor clearColor];
    setFav_label.font = [UIFont boldSystemFontOfSize:15];
	[favView addSubview:setFav_label];
	[setFav_label release];
	
	UISwitch *setFav_switch = [[UISwitch alloc]initWithFrame:CGRectMake(0,25,0, 30)];
	setFav_switch.tag = FAVESWITCHTAG;
	[favView addSubview:setFav_switch];
	[setFav_switch release];
    [mainView addSubview:favView];
    

    
    if(edit_order_dict == NULL)
        [self autoSelectFirstValue];
 
    
       
    int offset = 0;
    int contentSize;
    for(UIView *child in mainView.subviews) {
        CGPoint point = child.frame.origin;
        
        point.y = offset;
        //child.backgroundColor = [self randomColor];
        child.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5];
        
        CGRect rect = child.frame;
        rect.origin = point;
        child.frame = rect;
        
        offset += child.frame.size.height;
        
        offset += 10;
        contentSize = point.y;
        [scroll addSubview:child];
    }
    //[scroll setContentSize:mainView.frame.size];
    int bottom_padding;
    if(edit_order_dict == NULL)
        bottom_padding = 150;
    else
        bottom_padding = 200;
    
    [optionsView release];
    [favView release];
    [mainView release];
    
    
    [scroll setContentSize:CGSizeMake(self.view.frame.size.width,(contentSize+bottom_padding))];
    [super viewDidLoad];
}
 
         
-(UIColor *) randomColor {
  CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
  CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
  CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
  return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}
- (IBAction)selectedIndexChanged:(id)sender {
    
    MyUISegmentController *segmentedControl = (MyUISegmentController *)sender;
    //NSLog(@"sender %@",segmentedControl.selected_key);
    //NSLog(@"value %@", [[sender segmentTitles] objectAtIndex:[sender selectedIndex]]);
    //self.valueLabel.text = [[sender segmentTitles] objectAtIndex:[sender selectedIndex]];
    
    
    NSString *key = [segmentedControl selected_key];
	NSString *item = [[sender segmentTitles] objectAtIndex:[sender selectedIndex]];
    
	//add elements to NSDictionary
	if([savedDrink objectForKey:key])
	{
		[savedDrink removeObjectForKey:key];
		[savedDrink setObject:item forKey:key];
	}
	else
		[savedDrink setObject:item forKey:key];
}
-(void)autoSelectFirstValue{
    for (id theKey in coffee_dict)
    {
        if([[coffee_dict objectForKey:theKey] isKindOfClass:[NSArray class]])
        { 
            NSDictionary *option_dict = [coffee_dict objectForKey:theKey];
            NSString *key = theKey;
            NSString *item = [option_dict objectAtIndex:0];
            [savedDrink setObject:item forKey:key];
        }
    }

   // NSLog(@"savedDrink %@",savedDrink);
}
-(void)setValueForSegment:(id)sender{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	NSString *key = [segmentedControl selected_key];
	NSString *item = [segmentedControl titleForSegmentAtIndex:[segmentedControl selectedSegmentIndex]];
    
	//add elements to NSDictionary
	if([savedDrink objectForKey:key])
	{
		[savedDrink removeObjectForKey:key];
		[savedDrink setObject:item forKey:key];
	}
	else
		[savedDrink setObject:item forKey:key];
}

-(void)addOrder:(id)sender{
	//save the dictionary to a DB or txtFile	
	NSString *timestamp = [NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]];	
	UISwitch *_fav = (UISwitch *)[self.view viewWithTag:FAVESWITCHTAG];	
	UILabel *_custom_txt = (UILabel *)[self.view viewWithTag:UITEXTVIEWTAG];
    if([savedDrink count] ==0)
	{
		[Utils showAlert:@"No Items Selected" withMessage:nil inView:self.view];
		return;
	}
    for(int i=0;i<[switch_array count];i++)
    {
        UISwitch *_switch = (UISwitch *)[self.view viewWithTag:300+i];	
        NSDictionary *switches_dict = [switch_array objectAtIndex:i];        
        [savedDrink setObject:[NSNumber numberWithBool:_switch.on] forKey:[switches_dict objectForKey:@"theKey"]];	
    }
    
	[savedDrink setObject:[drink objectForKey:@"beverage"] forKey:@"beverage"];
    [savedDrink setObject:[drink objectForKey:@"drink_type"] forKey:@"drink_type"];
     [savedDrink setObject:[drink objectForKey:@"drink"] forKey:@"drink"];
    if(_fav.on)
        [SavedDrinksList writeDataToFile:savedDrink];
    
    if(_custom_txt.text != nil && ![_custom_txt.text isEqualToString:@""])
        [savedDrink setObject:_custom_txt.text forKey:@"Custom"];
	[savedDrink setObject:timestamp forKey:@"timestamp"];
	
	//Save the drink into the DrinkOrders Class
	DrinkOrders *drink_orders = [DrinkOrders instance];
	[[drink_orders getArray]addObject:savedDrink];
    //NSLog(@"drink %@",[drink_orders getArray]);
    
    if(editLocalOrder)
    {
        //NSLog(@"Edit Local Order"); 
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if(edit_order_dict !=NULL)
    {
        Order *order = [Order sharedOrder];
        SBJSON *parser = [[SBJSON alloc] init];	
        NSString *order_str = [parser stringWithObject:savedDrink];
        [parser release];
        
        NSDictionary *selected_drink = [[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:selected_index];
        
        
        
        BOOL orderPlaced = [[DataService sharedDataService]placeOrder:
                                                            [[[order currentOrder]objectForKey:@"run"]objectForKey:@"id"]
                                                                order:order_str
                                                          updateOrder:@"1"
                                                              orderID:[selected_drink objectForKey:@"order_id"]
                                                            ];
        
        if(orderPlaced)
        {
            //clear the drink orders array
            [[DrinkOrders instance]clearArray];
            //[Utils showAlert:@"Order Updated" withMessage:nil inView:self.view];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    else
    {
        printf("adding new order");
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.navigationController.view addSubview:HUD];
        HUD.delegate = self;
        [HUD show:YES];
        [self sendOrders];

        //[self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

-(void)sendOrders{
    
    [HUD hide:YES];
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
        
        
        BOOL orderSent = [[DataService sharedDataService]placeOrder:
                          [[[[Order sharedOrder] currentOrder]objectForKey:@"run"]objectForKey:@"id"] 
                                                              order:[Utils urlencode:theString]
                                                        updateOrder:nil
                                                            orderID:nil];
        
        if(orderSent)
        {
            [FlurryAnalytics logEvent:@"Order Added"];
            self.navigationItem.leftBarButtonItem = nil;
            DrinkOrders *drink_orders = [DrinkOrders instance];
            [drink_orders clearArray];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
            [self.navigationController dismissModalViewControllerAnimated:YES];
            
        }
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    svos = scroll.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:scroll ];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [scroll setContentOffset:pt animated:YES];           
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [scroll setContentOffset:svos animated:YES]; 
    [textField resignFirstResponder];
    return YES;
}


-(void)popToMainMenu
{
    printf("popToMainMenu");
    [self.navigationController  popToRootViewControllerAnimated:YES];
    return;
    UIViewController *mainMenu;
    for(int i=0;i<[[self.navigationController viewControllers] count];i++)
    {
        if([[[self.navigationController viewControllers] objectAtIndex:i] isKindOfClass:[OrdersViewController class]])
        {
            mainMenu =[[self.navigationController viewControllers] objectAtIndex:i];
            break;
            
        }
    }
    [self.navigationController popToViewController:mainMenu animated:YES];
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
