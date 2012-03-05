//
//  MutipleOrdersTableView.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 11/5/11.
//  Copyright (c) 2011 Dark Bear Interactive. All rights reserved.
//

#import "MutipleOrdersTableView.h"
#import "TapkuLibrary.h"
#import "Order.h"
#import "CoffeeDetailsView.h"
#import "Utils.h"
#import "CoffeeDetailsView.h"
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation MutipleOrdersTableView
@synthesize selected_index;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    static NSString *CellIdentifier = @"Cell";	
	cells = [[NSMutableArray alloc] init];

    Order *order = [Order sharedOrder];
    orders_cells = [[NSMutableArray alloc] init];
    
	//int orders_count = [[user_order objectForKey:@"orders"]count];
    NSDictionary *drink_dict = [[[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:selected_index]objectForKey:@"drink"];
    
    //NSLog(@"drink_dict %@",drink_dict);
    //NSLog(@"count %i",[drink_dict count]);
	//Save this dictionary into Drink Orders sp we can edit it
    //[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"];
		
		for(int i=0;i<[drink_dict count];i++)
		{
            TKLabelTextViewCell *cell1 = [[TKLabelTextViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
            NSDictionary *current_dict = [drink_dict objectAtIndex:i];
            //NSLog(@"current_dict %@",current_dict);
            NSArray *keys = [current_dict allKeys];
            if([keys count]>0)
            {
                NSMutableString *str = [[NSMutableString alloc]init];
                for(int j=0;j<[keys count];j++)
                {
                    NSString *key = [keys objectAtIndex:j];
                    NSString *value = [current_dict objectForKey:key];
                    //Dont show timestamp
                    if([key isEqualToString:@"timestamp"])
                        continue;
                    [str appendString:[NSString stringWithFormat:@"%@: %@\n",key,value]];
                }
                cell1.textView.text = str;
                [orders_cells addObject:cell1];
                [cell1 release];
            }

        }
    [table_view reloadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Order *order = [Order sharedOrder];
    NSDictionary *drink_dict = [[[[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:selected_index]objectForKey:@"drink"] objectAtIndex:indexPath.row];
    
    //NSLog(@"drink_dict %@",drink_dict);
    //NSLog(@"NSArray %d",[drink_dict isKindOfClass:[NSArray class]]);
    
    NSString *companyName = [Utils getCompanyName:[[[[order currentOrder]objectForKey:@"run"] objectForKey:@"location"]objectForKey:@"name"]];
    
    NSDictionary *options_dict = [[NSDictionary alloc]initWithObjectsAndKeys:companyName,@"companyName",[drink_dict objectForKey:@"drink_type"],@"drink_type",[drink_dict objectForKey:@"beverage"],@"beverage",[drink_dict objectForKey:@"drink"],@"drink",nil];
    
    CoffeeDetailsView *listView   = [[CoffeeDetailsView alloc]initWithNibName:nil bundle:nil];
    listView.drink = options_dict;
    listView.edit_order_dict =  drink_dict;
    listView.selected_index = selected_index;
    [self.navigationController pushViewController:listView animated:YES];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
