//
//  SettingsView.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/9/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "SettingsView.h"
#import "Utils.h"
#import "Tracker.h"
#import "DBSignupViewController.h"
#import "CoffeeRunSampleAppDelegate.h"
#import "DBSignupViewController.h"


#import "URLConnection.h"
#import "Constants.h"
#import "MKStoreManager.h"
#import "FacebookViewController.h"


#define MAX_BUMP_CHUNK 1024000.0f


@implementation SettingsView
@synthesize bump_btn,table_view;
//CoreData
@synthesize fetchedResultsController, managedObjectContext;
@synthesize friends_array;


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

	friends = [[FriendsInfo alloc]init];
	friends.managedObjectContext = self.managedObjectContext;	
	self.friends_array = [friends getAllFriends];
    
    
    NSMutableString *name = [[NSMutableString alloc]init];
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"FIRSTNAME"])
        [name appendString:[[NSUserDefaults standardUserDefaults] valueForKey:@"FIRSTNAME"]];
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"LASTNAME"])
        [name appendString:[NSString stringWithFormat:@" %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"LASTNAME"]]];
        
    profile_name.text =  name;
    [name release];
        
	if([[NSUserDefaults standardUserDefaults] valueForKey:@"IMAGE"])
	{
		//Resize it to 30x30
		NSData *image_data = [NSData dataWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"IMAGE"]];
		profile_image.image = [UIImage imageWithData:image_data]; 
	}

   	self.table_view.delegate = self;
	self.table_view.dataSource = self;
	[self.table_view reloadData];
}
-(IBAction)goFacebook:(id)sender
{
    FacebookViewController *fb = [[FacebookViewController alloc] initWithNibName:@"FacebookViewController" bundle:nil];
    fb.managedObjectContext = self.managedObjectContext;	
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:fb];
    [self presentModalViewController:nav animated:YES];
}

#pragma mark Remove Ads
#pragma mark
-(IBAction)removeAds:(id)sender
{
#if debug
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithBool:YES] forKey:@"didPurchaseApp"];
    CoffeeRunSampleAppDelegate *appDelegate  = (CoffeeRunSampleAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate checkForAppPurchase];
    return;
#endif
    
    [[MKStoreManager sharedManager] buyFeature:kFeatureAId onComplete:^(NSString* purchasedFeature) { 
#if debug
        NSLog(@"Purchased: %@", purchasedFeature);
#endif        
        //tell the server about the purchase.
        //Send a push to all devices
        int ts = [[NSDate date] timeIntervalSince1970];
        NSString *userInfo = [NSString stringWithFormat:@"deviceid=%@&ts=%i",
                                [[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],ts];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/userPurchase.php?%@",baseDomain,userInfo]]
                                                               cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                           timeoutInterval:60.0];
        
        URLConnection *conn = [[URLConnection alloc]init];
        [conn setDelegate:self];
        [conn initWithRequest:request];
        
    } 
                                   onCancelled:^ { 
                                       NSLog(@"User Cancelled Transaction"); 
                                   }];

}
- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data
{
	if(!success)
	{
		[Utils showAlert:@"Could not save data to server" withMessage:@"Please try again" inView:self.view];
		return;
	}
    
    NSString * json_str  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if([json_str isEqualToString:@"1"])
    {
        printf("Success");
        [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithBool:YES] forKey:@"didPurchaseApp"];
        CoffeeRunSampleAppDelegate *appDelegate  = (CoffeeRunSampleAppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate checkForAppPurchase];
    }
    
}

#pragma mark BumpAPI
#pragma mark 
-(IBAction)testBump:(id)sender
{
	if([friends checkIfContactAdded])	{
        [[Tracker sharedTracker]trackPageView:@"/app_bump_btn_clicked"];
		bumpObject = [BumpAPI sharedInstance];
		[self startBump];
	}
}
-(IBAction)updateProfile:(id)sender
{
    DBSignupViewController *dbSignupViewController = [[DBSignupViewController alloc] initWithNibName:@"DBSignupViewController" bundle:nil];
    dbSignupViewController.gotoContactInfo = YES;
    [dbSignupViewController setDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:dbSignupViewController];
    
    [self presentModalViewController:nav animated:YES];
    //gotoContactInfo
}
-(void)configBump{
	[bumpObject configAPIKey:@"679ba65f39d5420ea78c4934e44640ec"];//put your api key here. Get an api key from http://bu.mp
	[bumpObject configDelegate:self];
	[bumpObject configParentView:self.view];
	[bumpObject configActionMessage:@"Bump with another Java Dash user"];
}

- (void) startBump{
	printf("Calling startBump");
	[self configBump];
	[bumpObject requestSession];
}

- (void) stopBump{
	[bumpObject endSession];
}

#pragma mark -
#pragma mark BumpAPIDelegate methods
- (void) bumpDataReceived:(NSData *)chunk{
	//The chunk was packaged by the other user using an NSKeyedArchiver, so we unpackage it here with our NSKeyedUnArchiver
	NSDictionary *responseDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:chunk];
	
	if(![friends checkforFriendAdded:responseDictionary])
	{
		if([friends insertFriendData:responseDictionary])
		{
            [[Tracker sharedTracker]trackPageView:@"/app_bump_userDataAdded"];
			[Utils showAlert:@"Added" withMessage:[NSString stringWithFormat:@"%@ %@ has been added to your friends list",[responseDictionary objectForKey:@"FIRSTNAME"],[responseDictionary objectForKey:@"LASTNAME"]] inView:self.view];
			[self stopBump];
			
			self.friends_array = [friends getAllFriends];
			[self.table_view reloadData];
		}
	}
	else
		[Utils showAlert:nil withMessage:@"User has already been added to friends list" inView:self.view];
}
- (void) bumpSessionStartedWith:(Bumper*)otherBumper{
	[self sendBumpData];
}
-(void)sendBumpData
{
	//Create a dictionary describing the move to the other client.
	NSMutableDictionary *bumpDict = [[NSMutableDictionary alloc] initWithCapacity:6];
	
	
	[bumpDict setObject:[[bumpObject me] userName]  forKey:@"USER_ID"];
	[bumpDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"_UALastDeviceToken"] forKey:@"TOKEN"];
	[bumpDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTNAME"]forKey:@"FIRSTNAME"];
	[bumpDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"LASTNAME"]forKey:@"LASTNAME"];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"EMAIL"] != NULL)
        [bumpDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"EMAIL"]forKey:@"EMAIL"];
    
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"IMAGE"] != NULL)
		[bumpDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"IMAGE"]forKey:@"IMAGE"];
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"NUMBER"] != NULL)
		[bumpDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"NUMBER"]forKey:@"NUMBER"];
	
	
	if([[NSKeyedArchiver archivedDataWithRootObject:bumpDict] length] > MAX_BUMP_CHUNK) 
	{ 
		int dlen = [[NSKeyedArchiver archivedDataWithRootObject:bumpDict] length]; 
		for (int i=1; i <= (int)ceil(((float)dlen / MAX_BUMP_CHUNK)); i++) { 
			int maxr=0; 
			if ((MAX_BUMP_CHUNK*i) > dlen) { 
				maxr = dlen-(MAX_BUMP_CHUNK*(i-1)); 
			} else { 
				maxr = MAX_BUMP_CHUNK; 
			} 
			NSData *moveChunk = [[NSKeyedArchiver 
								  archivedDataWithRootObject:bumpDict] 
								 subdataWithRange:NSMakeRange(MAX_BUMP_CHUNK*(i-1),maxr)]; 
			[bumpObject sendData:moveChunk]; 
		} 
	}else{ 
		//Data is 1mb or under 
		NSData *moveChunk = [NSKeyedArchiver 
							 archivedDataWithRootObject:bumpDict]; 
		[bumpObject sendData:moveChunk]; 
	} 
	
	[bumpDict release];
}
- (void) bumpSessionEnded:(BumpSessionEndReason)reason {
	NSString *alertText;
	switch (reason) {
		case END_OTHER_USER_QUIT:
			alertText = @"Other user has quit the application.";
			break;
		case END_LOST_NET:
			alertText = @"Connection to Bump server was lost.";
			break;
		case END_OTHER_USER_LOST:
			alertText = @"Connection to other user was lost.";
			break;
		case END_USER_QUIT:
			alertText = @"You have been disconnected.";
			break;
		default:
			alertText = @"You have been disconnected.";
			break;
	}
#if debug
    NSLog(@"%@",alertText);
#endif
}

- (void) bumpSessionFailedToStart:(BumpSessionStartFailedReason)reason {
	
	NSString *alertText;
	switch (reason) {
		case FAIL_NETWORK_UNAVAILABLE:
			alertText = @"Please check your network settings and try again.";
			break;
		case FAIL_INVALID_AUTHORIZATION:
			//the user should never see this, since we'll pass in the correct API auth strings.
			//just for debug.
			alertText = @"Failed to connect to the Bump service. Auth error.";
			break;
		default:
			alertText = @"Failed to connect to the Bump service.";
			break;
	}
	
	if(reason != FAIL_USER_CANCELED){
		//if the user canceled they know it and they don't need a popup.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}



#pragma mark -
#pragma mark Table view data source

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[[self.friends_array objectAtIndex:indexPath.row]valueForKey:@"first_name"],[[self.friends_array objectAtIndex:indexPath.row]valueForKey:@"last_name"]];

	if([[self.friends_array objectAtIndex:indexPath.row]valueForKey:@"image"] != NULL)
	{
		cell.imageView.image = [[UIImage alloc] initWithData:[[self.friends_array objectAtIndex:indexPath.row]valueForKey:@"image"]];
	}
	return cell;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.friends_array count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(void)viewDidAppear:(BOOL)animated
{
    if(![[[NSUserDefaults standardUserDefaults]valueForKey:@"didPurchaseApp"]boolValue])
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Remove Ads" style:UIBarButtonItemStylePlain target:self action:@selector(removeAds:)];
    /*
    friends = [[FriendsInfo alloc]init];
	friends.managedObjectContext = self.managedObjectContext;
     */
	self.friends_array = [friends getAllFriends];
    NSMutableString *name = [[NSMutableString alloc]init];
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"FIRSTNAME"])
        [name appendString:[[NSUserDefaults standardUserDefaults] valueForKey:@"FIRSTNAME"]];
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"LASTNAME"])
        [name appendString:[NSString stringWithFormat:@" %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"LASTNAME"]]];
    
    profile_name.text =  name;
    [name release];
    
	if([[NSUserDefaults standardUserDefaults] valueForKey:@"IMAGE"])
	{
		//Resize it to 30x30
		NSData *image_data = [NSData dataWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"IMAGE"]];
		profile_image.image = [UIImage imageWithData:image_data]; 
	}

	self.table_view.delegate = self;
	self.table_view.dataSource = self;
	[self.table_view reloadData];
    
    CoffeeRunSampleAppDelegate *appDelegate  = (CoffeeRunSampleAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate showAdView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidUnload
{
	// we are being asked to unload our view controller's view,
	// so go ahead and reset our AdBannerView for the next time
		
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



- (void)dealloc {
    [friends release];
    [super dealloc];
}


@end