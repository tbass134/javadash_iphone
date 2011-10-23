//
//  CoffeeOrderTableViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoffeeOrderTableViewController.h"
#import "Utils.h"
#import "Order.h"
#import "DrinkOrders.h"
@implementation CoffeeOrderTableViewController
@synthesize companyName;
@synthesize beverage;
@synthesize orderType;
#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	appDelegate = [[UIApplication sharedApplication] delegate];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addOrder:)];
	
	plistDictionary = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"plistDictionary"];

	if(!plistDictionary)
	{
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:@"CoffeeList.plist"];
		plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
	
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		if (standardUserDefaults) 
			[standardUserDefaults setObject:plistDictionary forKey:@"plistDictionary"];
			
	}
	coffee_dict =[[[plistDictionary objectForKey:companyName]objectForKey:orderType]objectForKey:beverage];
	sections_array = [[NSMutableArray alloc]init];
	savedDrink = [[NSMutableDictionary alloc]init];
	
	for (id theKey in coffee_dict) {
		[sections_array addObject:theKey];
	}
	//Save the company name and product in the SaveDrink Array
	//[savedDrink setObject:[[[[order currentOrder]objectForKey:@"run"]objectForKey:@"location"]objectForKey:@"name"] forKey:@"name"];
	[savedDrink setObject:beverage forKey:@"beverage"];
	
	
	
	
}
-(void)addOrder:(id)sender
{
	//save the dictionary to a DB or txtFile
	//This is wrong
	//NSString *GMTtimestamp = [NSString stringWithFormat:@"%0.0f", [[Utils dateToGMT:[NSDate date]] timeIntervalSince1970]];
	//NSLog(@"dateToGMT GMTtimestamp %@",GMTtimestamp);
	
	NSString *timestamp = [NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]];
	NSLog(@" timestamp %@",timestamp);
	
	[savedDrink setObject:timestamp forKey:@"timestamp"];
	
	
	//[appDelegate.coffee_orders_array addObject:savedDrink];
	
	//Save the drink into the DrinkOrders Class
	DrinkOrders *drink_orders = [DrinkOrders instance];
	[[drink_orders getArray]addObject:savedDrink];
	
	
	[Utils showAlert:@"Order Added" withMessage:nil inView:self.view];
	[self.navigationController popViewControllerAnimated:YES];
	
/*	
	PlaceOrderViewController *place_order_view   = [[PlaceOrderViewController alloc]initWithNibName:@"PlaceOrderViewController" bundle:nil];
	[self.navigationController pushViewController:place_order_view animated:YES];
	[place_order_view release];
*/
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
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
    return [sections_array count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return[sections_array objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSLog(@"section %i",section);
	return [[coffee_dict objectForKey:[sections_array objectAtIndex:section]]count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   // if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  //  }
   
	cell.textLabel.text = [[coffee_dict objectForKey:[sections_array objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
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
	UITableViewCell *newCell =[tableView cellForRowAtIndexPath:indexPath];
	
	
	NSString *sectionName = [sections_array objectAtIndex:indexPath.section];
	NSString *item = [[coffee_dict objectForKey:[sections_array objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	
	//add elements to NSDictionary
	if([savedDrink objectForKey:sectionName])
	{
		[savedDrink removeObjectForKey:sectionName];
		[savedDrink setObject:item forKey:sectionName];
	}
	else
		[savedDrink setObject:item forKey:sectionName];
	
	int newRow = [indexPath row];
	int oldRow = [lastIndexPath row];
	
	
	if (newRow != oldRow)
	{
		newCell = [tableView  cellForRowAtIndexPath:indexPath];
		newCell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: lastIndexPath]; 
		oldCell.accessoryType = UITableViewCellAccessoryNone;
		
		lastIndexPath = indexPath;	
	}
	

	
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
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

