//
//  NameListViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NameListViewController.h"
#import "CoffeeDetailsView.h"
#import "Utils.h"
#import "Order.h"
@implementation NameListViewController
@synthesize companyName;
@synthesize orderType;
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
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	companyName =[[[[NSUserDefaults standardUserDefaults] valueForKey:@"Current Order Dict"]objectForKey:@"data"]objectForKey:@"selected_name"];
	
	
    Order *order = [Order sharedOrder];
	NSDictionary *user_order = [order currentOrder];
	
	self.title = [[[user_order objectForKey:@"run"]objectForKey:@"location"]objectForKey:@"name"];

	companyName = [Utils getCompanyName:[[[user_order objectForKey:@"run"]objectForKey:@"location"]objectForKey:@"name"]];

	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)]autorelease];

/*	
	if([orderType isEqualToString:@"Drinks"])
	{
		if([companyName isEqualToString:@"Dunkin Donuts"])
			beverage_array = [[NSMutableArray alloc]initWithObjects:@"Coffee",@"Espresso Drinks",@"Coolata",@"Dunkaccino",@"Hot Chocolate",@"Turbo Shot",nil];
		else if([companyName isEqualToString:@"Starbucks"])
			beverage_array = [[NSMutableArray alloc]initWithObjects:@"Coffee",@"Espresso",@"Frappuccino Blended Beverages",@"Chocolate Beverages",@"Tazo Teas",@"Kids' Drinks & Others",@"Vivanno Smoothies",@"Bottled Drinks",@"Espresso Plain",nil];
		else if([companyName isEqualToString:@"Bad Ass"])
			beverage_array = [[NSMutableArray alloc]initWithObjects:@"Coffee Drinks",@"Signature Blended Lattes",@"Espresso",@"Signature Lattes",@"Non-Coffee Drinks",@"Smoothies",@"Tea",@"Coffee",@"Espresso Drinks",@"Cold Drinks",@"Hot Drinks",@"Traditional Lattes",@"Treats",@"Breakfast Sandwiches",nil];
		else 
			beverage_array = [[NSMutableArray alloc]initWithObjects:@"Coffee",@"Espresso Drinks",@"Tea",nil];
	}
	else
	{
		if([companyName isEqualToString:@"Dunkin Donuts"])
			beverage_array = [[NSMutableArray alloc]initWithObjects:@"Wraps",@"Breakfast Sandwiches",@"Hash Browns",@"Flatbread",@"Bagels",@"Cookies & Other Baked Items",@"Fancies",@"Muffins",@"Danish",@"Donut Sticks",nil];
		else if([companyName isEqualToString:@"Starbucks"])
			beverage_array = [[NSMutableArray alloc]initWithObjects:nil];
		else if([companyName isEqualToString:@"Bad Ass"])
			beverage_array = [[NSMutableArray alloc]initWithObjects:nil];
		else 
			beverage_array = [[NSMutableArray alloc]initWithObjects:nil];
		
	}
    [table_view reloadData];
   */ 
}
-(void)close:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}
-(IBAction)chooseDrinkTemp:(id)sender
{
    UIButton *btn = sender;
    
    if(btn.tag ==1)
    {
        printf("hot");
        drink_type = @"Hot";
    }
    else if(btn.tag==2)
    {
        printf("iced");
        drink_type = @"Iced";
    }
    
    drink_temp_view.hidden = YES;
    
    
    //plistDictionary = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"plistDictionary"];
	
	//if(!plistDictionary)
	{
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:@"CoffeeList2.plist"];
		plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
		
        //NSLog(@"plistDictionary %@\n",plistDictionary);
        
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		if (standardUserDefaults) 
			[standardUserDefaults setObject:plistDictionary forKey:@"plistDictionary"];
	}
    //NSLog(@"companyName %@\n",companyName);
    //NSLog(@"drink_type %@",drink_type);
	coffee_dict =[[[plistDictionary objectForKey:companyName]objectForKey:@"Drinks"]objectForKey:drink_type];
    
    NSLog(@"coffee_dict %@",coffee_dict);
    NSLog(@"count %i",[coffee_dict count]);
    sections = [[NSMutableArray alloc]init];
    
    
    // Loop through the books and create our keys
    for (NSDictionary *item in coffee_dict)
    {
        NSLog(@"item %@",item);
        [sections addObject:item];
    }
    
    [table_view reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sections count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dictionary = [coffee_dict objectForKey:[sections objectAtIndex:section]];
    //NSLog(@"dictionary %@",dictionary);
    return [dictionary count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[coffee_dict allKeys] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    //
    //NSLog(@"[sections objectAtIndex:indexPath.section] %@",[sections objectAtIndex:indexPath.section]);
    cell.textLabel.text = [[coffee_dict objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *beverage = [[coffee_dict objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    NSString *drink = [[coffee_dict allKeys] objectAtIndex:indexPath.section];
    
    NSDictionary *drink_dict = [[NSDictionary alloc]initWithObjectsAndKeys:companyName,@"companyName",drink_type,@"drink_type",beverage,@"beverage",drink,@"drink",nil];
    
    
    
    CoffeeDetailsView *listView   = [[CoffeeDetailsView alloc]initWithNibName:nil bundle:nil];
	listView.drink = drink_dict;    
	[self.navigationController pushViewController:listView animated:YES];
    [drink_dict release];
	[listView release];
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
