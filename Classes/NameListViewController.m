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
	
    table_view.hidden = YES;
	companyName =[[[[NSUserDefaults standardUserDefaults] valueForKey:@"Current Order Dict"]objectForKey:@"data"]objectForKey:@"selected_name"];
	
	
    Order *order = [Order sharedOrder];
	NSDictionary *user_order = [order currentOrder];
	
	self.title = [[[user_order objectForKey:@"run"]objectForKey:@"location"]objectForKey:@"name"];

	companyName = [Utils getCompanyName:[[[user_order objectForKey:@"run"]objectForKey:@"location"]objectForKey:@"name"]];

	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)]autorelease];

}
-(void)close:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}
-(IBAction)chooseDrinkTemp:(id)sender
{
    UIButton *btn = sender;
    
    if(btn.tag ==1)
        drink_type = @"Hot";
    else if(btn.tag==2)
        drink_type = @"Iced";
    
    table_view.hidden = NO;
    drink_temp_view.hidden = YES;
    
    plistDictionary = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"plistDictionary"];
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:@"CoffeeList2.plist"];
		plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];

	coffee_dict =[[[plistDictionary objectForKey:companyName]objectForKey:@"Drinks"]objectForKey:drink_type];
    
    
    sections = [[NSMutableArray alloc]init];
    //itemsInSection = [[NSMutableArray alloc]init];
    
    // Loop through the items and create our keys
    for (NSDictionary *item in coffee_dict)
    {
        /*
        NSMutableArray *temp = [[NSMutableArray alloc]init]; 
        //NSLog(@"item %@",item);
        for(NSDictionary *items in [coffee_dict objectForKey:item])
        {
            [temp addObject:items];
        }
        NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
        [temp sortUsingDescriptors:[NSArray arrayWithObject: sortOrder]];
         
        [itemsInSection addObject:temp];
         */
        [sections addObject:item];
    }
    
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
	[sections sortUsingDescriptors:[NSArray arrayWithObject: sortOrder]];
    
   
        
    
    NSLog(@"sections %@",sections);
    NSLog(@"itemsInSection %@",itemsInSection);
    
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
    return [dictionary count];  
    
    //return [[sections objectAtIndex:section]count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sections objectAtIndex:section];//[[coffee_dict allKeys] objectAtIndex:section];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    headerView.backgroundColor = [UIColor colorWithRed:108.0f/255.0f green:58.0f/255.0f blue:23.0f/255.0f alpha:1];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(2, -1, self.view.frame.size.width, 30)];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = [sections objectAtIndex:section];
    [headerView addSubview:label];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        UIView *v = [[[UIView alloc] init] autorelease];
        v.backgroundColor = [UIColor colorWithRed:108.0f/255.0f green:58.0f/255.0f blue:23.0f/255.0f alpha:1];
        cell.selectedBackgroundView = v;
    }
    
    cell.textLabel.text = [[coffee_dict objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *beverage = [[coffee_dict objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    //NSString *drink = [[coffee_dict allKeys] objectAtIndex:indexPath.section];
    NSString *drink = [sections objectAtIndex:indexPath.section];
    
    NSLog(@"beverage %@",beverage);
    NSLog(@"drink %@",drink);
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
