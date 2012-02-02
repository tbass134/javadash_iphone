//
//  FavoritesTableViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/7/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "FavoriteLocations.h"
#import "FriendsList.h"
#import "DashSummary.h"
#import "OAuthConsumer.h"
#import "SBJSON.h"

@implementation FavoritesTableViewController
//CoreData
@synthesize fetchedResultsController, managedObjectContext;
@synthesize favorites_array;

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
	}
/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"getAllFavoriteLocations %@",[FavoriteLocations getAllFavoriteLocations]);
	//self.favorites_array = 
    yelp_id_array = [[FavoriteLocations getAllFavoriteLocations]retain];
    
    for(int i=0;i<[yelp_id_array count];i++)
    {
        [self loadYelp:[yelp_id_array objectAtIndex:i]];
    }
    
    self.tableView.backgroundColor = [UIColor clearColor];

    


}
- (void)loadYelp:(NSString *)yelp_id {
    
    // OAuthConsumer doesn't handle pluses in URL, only percent escapes
    // OK: http://api.yelp.com/v2/search?term=restaurants&location=new%20york
    // FAIL: http://api.yelp.com/v2/search?term=restaurants&location=new+york
    
    // OAuthConsumer has been patched to properly URL escape the consumer and token secrets 
   NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/business/%@",yelp_id]];
       
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"PTBdkAuUvjJh8JCiKEHvBg" secret:@"_coFSZoQItl-uGKKV5nNqDhbR70"] autorelease];
    OAToken *token = [[[OAToken alloc] initWithKey:@"Oas9vU3hIvjKpTjRy1rRzyJj4h9F43od" secret:@"2KCzJstOOSRNR9cDWKClmqWP7xE"] autorelease];  
    
    id<OASignatureProviding, NSObject> provider = [[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease];
    NSString *realm = nil;  
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];
    printf("calling yelp\n");
    NSLog(@"request %@",[request URL]);
    
    _yelpResponseData = [[NSMutableData alloc] init];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection release];
    [request release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_yelpResponseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_yelpResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@, %@", [error localizedDescription], [error localizedFailureReason]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *json_str = [[NSString alloc] initWithData:_yelpResponseData encoding:NSUTF8StringEncoding];
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *yelp_obj= [[parser objectWithString:json_str error:nil]retain];
    [parser release];
    [json_str release];
    [self.favorites_array addObject:yelp_obj];
    NSLog(@"[self.favorites_array count] %i",[self.favorites_array count]);
    NSLog(@"[yelp_id_array count] %i",[yelp_id_array count]);
    
    if([self.favorites_array count] == [yelp_id_array count])
    {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView reloadData];
    }
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.favorites_array count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSLog(@"self.favorites_array %@",[self.favorites_array objectAtIndex:indexPath.row]);
    // Configure the cell...
    //cell.textLabel.text = [self.favorites_array objectAtIndex:indexPath.row];
    return cell;
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
		 NSMutableDictionary *obj = [self.favorites_array objectAtIndex:indexPath.row];
		if([FavoriteLocations removeFromList:obj])
		{
			printf("DELEATED");
			self.favorites_array = [FavoriteLocations getAllFavoriteLocations];
			self.tableView.delegate = self;
			self.tableView.dataSource = self;
			[self.tableView reloadData];
        }
		
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
	
	DashSummary *dash = [DashSummary instance];
	[[dash getDict]setValue:[self.favorites_array objectAtIndex:indexPath.row] forKey:@"selected_location"];
	//NSLog(@"dash %@", [dash getDict]);
	[self.navigationController popToRootViewControllerAnimated:YES];
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

