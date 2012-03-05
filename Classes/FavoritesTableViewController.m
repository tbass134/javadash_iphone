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
#import "UIImageView+WebCache.h"

@implementation FavoritesTableViewController
//CoreData
@synthesize fetchedResultsController, managedObjectContext;
@synthesize favorites_array,yelp_id_array;

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
    
    self.favorites_array = [[NSMutableArray alloc]init];
    self.yelp_id_array = [FavoriteLocations getAllFavoriteLocations];
    
    if([self.yelp_id_array count]>0)
    {
        
        for(int i=0;i<[self.yelp_id_array count];i++)
        {
            [self loadYelp:[self.yelp_id_array objectAtIndex:i]];
        }
    
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.navigationController.view addSubview:HUD];
        HUD.delegate = self;
        [HUD show:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Favorites" message:@"You currently have no favorite locations" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }

    
    [super viewDidLoad];

    }
/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
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
    //printf("calling yelp\n");
    //NSLog(@"request %@",[request URL]);
    
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
    //NSLog(@"Error: %@, %@", [error localizedDescription], [error localizedFailureReason]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *json_str = [[NSString alloc] initWithData:_yelpResponseData encoding:NSUTF8StringEncoding];
    SBJSON *parser = [[SBJSON alloc] init];
    
    [self.favorites_array addObject:[parser objectWithString:json_str error:nil]];    
    if([self.favorites_array count] == [self.yelp_id_array count])
    {
        [HUD hide:YES];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView reloadData];
    }
    [parser release];
    [json_str release];
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
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 110;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        NSDictionary *obj = [self.favorites_array objectAtIndex:indexPath.row];
        
        const NSInteger TOP_LABEL_TAG = 1001;
        const NSInteger BOTTOM_LABEL_TAG = 1002;
        const NSInteger DISTANCE_TAG = 1003;
        
        const NSInteger ASYNC_IMAGE_TAG  = 1004;
        const NSInteger RATING_IMAGE_TAG = 1005;
        const NSInteger RATING_BUTTON_TAG = 1006;
        const NSInteger YELP_IMAGE_TAG = 1007;
        
        
        UILabel *topLabel;
        UILabel *bottomLabel;
        UILabel *distanceLabel;
        UIImageView *asyncImageView;
        UIImageView *ratingImageView;
        UILabel *rating;
        UIImageView *yelpImage;
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            //
            // Create the cell.
            //
            cell =
            [[[UITableViewCell alloc]
              initWithFrame:CGRectZero
              reuseIdentifier:CellIdentifier]
             autorelease];
            
            
            const CGFloat LABEL_HEIGHT = 20;
            //UIImage *image = [UIImage imageNamed:@"imageA.png"];
            
            asyncImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 75, 75)] autorelease];
            asyncImageView.tag = ASYNC_IMAGE_TAG;
            [cell.contentView addSubview:asyncImageView];
            
            yelpImage = [[[UIImageView alloc] initWithFrame:CGRectMake(160, 70, 51, 26)] autorelease];
            yelpImage.tag = YELP_IMAGE_TAG;
            
            [cell.contentView addSubview:yelpImage];
            
            //
            // Create the label for the top row of text
            //
            
            topLabel =
            [[[UILabel alloc]
              initWithFrame:
              CGRectMake(
                         asyncImageView.frame.size.width+10,
                         0.5 * (self.tableView.rowHeight - 2 * LABEL_HEIGHT),
                         self.tableView.bounds.size.width - asyncImageView.frame.size.width,
                         LABEL_HEIGHT)]
             autorelease];
            [cell.contentView addSubview:topLabel];
            
            //
            // Configure the properties for the text that are the same on every row
            //
            topLabel.tag = TOP_LABEL_TAG;
            topLabel.backgroundColor = [UIColor clearColor];
            topLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
            topLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
            topLabel.font = [UIFont boldSystemFontOfSize:13];            
            //
            // Create the label for the top row of text
            //
            bottomLabel =
            [[[UILabel alloc]
              initWithFrame:
              CGRectMake(
                         asyncImageView.frame.size.width+10,
                         LABEL_HEIGHT,
                         self.tableView.bounds.size.width -asyncImageView.frame.size.width,
                         LABEL_HEIGHT *2)]
             autorelease];
            bottomLabel.numberOfLines = 2;
            [cell.contentView addSubview:bottomLabel];
            
            //
            // Configure the properties for the text that are the same on every row
            //
            bottomLabel.tag = BOTTOM_LABEL_TAG;
            bottomLabel.backgroundColor = [UIColor clearColor];
            bottomLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
            bottomLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
            bottomLabel.font = [UIFont systemFontOfSize:12];
            
            
            
            // Create the label for the distance text
            //
            distanceLabel =
            [[[UILabel alloc]
              initWithFrame:
              CGRectMake(
                         asyncImageView.frame.size.width+10,
                         55,
                         100,
                         20)]
             autorelease];
            distanceLabel.numberOfLines = 1;
            [cell.contentView addSubview:distanceLabel];
            
            //
            // Configure the properties for the text that are the same on every row
            //
            distanceLabel.tag = DISTANCE_TAG;
            distanceLabel.backgroundColor = [UIColor clearColor];
            distanceLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
            distanceLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
            distanceLabel.font = [UIFont systemFontOfSize:11];
            
            
            //Create the image view for the rating
            ratingImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 82, 75, 15)] autorelease];
            ratingImageView.tag = RATING_IMAGE_TAG;
            [cell.contentView addSubview:ratingImageView];
            
                        
            rating = [[UILabel alloc]initWithFrame:CGRectMake(asyncImageView.frame.size.width+10,asyncImageView.frame.size.height,75,LABEL_HEIGHT)];
            rating.backgroundColor = [UIColor clearColor];
            rating.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
            rating.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
            rating.font = [UIFont boldSystemFontOfSize:13];
            [cell.contentView addSubview:rating];
            
            //
            // Create a background image view.
            //
            cell.backgroundView =
            [[[UIImageView alloc] init] autorelease];
            cell.selectedBackgroundView =
            [[[UIImageView alloc] init] autorelease];
        }
        else
        {
            topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
            bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
            distanceLabel = (UILabel *)[cell viewWithTag:DISTANCE_TAG];
            asyncImageView = (UIImageView *)[cell viewWithTag:ASYNC_IMAGE_TAG];
            ratingImageView = (UIImageView *)[cell viewWithTag:RATING_IMAGE_TAG];
            rating = (UILabel *)[cell viewWithTag:RATING_BUTTON_TAG];
            yelpImage = (UIImageView *)[cell viewWithTag:YELP_IMAGE_TAG];
        }
        
        topLabel.text = [obj objectForKey:@"name"];
        
        @try {
            
            NSString *_address = [[[obj objectForKey:@"location"]objectForKey:@"address"]objectAtIndex:0];
            NSString *_city = [[obj objectForKey:@"location"]objectForKey:@"city"];
            NSString *_state = [[obj objectForKey:@"location"]objectForKey:@"state_code"];
            bottomLabel.text = [NSString stringWithFormat:@"%@\n%@, %@",_address,_city,_state];
            
            
            rating.text = [NSString stringWithFormat:@"%@ reviews",[obj objectForKey:@"review_count"]];
                    
        }
        @catch (NSException * e) {
            NSLog(@"error %@",e);
        }
        
        if([obj objectForKey:@"image_url"] != (id)[NSNull null])
        {
            [asyncImageView setImageWithURL:[NSURL URLWithString:[obj objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"blank_location.png"]];
            
            asyncImageView.hidden = NO;
        }
        
        
        if([obj objectForKey:@"rating_img_url"] != (id)[NSNull null])
        {
            [ratingImageView setImageWithURL:[NSURL URLWithString:[obj objectForKey:@"rating_img_url"]] placeholderImage:[UIImage imageNamed:@""]];
            ratingImageView.hidden = NO;
        }
        yelpImage.image = [UIImage imageNamed:@"yelp.png"];
        
        
        
        //
        // Set the background and selected background images for the text.
        // Since we will round the corners at the top and bottom of sections, we
        // need to conditionally choose the images based on the row index and the
        // number of rows in the section.
        //
        UIImage *rowBackground;
        UIImage *selectionBackground;
        NSInteger sectionRows = [self.tableView numberOfRowsInSection:[indexPath section]];
        NSInteger row = [indexPath row];
        if (row == 0 && row == sectionRows - 1)
        {
            rowBackground = [UIImage imageNamed:@"topAndBottomRow.png"];
            selectionBackground = [UIImage imageNamed:@"topAndBottomRowSelected.png"];
        }
        else if (row == 0)
        {
            rowBackground = [UIImage imageNamed:@"topRow.png"];
            selectionBackground = [UIImage imageNamed:@"topRowSelected.png"];
        }
        else if (row == sectionRows - 1)
        {
            rowBackground = [UIImage imageNamed:@"bottomRow.png"];
            selectionBackground = [UIImage imageNamed:@"bottomRowSelected.png"];
        }
        else
        {
            rowBackground = [UIImage imageNamed:@"middleRow.png"];
            selectionBackground = [UIImage imageNamed:@"middleRowSelected.png"];
        }
        ((UIImageView *)cell.backgroundView).image = rowBackground;
        ((UIImageView *)cell.selectedBackgroundView).image = selectionBackground;
        
        return cell;
    
}

/*
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
     NSDictionary *obj = [self.favorites_array objectAtIndex:indexPath.row];
    // Configure the cell...
    cell.textLabel.text = [obj objectForKey:@"name"];;
    return cell;

}
*/
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
		if([FavoriteLocations removeFromList:[obj objectForKey:@"id"]])
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

