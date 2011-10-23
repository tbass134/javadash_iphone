//
//  CoffeeDetailsTableViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/14/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "CoffeeDetailsTableViewController.h"
#import "Order.h"

@implementation CoffeeDetailsTableViewController
@synthesize companyName;
@synthesize beverage;
@synthesize orderType;

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

    [self.tableView initWithFrame:CGRectZero style:UITableViewStyleGrouped];
   NSDictionary *plistDictionary = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"plistDictionary"];
	
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
	NSLog(@"coffee_dict %@",coffee_dict);
	
	sections_array = [[NSMutableArray alloc]init];
	savedDrink = [[NSMutableDictionary alloc]init];
	
	for (id theKey in coffee_dict) {
		[sections_array addObject:theKey];
	}
	//Save the company name and product in the SaveDrink Array
	//[savedDrink setObject:[[[[order currentOrder]objectForKey:@"run"]objectForKey:@"location"]objectForKey:@"name"] forKey:@"name"];
	[savedDrink setObject:beverage forKey:@"beverage"];
	
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
    return 1;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [sections_array count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 88.0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	
	NSDictionary *option_dict = [coffee_dict objectForKey:[sections_array objectAtIndex:indexPath.row]];
	UISegmentedControl *seg = [[UISegmentedControl alloc]init];
	
	NSMutableArray *keys = [[NSMutableArray alloc]init];
	for(id key in option_dict)
	{
		[keys addObject:key];
	}
	
	
	SVSegmentedControl *navSC = [[SVSegmentedControl alloc] initWithSectionTitles:keys];
	[keys release];

	navSC.delegate = self;
	navSC.font = [UIFont boldSystemFontOfSize:12];
	navSC.height = 46;
	
	navSC.thumb.tintColor = [UIColor colorWithRed:0 green:0.5 blue:0.1 alpha:1];
	
	navSC.center = CGPointMake(cell.frame.size.width/2, 20);
	[cell addSubview:navSC];
	[navSC release];
	
	
	
	[cell addSubview:seg];
	[seg release];
	
	//cell.textLabel.text = [[coffee_dict objectForKey:[sections_array objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    // Configure the cell...
    
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
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
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

