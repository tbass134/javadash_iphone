//
//  MapViewController.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 12/27/10.
//  Copyright 2010 Dark Bear Interactive. All rights reserved.
//

#import "MapViewController.h"

#import "ParkPlaceMark.h"
#import "FriendsList.h"
#import "FavoritesTableViewController.h"
#import "FavoriteLocations.h"
#import "JSON.h"
#import "URLConnection.h"
#import "Utils.h"
#import "Constants.h"
#import "DashSummary.h"
#import "Tracker.h"
#import "OAuthConsumer.h"

#import "AsyncImageView2.h"

#define kYelpSearchTerm @"Coffee Shop"

@implementation MapViewController
@synthesize mapView,tableView,seg_control,reloadLocation_btn,searchBar;
@synthesize tableDataSource,currentLocation;
@synthesize favorites_array;
@synthesize fetchedResultsController, managedObjectContext;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		}
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(searchCancel:)];

    limit = 20;
    offset = 0;
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
	
	//Show list at starup
	tableView.hidden = NO;
	mapView.hidden = YES;
	[seg_control setSelectedSegmentIndex:0];
	
	load = [[Loading alloc]init];
	self.favorites_array = [FavoriteLocations getAllFavoriteLocations];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(IBAction)changeSegment:(id)sender
{
	if(seg_control.selectedSegmentIndex == 1){
		printf("showMap");
		tableView.hidden = YES;
		mapView.hidden =NO;
        [[Tracker sharedTracker]trackPageView:@"/app_mapview_showMap"];
        
	}
	if(seg_control.selectedSegmentIndex == 0){
		printf("Show list");
		tableView.hidden = NO;
		mapView.hidden = YES;
       [[Tracker sharedTracker]trackPageView:@"/app_mapview_showList"];
	}
	
}
-(IBAction)reloadLocation:(id)sender
{
	printf("reloadLocation");
	[locationManager startUpdatingLocation];
}
-(IBAction)showFavorites:(id)sender
{
    [[Tracker sharedTracker]trackPageView:@"/app_mapview_showFavorites"];
	FavoritesTableViewController *favoritesViewController = [[FavoritesTableViewController alloc] initWithNibName:nil bundle:nil];
	favoritesViewController.managedObjectContext = self.managedObjectContext;
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:favoritesViewController animated:YES];
	[favoritesViewController release];
}
-(void)loadFavoriteLocation:(NSDictionary *)dict
{
	selected_location = dict;		
}


#pragma mark Location Info
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    printf("calling locationManager");
    // store all of the measurements, just so we can see what kind of data we might receive
	//  [locationMeasurements addObject:newLocation];
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (self.currentLocation == nil || self.currentLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.currentLocation = newLocation;
        NSLog(@",self.currentLocation %@",self.currentLocation);
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue 
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of 
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        //	NSLog(@"newLocation.horizontalAccuracy:%d locationManager.desiredAccuracy:%d",newLocation.horizontalAccuracy,locationManager.desiredAccuracy);
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
			
			
            // we have a measurement that meets our requirements, so we can stop updating the location
            // 
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            [self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        }
    
        //NSLog(@"latitude %+.6f, longitude %+.6f\n",newLocation.coordinate.latitude,newLocation.coordinate.longitude);

        NSString *coords = [NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];

        NSString *searchTerm;
        if(searchText != NULL && ![searchText isEqualToString:@""])
        searchTerm = searchText;
        else
        searchTerm = coords;
        
        [self loadData:kYelpSearchTerm loc:searchTerm];

        //if(![[[NSUserDefaults standardUserDefaults]stringForKey:@"is_debug"]boolValue])
        //[self loadData:searchTerm loc:coords];
        /*

        MKReverseGeocoder* theGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
        theGeocoder.delegate = self;
        [theGeocoder start];
        [theGeocoder release];
        */
         
    }

}
- (void)stopUpdatingLocation:(NSString *)state {
	
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"could not retrive Location %@",error);
    [locationManager stopUpdatingLocation];
    [Utils showAlert:@"Could not load current location" withMessage:nil inView:self.view];
    
    if(debug)
        [self loadData:nil loc:@"10977"];
    

	
}
#pragma mark -
#pragma mark reverseGeocoder
- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)place
{
    NSLog(@"place %@", place.postalCode);
	
	CLLocationCoordinate2D userlocation=[place coordinate];
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.2;
	span.longitudeDelta=0.2;
	
	region.span=span;
	region.center=userlocation;
	[mapView setRegion:region animated:TRUE];
    [locationManager stopUpdatingLocation];
	
	
}
- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFailWithError:(NSError*)error
{
    NSLog(@"Could not retrieve the specified place information.\n");
}

-(void)loadData:(NSString *)term loc:(NSString *)l
{
	  //[[Tracker sharedTracker]trackPageView:[NSString stringWithFormat:@"/app_mapview_loadData_with_search_term_%@",term]];
        
        [load showLoading:@"Loading" inView:self.view];
        [self loadYelp:kYelpSearchTerm loc:l];
   }

- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data{
	
    
    
	if(success && [tag isEqualToString:@"YELP"])
	{
       
        [[Tracker sharedTracker]trackPageView:@"/app_mapview_MapDataLoaded"];
		NSString *json_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[self loadDataFromJSONStr:json_str];
		[[NSUserDefaults standardUserDefaults]setValue:json_str forKey:@"yelp"];
        //[json_str release];
	}
	else {
		
	}

	
}

#pragma mark YELP API
- (void)loadYelp:(NSString *)term loc:(NSString *)l {
    
    // OAuthConsumer doesn't handle pluses in URL, only percent escapes
    // OK: http://api.yelp.com/v2/search?term=restaurants&location=new%20york
    // FAIL: http://api.yelp.com/v2/search?term=restaurants&location=new+york
    
    // OAuthConsumer has been patched to properly URL escape the consumer and token secrets 
    
    NSURL *URL;
    
   // NSLog(@"l = %@",l);
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@","];
    if ([l rangeOfCharacterFromSet:set].location != NSNotFound) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&ll=%@&limit=%i&offset=%i&sort=%i",[Utils urlencode:term],l,limit,offset,1]];
    }
    else
    {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&location=%@&limit=%i&offset=%i&sort=%i",[Utils urlencode:term],l,limit,offset,1]];
    }
    
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"PTBdkAuUvjJh8JCiKEHvBg" secret:@"_coFSZoQItl-uGKKV5nNqDhbR70"] autorelease];
    OAToken *token = [[[OAToken alloc] initWithKey:@"Oas9vU3hIvjKpTjRy1rRzyJj4h9F43od" secret:@"2KCzJstOOSRNR9cDWKClmqWP7xE"] autorelease];  
    
    NSLog(@"URL %@",URL);
    id<OASignatureProviding, NSObject> provider = [[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease];
    NSString *realm = nil;  
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];
    
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
    [load hideLoading];
    [Utils showAlert:@"Could not load data" withMessage:nil inView:self.view];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [load hideLoading];
     loadingView.hidden = YES;
    NSString *json_str = [[NSString alloc] initWithData:_yelpResponseData encoding:NSUTF8StringEncoding];
    //NSLog(@"json_str %@",json_str);
    SBJSON *parser = [[SBJSON alloc] init];
    yelp_dict= [[parser objectWithString:json_str error:nil]retain];
    total = [[yelp_dict objectForKey:@"total"]intValue];
    [parser release];
    
    if([yelp_dict objectForKey:@"error"] != NULL)
    {
        [Utils showAlert:@"Could not load data" withMessage:@"Please try again" inView:nil];
        return;
    }
    
    float lat = [[[[yelp_dict objectForKey:@"region"]objectForKey:@"center"]objectForKey:@"latitude"]floatValue];
    
    float lng = [[[[yelp_dict objectForKey:@"region"]objectForKey:@"center"]objectForKey:@"longitude"]floatValue];
    
    NSLog(@"lat %f",lat);
    NSLog(@"lng %f",lng);
    CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude: lat longitude:lng];
    
    CLLocationCoordinate2D userlocation=[tempLocation coordinate];
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.2;
	span.longitudeDelta=0.2;
	
	region.span=span;
	region.center=userlocation;
	[mapView setRegion:region animated:TRUE];
    
    
    if(offset<20)
    {
        if([self.mapView.annotations count]>1)
            [self.mapView removeAnnotations:self.mapView.annotations];
    }
    
    if(self.tableDataSource == NULL)
        self.tableDataSource = [[NSMutableArray alloc]init];
    
    for(id items in [yelp_dict objectForKey:@"businesses"])
    {
        [self.tableDataSource addObject:items];
        location = [[CoffeeLocation alloc]init];
        NSMutableDictionary *obj = items;
        //NSLog(@"obj.name %@", [obj objectForKey:@"name"]);
        
        location.rating_img_url			= [obj objectForKey:@"rating_img_url"];
        location.country_code			= [obj objectForKey:@"country_code"];
        location.id						= [obj objectForKey:@"id"];
        location.is_closed				= [obj objectForKey:@"is_closed"];
        location.city					= [[obj objectForKey:@"location"]objectForKey:@"city"];
        location.mobile_url				= [obj objectForKey:@"mobile_url"];
        location.review_count			= [obj objectForKey:@"review_count"];
        location.zip					= [obj objectForKey:@"zip"];
        location.state					= [obj objectForKey:@"state"];
        location.latitude				= [[[obj objectForKey:@"location"]objectForKey:@"coordinate"]objectForKey:@"latitude"];
        location.rating_img_url_small	= [obj objectForKey:@"rating_img_url_small"];
        location.address1				= [obj objectForKey:@"address1"];
        location.address2				= [obj objectForKey:@"address2"];
        location.address3				= [obj objectForKey:@"address3"];
        location.phone					= [obj objectForKey:@"phone"];
        location.state_code				= [[obj objectForKey:@"location"]objectForKey:@"state_code"];
        location.photo_url				= [obj objectForKey:@"photo_url"];
        location.distance				= [obj objectForKey:@"distance"];
        location.name					= [obj objectForKey:@"name"];
        location.url					= [obj objectForKey:@"url"];
        location.avg_rating				= [obj objectForKey:@"avg_rating"];
        location.longitude				= [[[obj objectForKey:@"location"]objectForKey:@"coordinate"]objectForKey:@"longitude"];
        location.nearby_url				= [obj objectForKey:@"nearby_url"];
        location.photo_url_small		= [obj objectForKey:@"photo_url_small"];
        
        
        float lat = [location.latitude floatValue];
        float lng = [location.longitude floatValue];
        
        CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        ParkPlaceMark *placemark=[[[ParkPlaceMark alloc] initWithCoordinate:[tempLocation coordinate]]retain];
        placemark.cam_title = location.name;
        placemark.cam_subtitle = location.name;
        placemark.location_id = location.id;
        placemark.location_dict = obj;
        [mapView addAnnotation:placemark];
        [placemark release];
        [location release];
        [tempLocation release];
    }
    
    [self.tableView setDelegate:self];
    [self.tableView reloadData];
    
    //self.tableDataSource = [yelp_dict objectForKey:@"businesses"];
    //[self.tableView reloadData];

}



-(void)loadDataFromJSONStr:(NSString *)str
{
   
    SBJSON *parser = [[SBJSON alloc] init];
    yelp_dict= [[parser objectWithString:str error:nil]retain];
    total = [[yelp_dict objectForKey:@"total"]intValue];
    [parser release];

    if([yelp_dict objectForKey:@"error"] != NULL)
    {
        [Utils showAlert:@"Could not load data" withMessage:@"Please try again" inView:nil];
        return;
    }
    if(offset<20)
    {
        if([self.mapView.annotations count]>1)
            [self.mapView removeAnnotations:self.mapView.annotations];
    }
       
    if(self.tableDataSource == NULL)
        self.tableDataSource = [[NSMutableArray alloc]init];
    
    for(id items in [yelp_dict objectForKey:@"businesses"])
    {
        [self.tableDataSource addObject:items];
        location = [[CoffeeLocation alloc]init];
        NSMutableDictionary *obj = items;
        //NSLog(@"obj.name %@", [obj objectForKey:@"name"]);

        location.rating_img_url			= [obj objectForKey:@"rating_img_url"];
        location.country_code			= [obj objectForKey:@"country_code"];
        location.id						= [obj objectForKey:@"id"];
        location.is_closed				= [obj objectForKey:@"is_closed"];
        location.city					= [[obj objectForKey:@"location"]objectForKey:@"city"];
        location.mobile_url				= [obj objectForKey:@"mobile_url"];
        location.review_count			= [obj objectForKey:@"review_count"];
        location.zip					= [obj objectForKey:@"zip"];
        location.state					= [obj objectForKey:@"state"];
        location.latitude				= [[[obj objectForKey:@"location"]objectForKey:@"coordinate"]objectForKey:@"latitude"];
        location.rating_img_url_small	= [obj objectForKey:@"rating_img_url_small"];
        location.address1				= [obj objectForKey:@"address1"];
        location.address2				= [obj objectForKey:@"address2"];
        location.address3				= [obj objectForKey:@"address3"];
        location.phone					= [obj objectForKey:@"phone"];
        location.state_code				= [[obj objectForKey:@"location"]objectForKey:@"state_code"];
        location.photo_url				= [obj objectForKey:@"photo_url"];
        location.distance				= [obj objectForKey:@"distance"];
        location.name					= [obj objectForKey:@"name"];
        location.url					= [obj objectForKey:@"url"];
        location.avg_rating				= [obj objectForKey:@"avg_rating"];
        location.longitude				= [[[obj objectForKey:@"location"]objectForKey:@"coordinate"]objectForKey:@"longitude"];
        location.nearby_url				= [obj objectForKey:@"nearby_url"];
        location.photo_url_small		= [obj objectForKey:@"photo_url_small"];


        float lat = [location.latitude floatValue];
        float lng = [location.longitude floatValue];

        CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        ParkPlaceMark *placemark=[[[ParkPlaceMark alloc] initWithCoordinate:[tempLocation coordinate]]retain];
        placemark.cam_title = location.name;
        placemark.cam_subtitle = location.name;
        placemark.location_id = location.id;
        placemark.location_dict = obj;
        [mapView addAnnotation:placemark];
        [placemark release];
        [location release];
        [tempLocation release];
    }
    
   
    
    [self.tableView setDelegate:self];
    [self.tableView reloadData];

    //self.tableDataSource = [yelp_dict objectForKey:@"businesses"];
    //[self.tableView reloadData];
      
}
-(BOOL)checkForFavorites:(NSString *)str
{
	BOOL success = NO;
	for (int i=0;i<[self.favorites_array count]; i++) {
		if([str isEqualToString:[[self.favorites_array objectAtIndex:i]objectForKey:@"id"]])
		{
			success = YES;
			break;
		}
		else
			success = NO;
	}
	return success;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(ParkPlaceMark *)annotation {
	

	MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	annView.animatesDrop=TRUE;
	annView.canShowCallout = TRUE;
	
	if([annotation isKindOfClass:[ParkPlaceMark class]])
    {
		if([annotation.location_dict objectForKey:@"image_url"] != NULL)
		{
			//NSLog(@"annotation %@",[annotation.location_dict objectForKey:@"image_url"]);
			AsyncImageView2 *asyncImageView = [[[AsyncImageView2 alloc] initWithFrame:CGRectMake(5, 5, 30, 30)] autorelease];
			[asyncImageView loadImageFromURL:[NSURL URLWithString:[annotation.location_dict objectForKey:@"image_url"]]];
			annView.leftCalloutAccessoryView = asyncImageView;
		}

	}
	UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[rightButton addTarget:self action:@selector(annotationViewClick:) forControlEvents:UIControlEventTouchUpInside];
	annView.rightCalloutAccessoryView = rightButton;
	
	return annView;
}
- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if([view.annotation isKindOfClass:[ParkPlaceMark class]])
    {
		ParkPlaceMark* theAnnotation;
		theAnnotation = (ParkPlaceMark *) view.annotation;
		
		//NSLog(@"theAnnotation %@",theAnnotation.location_dict);
		selected_location = theAnnotation.location_dict;
		
		//[Utils printDict:selected_location];
		
		DashSummary *dash = [DashSummary instance];
		[[dash getDict]setValue:selected_location forKey:@"selected_location"];
		NSLog(@"dash %@", [dash getDict]);
		[self.navigationController popViewControllerAnimated:YES];
	}

	
}
-(void)annotationViewClick:(id)sender
{
}

#pragma mark 
#pragma mark Search Bar
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	//Add the done button.
    self.navigationItem.rightBarButtonItem = cancel;
}
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
    printf("searchBarSearchButtonClicked");
    self.navigationItem.rightBarButtonItem = cancel;
    offset = 0;
	searchText = [searchBar.text retain];
	//NSString *coords = [NSString stringWithFormat:@"%f,%f",self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude];
    
    self.tableDataSource = nil;
	[self loadData:nil loc:searchText];
	[searchBar resignFirstResponder];

}
-(void)searchCancel:(id)sender
{
    searchBar.text = @"";
    self.navigationItem.rightBarButtonItem = nil;
	[searchBar resignFirstResponder];

}
-(void)goNext
{
	FriendsList *runDetailsViewController = [[FriendsList alloc] initWithNibName:@"RunDetails" bundle:nil];
	runDetailsViewController.managedObjectContext = self.managedObjectContext;
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:runDetailsViewController animated:YES];
	[runDetailsViewController release];
	
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [self.tableDataSource count];
    
    if([self.tableDataSource count]<total)
        return [self.tableDataSource count]+1;
    else
        return [self.tableDataSource count];
 
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     
    static NSString *moreCellId = @"moreCell";
    UITableViewCell *cell = nil;
	
    NSUInteger row = [indexPath row];
    NSUInteger count = [self.tableDataSource count];
	
    if (row == count) {
		
        cell = [tv dequeueReusableCellWithIdentifier:moreCellId];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] 
                     initWithStyle:UITableViewCellStyleDefault 
                     reuseIdentifier:moreCellId] autorelease];
        }
		
        cell.textLabel.text = @"Load more items...";
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        return cell;
		
        
    } else {
        
        NSDictionary *obj = [self.tableDataSource objectAtIndex:indexPath.row];
        
        const NSInteger TOP_LABEL_TAG = 1001;
        const NSInteger BOTTOM_LABEL_TAG = 1002;
        const NSInteger DISTANCE_TAG = 1003;
        
        const NSInteger ASYNC_IMAGE_TAG  = 1004;
        
        UILabel *topLabel;
        UILabel *bottomLabel;
        UILabel *distanceLabel;
        AsyncImageView2 *asyncImageView;
        
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
            
            asyncImageView = [[[AsyncImageView2 alloc] initWithFrame:CGRectMake(5, 5, 50, 50)] autorelease];
            asyncImageView.tag = ASYNC_IMAGE_TAG;
            [cell.contentView addSubview:asyncImageView];
            
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
                         0.5 * (self.tableView.rowHeight - 2 * LABEL_HEIGHT)+LABEL_HEIGHT,
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
            bottomLabel.font = [UIFont systemFontOfSize:13];

            
            
            // Create the label for the distance text
            //
            distanceLabel =
            [[[UILabel alloc]
              initWithFrame:
              CGRectMake(
                         asyncImageView.frame.size.width+10,
                         asyncImageView.frame.size.height,
                         self.tableView.bounds.size.width -asyncImageView.frame.size.width,
                         LABEL_HEIGHT *2)]
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
            distanceLabel.font = [UIFont systemFontOfSize:13];

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
            asyncImageView = (AsyncImageView2 *)[cell viewWithTag:ASYNC_IMAGE_TAG];
        }
        
        topLabel.text = [obj objectForKey:@"name"];
        
        
        BOOL checked;
        if([self checkForFavorites:[obj objectForKey:@"id"]])
            checked = YES;
        else
            checked = NO;
        
        BOOL checked2 = [[obj valueForKey:@"checked"] boolValue];
        UIImage *indicatorImage = (checked || checked2) ? [UIImage imageNamed:@"star_active.png"] : [UIImage imageNamed:@"star.png"];
        
        cell.accessoryView =
        [[[UIImageView alloc]
          initWithImage:indicatorImage]
         autorelease];
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, indicatorImage.size.width, indicatorImage.size.height);
        button.frame = frame;  
        [button setBackgroundImage:indicatorImage forState:UIControlStateNormal];
        [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
        
        @try {
            
            NSString *_address = [[[obj objectForKey:@"location"]objectForKey:@"address"]objectAtIndex:0];
            NSString *_city = [[obj objectForKey:@"location"]objectForKey:@"city"];
            NSString *_state = [[obj objectForKey:@"location"]objectForKey:@"state_code"];
            bottomLabel.text = [NSString stringWithFormat:@"%@\n%@, %@",_address,_city,_state];
            
            
            //Distance
            float miles = [[obj objectForKey:@"distance"]intValue]*0.000621371192;        

            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setMaximumFractionDigits:5];
            [formatter setRoundingMode: NSNumberFormatterRoundDown];
            
            NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:miles]];
            [formatter release];
            
            if([numberString intValue] ==0)
                distanceLabel.text = @"";
            else if([numberString intValue] <=0)
            {
                float feet = miles * 5280;
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setMaximumFractionDigits:5];
                [formatter setRoundingMode: NSNumberFormatterRoundDown];
                
                NSString *feet_str = [formatter stringFromNumber:[NSNumber numberWithFloat:feet]];
                [formatter release];

                distanceLabel.text = [NSString stringWithFormat:@"%i feet",[feet_str intValue]];
            }
            else
            {
                if([numberString intValue] <=1)
                    distanceLabel.text = [NSString stringWithFormat:@"%i mile",[numberString intValue]];
                else
                    distanceLabel.text = [NSString stringWithFormat:@"%i miles",[numberString intValue]];
            }
            
        }
        @catch (NSException * e) {
            NSLog(@"error %@",e);
        }
        
        if([obj objectForKey:@"image_url"] != (id)[NSNull null])
        {
            [asyncImageView loadImageFromURL:[NSURL URLWithString:[obj objectForKey:@"image_url"]]];
            asyncImageView.hidden = NO;
        }
        else
        {
           [asyncImageView loadImageFromURL:[NSURL URLWithString:@""]];
            asyncImageView.hidden = YES;
        }
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
	
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 90.0;
}
- (void)checkButtonTapped:(id)sender event:(id)event
{
	
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];

    NSMutableDictionary *obj = [self.tableDataSource objectAtIndex:indexPath.row];

    if (indexPath != nil)
    {
		//printf("add To Favorites");
		
		
		BOOL checked = [self checkForFavorites:[obj objectForKey:@"id"]];
		BOOL checked2 = [[[[yelp_dict objectForKey:@"businesses"] objectAtIndex:indexPath.row]valueForKey:@"checked"]boolValue];
		
		UIImage *image;
		if(checked || checked2)
		{
			printf("turn it off");
            if([FavoriteLocations removeFromList:obj])
            {
                [[Tracker sharedTracker]trackPageView:@"/app_mapview_location_removed_bookmark"];
                [[[yelp_dict objectForKey:@"businesses"] objectAtIndex:indexPath.row] setValue:[NSNumber numberWithBool:0] forKey:@"checked"];
                [obj setValue:[NSNumber numberWithBool:0] forKey:@"checked"];
                image = [UIImage imageNamed:@"star.png"];
            }

		}
		else {
			printf("Turn it on");
			[FavoriteLocations writeDataToFile:obj];
            [[Tracker sharedTracker]trackPageView:@"/app_mapview_location_added_bookmark"];
			[[[yelp_dict objectForKey:@"businesses"] objectAtIndex:indexPath.row] setValue:[NSNumber numberWithBool:1] forKey:@"checked"];	
			image = [UIImage imageNamed:@"star_active.png"];
			[obj setValue:[NSNumber numberWithBool:1] forKey:@"checked"];
		}

		
		UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:indexPath];
		UIButton *button = (UIButton *)cell.accessoryView;
		[button setBackgroundImage:image forState:UIControlStateNormal];
			
		self.tableDataSource = [yelp_dict objectForKey:@"businesses"];
        [self.tableView setDelegate:self];
        [self.tableView reloadData];
		
    }
	
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

-(void)viewWillAppear:(BOOL)animated
{
	printf("viewWillAppear");
	self.tableDataSource = [yelp_dict objectForKey:@"businesses"];
	[self.tableView setDelegate:self];
	[self.tableView reloadData];
	
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
       
    
    NSUInteger row = [indexPath row];
	NSUInteger count = [self.tableDataSource count];
	
	if (row == count) 
    {
        offset +=20;
        NSString *coords = [NSString stringWithFormat:@"%f,%f",self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude];
       
        NSString *searchTerm;
        
        if(![searchBar.text isEqualToString:@""] && searchBar.text !=NULL)
            searchTerm = searchBar.text;
        else
            searchTerm = coords;
    

        [self loadData:kYelpSearchTerm loc:searchTerm];
        NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
        if (selected) {
            [self.tableView deselectRowAtIndexPath:selected animated:YES];
        }
		
	} 
    else
    {
       
        NSDictionary *savedLocaton = [[yelp_dict objectForKey:@"businesses"]objectAtIndex:indexPath.row];	
        selected_location = savedLocaton;
        DashSummary *dash = [DashSummary instance];
        [[dash getDict]setValue:selected_location forKey:@"selected_location"];
        //NSLog(@"dash %@", [dash getDict]);
        [self.navigationController popViewControllerAnimated:YES];

	}
}

#pragma mark DETAILS
-(void)showDetails:(NSDictionary *)info
{
}
-(IBAction)chooseLocation:(id)sender
{
	
}
	   
	   
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    //\ e.g. self.myOutlet = nil;
	self.currentLocation = nil;
}


- (void)dealloc {
    [super dealloc];
	[conn release];
	[load release];
	//[self.currentLocation release];
}


@end