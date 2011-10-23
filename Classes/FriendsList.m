//
//  RunDetails.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 1/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendsList.h"
//#import "CoffeeOrderTableViewController.h"
#import "NameListViewController.h"
#import "Constants.h"
#import "Utils.h"

#import "CoffeeRunSampleAppDelegate.h"
#import "DashSummary.h"
@implementation FriendsList
@synthesize tableView;
@synthesize selected_friends;
@synthesize selected_friends_btn;
//CoreData
@synthesize fetchedResultsController, managedObjectContext;
@synthesize friends_array = _friends_array;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    
	selected_friends = [[NSMutableArray alloc]init];
	[self readFriendsData];
}

-(IBAction)addFriends
{
	printf("addFriends");
	DashSummary *dash = [DashSummary instance];
	[[dash getDict]setValue:selected_friends  forKey:@"selected_friends"];	
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)readFriendsData {
	
	CoffeeRunSampleAppDelegate *appDelegate = (CoffeeRunSampleAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;    
	NSEntityDescription *friendsEntity = [NSEntityDescription entityForName:@"Friends" inManagedObjectContext:context];
	
	
	[fetchRequest setEntity:friendsEntity];
	
	NSError *error;
	self.friends_array = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.tableView reloadData];
	
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrien+tationPortrait);
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
    return [self.friends_array count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return 80;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[[self.friends_array objectAtIndex:indexPath.row]valueForKey:@"first_name"],[[self.friends_array objectAtIndex:indexPath.row]valueForKey:@"last_name"]];
	
	if([[self.friends_array objectAtIndex:indexPath.row]valueForKey:@"image"] != NULL)
	{
		cell.imageView.image = [[UIImage alloc] initWithData:[[self.friends_array objectAtIndex:indexPath.row]valueForKey:@"image"]];
	}
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *newCell =[tv cellForRowAtIndexPath:indexPath];
	
	if(newCell.accessoryType == UITableViewCellAccessoryNone)
	{
		[selected_friends addObject:[self.friends_array objectAtIndex:indexPath.row]];
		newCell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		[selected_friends removeObject:[self.friends_array objectAtIndex:indexPath.row]];
		newCell.accessoryType = UITableViewCellAccessoryNone;

	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[selected_friends release];
}


@end
