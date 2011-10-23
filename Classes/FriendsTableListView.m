//
//  FriendsTableListView.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 2/15/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "FriendsTableListView.h"
#import "CoffeeRunSampleAppDelegate.h"

@implementation FriendsTableListView
@synthesize tableView;
//CoreData
@synthesize fetchedResultsController, managedObjectContext;
@synthesize friends_array = _friends_array;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	selected_friends = [[NSMutableArray alloc]init];
	[self readFriendsData];
	
	
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

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[[self.friends_array objectAtIndex:indexPath.row]valueForKey:@"first_name"],[[self.friends_array objectAtIndex:indexPath.row]valueForKey:@"last_name"]];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

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
	[selected_friends release];
    [super dealloc];
}


@end

