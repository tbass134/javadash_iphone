//
//  AttendeeOrderTableViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/24/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "AttendeeOrderTableViewController.h"
#import "Order.h"

@implementation AttendeeOrderTableViewController
@synthesize run_array;

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
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self.tableView initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	
	
	Order *order = [Order sharedOrder];
	NSDictionary *user_order = [[order currentOrder]objectForKey:@"data"];
	
	
	run_array = [[NSMutableArray alloc]init];
	for (NSDictionary *items in user_order)
	{
		[run_array addObject:items];
	}
#if debug
	NSLog(@"count %i",[run_array count]);
#endif   
    static NSString *CellIdentifier = @"Cell";
	/*
	 "device_ids" = 8b5149b911a2bc2c3bf55e2796da3e1e71ff4d89237ea3f9c0940f9ee6b0762f;
	 id = 1;
	 "runner_device_id" = b76cc8ae0270c31e99112e8ec823711a41bec4e508a9d74b76edcc290a5b7f45;
	 "runner_first_name" = Tony;
	 "runner_last_name" = Hung;
	 "selected_address" = "    286 8th Ave/nNew York,NY";
	 "selected_date" = "2011-03-17 15:55:57";
	 "selected_name" = "Brooklyn Bagel ";
	 timestamp = "2011-03-17 12:48:04";
	 type = runner;
	 */
	
	cells = [[NSMutableArray alloc] init];
    
    TKLabelTextViewCell *cell1 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
	cell1.label.text = @"Runner";
	cell1.textView.text = [NSString stringWithFormat:@"%@ %@",[user_order objectForKey:@"runner_first_name"],[user_order objectForKey:@"runner_last_name"]];
	[cells addObject:cell1];
	[cell1 release];
	
	TKLabelTextViewCell *cell2 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
	cell2.label.text = @"Location";
	cell2.textView.text = [NSString stringWithFormat:@"%@\n%@",[user_order objectForKey:@"selected_name"],[user_order objectForKey:@"selected_address"]];
	[cells addObject:cell2];
	[cell2 release];
	
	TKLabelTextViewCell *cell3 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
	cell3.label.text = @"Time";
	cell3.textView.text = [user_order objectForKey:@"timestamp"];
	[cells addObject:cell3];
	[cell3 release];
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
	return [cells count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.row == 1){
		return 120.0;
	}
	return 44.0;
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

