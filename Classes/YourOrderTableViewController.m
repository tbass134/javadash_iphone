//
//  YourOrderTableViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 2/22/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "YourOrderTableViewController.h"
#import "DrinkOrders.h"
#import "SavedDrinksList.h"
#import "TapkuLibrary.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation YourOrderTableViewController
@synthesize type;
@synthesize coffee_orders_array;
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
	self.coffee_orders_array = [[NSMutableArray alloc]init];
	[self.tableView initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	if([self.type isEqualToString:@"favorites"])
	{
		self.coffee_orders_array = [SavedDrinksList getAllDrinks];
		NSLog(@"getAllDrinks %@",[SavedDrinksList getAllDrinks]);
		//NSLog(@"coffee_orders_array %@",coffee_orders_array);
		
	}
	else
	{
		//THIS MAY NOT WORK TH 060111
		DrinkOrders *drink_orders = [DrinkOrders instance];
		self.coffee_orders_array = [drink_orders getArray];
	}
    
    [self loadData];
}
-(void)loadData
{
    if(orders_cells != NULL)
        [orders_cells release];
    
    orders_cells = [[NSMutableArray alloc] init];
	int orders_count = [self.coffee_orders_array count];
    NSLog(@"orders_count %i",orders_count);
    
    static NSString *CellIdentifier = @"Cell";	
	if(orders_count >0)
	{
        
		for(int i=0;i<orders_count;i++)
		{
            TKLabelTextViewCell *cell1 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
			NSMutableString *str = [[NSMutableString alloc]init];
            
            
			NSArray *order_dict = [self.coffee_orders_array objectAtIndex:i];
            if(order_dict == (id)[NSNull null])
            {
                printf("its null");
                continue;
            }
            if([order_dict  isKindOfClass:[NSDictionary class]])
			{
                printf("is Dict");
                NSArray *keys = [order_dict allKeys];
                if([keys count]>0)
                {
                    for(int j=0;j<[keys count];j++)
                    {
                        NSString *key = [keys objectAtIndex:j];
                        NSString *value = [order_dict objectForKey:key];
                        //Dont show timestamp
                        if([key isEqualToString:@"timestamp"])
                            continue;
                        [str appendString:[NSString stringWithFormat:@"%@: %@\n",key,value]];
                        //NSLog(@"%@: %@",key,value);
                    }
                }
            }
            else if([order_dict isKindOfClass:[NSArray class]])
			{
				printf("array");
				int drinks_count = [order_dict count];
				NSLog(@"drinks count %i", drinks_count);
				for(int i=0;i<drinks_count;i++)
				{
					[str appendString:[NSString stringWithFormat:@"\nOrder #%i\n",i+1]];
					
					NSArray *keys = [[order_dict objectAtIndex:i] allKeys];
					for(int j=0;j<[keys count];j++)
					{
						NSString *key = [keys objectAtIndex:j];
						NSString *value = [[order_dict objectAtIndex:i]objectForKey:key];
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
	[self.tableView reloadData];
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
	//NSLog(@"count %i",[[coffee_orders_array objectAtIndex:section]count]);
    return [orders_cells count];
}



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    TKLabelTextViewCell *cell = [orders_cells objectAtIndex:[indexPath row]];
    NSString *text =  cell.textView.text;

    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = MAX(size.height, 44.0f);
    return height + (CELL_CONTENT_MARGIN * 2);
    
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [orders_cells objectAtIndex:indexPath.row];

    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

        NSMutableDictionary *order = [self.coffee_orders_array objectAtIndex:indexPath.row];
        if([self.type isEqualToString:@"favorites"])
        {
            if([SavedDrinksList removeFromList:order])
            {
                self.coffee_orders_array = [SavedDrinksList getAllDrinks];  
                NSLog(@"getAllDrinks %@",[SavedDrinksList getAllDrinks]);
            }
        }
        else
        {
            
            DrinkOrders *drink_orders = [DrinkOrders instance];
            NSMutableArray *drink_array = [drink_orders getArray];
            [drink_array removeObjectAtIndex:indexPath.row];
            self.coffee_orders_array = [drink_orders getArray];
        }
            
        [self loadData];

        }
        
   }



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
