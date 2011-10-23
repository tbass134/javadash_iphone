//
//  CoffeeRunSampleAppDelegate.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 12/14/10.
//  Copyright 2010 Dark Bear Interactive. All rights reserved.
//

#import "CoffeeRunSampleAppDelegate.h"

#import "SettingsView.h"
#import "RunViewController.h"
#import "OrdersViewController.h"
#import "Utils.h"
#import "Constants.h"
#import "Tracker.h"
#import "Appirater.h"


#define kApplicationKey @"V1IdApIgQ_WuhReygjVqBg"
#define kApplicationSecret @"lMYfECKyQGypK1MzGOf6Ew"

// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
// Also, your application must bind to the fb[app_id]:// URL
// scheme (substitute [app_id] for your real Facebook app id).
static NSString* kAppId = @"189714094427611";
@implementation CoffeeRunSampleAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize deviceToken;
@synthesize deviceAlias;
@synthesize tabBarController;

//This store the coffee Orders
@synthesize coffee_orders_array;

@synthesize facebook = _facebook,permissions = _permissions;
@synthesize fb_friends,fb_me,fb_tag;

@synthesize adWhirlKey,adsLoaded;
@synthesize didPurchaseApp;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    
    //Facebook
    _permissions =  [[NSArray arrayWithObjects:
                      @"read_stream", @"publish_stream", @"offline_access",nil] retain];
    _facebook = [[Facebook alloc] initWithAppId:kAppId
                                    andDelegate:self];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [prefs valueForKey:@"facebook-accessToken"];
    NSDate *expirationDate = [prefs valueForKey:@"facebook-expirationDate"];
    #if debug
    NSLog(@"expirationDate %@",expirationDate);
#endif
    _facebook.accessToken = accessToken;
    _facebook.expirationDate = expirationDate;


    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
     [[Tracker sharedTracker]trackPageView:@"/app_launched"];
	
    

	//Register for notifications
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
	
	//Alloc the coffee_orders_array
	
	self.coffee_orders_array = [[NSMutableArray alloc]init];
    
	
	if(debug)
    {
        [self initTesting];
        [[NSUserDefaults standardUserDefaults]setValue:@"6607b4cc259f117dd348678a50d2e984a1d7a8f8557bf315cd6b45c1c6c904e7"forKey:@"_UALastDeviceToken"];
        [[NSUserDefaults standardUserDefaults] setValue:@"tony" forKey:@"FIRSTNAME"];
        [[NSUserDefaults standardUserDefaults] setValue:@"hung" forKey:@"LASTNAME"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"NUMBER"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"EMAIL"];
    }
    
	if(![Utils checkIfContactAdded])
	{
       
        dbSignupViewController = [[DBSignupViewController alloc] initWithNibName:@"DBSignupViewController" bundle:nil];
        dbSignupViewController.gotoContactInfo = NO;
        [dbSignupViewController setDelegate:self];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:dbSignupViewController];
        
		
		// Add the tab bar controller's current view as a subview of the window
		[window addSubview:nav.view];
		[window makeKeyAndVisible];	
 	}
	else {
		[self loadUI];
	}
	
    // call the Appirater class
    [Appirater appLaunched];
    
    
	    return YES;
}
-(void)userDataAdded
{
	printf("userDataAddeds");
    [[Tracker sharedTracker]trackPageView:@"/app_userDataAdded"];
	[dbSignupViewController.view removeFromSuperview];
	[self loadUI];
}

-(void)loadUI
{
	NSMutableArray *localViewControllersArray = [[NSMutableArray alloc]initWithCapacity:1];
	UINavigationController *localNavController;
	
	myTabBarController = [[UITabBarController alloc]init];
	RunViewController* runs_view = [[RunViewController alloc]initWithNibName:@"RunViewController" bundle:nil];
	runs_view.title = @"Runs";
	runs_view.managedObjectContext = self.managedObjectContext;	
	localNavController = [[UINavigationController alloc] initWithRootViewController:runs_view];
	localNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	localNavController.tabBarItem.image = [UIImage imageNamed:@"30x-Movie.png"];
	[localViewControllersArray addObject:localNavController];
	[localNavController release]; // Retained by above array
	[runs_view release];
	
	
	OrdersViewController* orders_view = [[OrdersViewController alloc]initWithNibName:nil bundle:nil];
	//orders_view.managedObjectContext = self.managedObjectContext;	
	orders_view.title = @"Orders";
	localNavController = [[UINavigationController alloc] initWithRootViewController:orders_view];
	localNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	localNavController.tabBarItem.image = [UIImage imageNamed:@"30x-Grocery-Bag.png"];
	[localViewControllersArray addObject:localNavController];
	[localNavController release]; // Retained by above array
	[orders_view release];
	
	SettingsView* settings_view = [[SettingsView alloc]initWithNibName:@"SettingsView" bundle:nil];
	settings_view.title = @"Settings";
	settings_view.managedObjectContext = self.managedObjectContext;	
	localNavController = [[UINavigationController alloc] initWithRootViewController:settings_view];
	localNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	localNavController.tabBarItem.image = [UIImage imageNamed:@"30x-Gear.png"];
	[localViewControllersArray addObject:localNavController];
	[localNavController release]; // Retained by above array
	[settings_view release];
	
	myTabBarController.viewControllers = localViewControllersArray;
	[localViewControllersArray release]; // Retained thru above setter	
	myTabBarController.delegate = self;
    [self.window addSubview:myTabBarController.view];
    [self checkForAppPurchase];
    

    if(!self.didPurchaseApp)
    {
        self.adWhirlKey = @"ec8e031962fe4384837daf3c8905045c";
        self.adsLoaded=NO;    
        
        adView = [[AdViewController alloc] initWithNibName:@"AdViewController" bundle:nil];
        
        adView.view.frame =  CGRectMake(0,-30, 320,50);
        AdWhirlView *adWhirlView = [AdWhirlView requestAdWhirlViewWithDelegate:self];

        [adView.view addSubview:adWhirlView];
        [self.window addSubview:adView.view];
        //[adView release];
        
        [self.window bringSubviewToFront:myTabBarController.view];
    }
    [self.window makeKeyAndVisible];
}	


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
	
	// Get a hex string from the device token with no spaces or < >
    self.deviceToken = [[[[_deviceToken description]
						  stringByReplacingOccurrencesOfString: @"<" withString: @""] 
						 stringByReplacingOccurrencesOfString: @">" withString: @""] 
						stringByReplacingOccurrencesOfString: @" " withString: @""];
    #if debug
	NSLog(@"Device Token: %@", self.deviceToken);
#endif
	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
		NSLog(@"Notifications are disabled for this application. Not registering with Urban Airship");
		return;
	}

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.deviceAlias = [userDefaults stringForKey: @"_UADeviceAliasKey"];
    // Display the network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *UAServer = @"https://go.urbanairship.com";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/", UAServer, @"/api/device_tokens/", self.deviceToken];
    NSURL *url = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];
    
    // Send along our device alias as the JSON encoded request body
    if(self.deviceAlias != nil && [self.deviceAlias length] > 0) {
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[[NSString stringWithFormat: @"{\"alias\": \"%@\"}", self.deviceAlias]
                              dataUsingEncoding:NSUTF8StringEncoding]];
    }
	
	
    // Authenticate to the server
    [request addValue:[NSString stringWithFormat:@"Basic %@",
                       [Utils base64forData:[[NSString stringWithFormat:@"%@:%@",
                                                        kApplicationKey,
                                                        kApplicationSecret] dataUsingEncoding: NSUTF8StringEncoding]]] forHTTPHeaderField:@"Authorization"];
    
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
	[request release];
}
-(NSDictionary *)getDeviceInfo{
	return [[[NSDictionary alloc] initWithObjectsAndKeys:self.deviceToken, @"deviceToken", self.deviceAlias, @"deviceAlias", nil]autorelease];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    NSLog(@"Failed to register with error: %@", error);
}
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue: self.deviceToken forKey: @"_UALastDeviceToken"];
    [userDefaults setValue: self.deviceAlias forKey: @"_UALastAlias"];

    #if debug
	NSLog(@"getDeviceInfo %@", [self getDeviceInfo]);
#endif
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
	NSLog(@"ERROR: NSError query result: %@", error);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Notification Received: %@",[userInfo description]);
	
	// Please refer to the following Apple documentation for full details on handling the userInfo payloads
	// http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/ApplePushService/ApplePushService.html#//apple_ref/doc/uid/TP40008194-CH100-SW1
	
	NSString *message =@"";
	if ([[userInfo allKeys] containsObject:@"order"])
	{
		NSDictionary *orderInfo  = [userInfo objectForKey:@"order"];
		[Utils printDict:orderInfo];
		if([[orderInfo objectForKey:@"push_type"] isEqualToString:@"doOrder"])
		{
			message = [NSString stringWithFormat:@"%@ wants to know if you want some coffee!",[orderInfo objectForKey:@"runner"]];
		}
		else if([[orderInfo objectForKey:@"push_type"] isEqualToString:@"notify runner"]){
			message = [NSString stringWithFormat:@"%@ has placed an order!",[orderInfo objectForKey:@"attendee"]];
		}

        [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
	}
    
   // printf("Should be called Reload Data");
	//NSLog(@"message %@",message);
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
	
/*	
	UIAlertView *push_alert = [[UIAlertView alloc] initWithTitle:@"Java Dash"
														 message:message
													   delegate: self
											  cancelButtonTitle: @"Ok"
											  otherButtonTitles: nil];
    [push_alert show];
    [push_alert release];
*/	
}
- (void)applicationWillResignActive:(UIApplication *)application {
   
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
   	//exit(0);
	//[[NSNotificationCenter defaultCenter] removeObserver:@"reloadData"];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    printf("applicationDidBecomeActive");
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
}
- (void)applicationWillTerminate:(UIApplication *)application {
	//Clear the array when the app quits
	self.coffee_orders_array = nil;
}

#pragma mark Testing
-(void)initTesting
{
	FriendsInfo *friends = [[FriendsInfo alloc]init];
	friends.managedObjectContext = self.managedObjectContext;
    
    
	//if(![[NSUserDefaults standardUserDefaults] valueForKey:@"add_temp_friend"])
	{
		//Test Friend
		NSDictionary *temp_dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"Tony 2",@"FIRSTNAME",@"home",@"LASTNAME",@"",@"NUMBER",@"", @"EMAIL",@"b76cc8ae0270c31e99112e8ec823711a41bec4e508a9d74b76edcc290a5b7f45",@"TOKEN", nil];
		if([friends insertFriendData:temp_dict])
		{
			[[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithBool:1] forKey:@"add_temp_friend"];
			//[Utils showAlert:@"Added" withMessage:[NSString stringWithFormat:@"%@ %@ has been added to your friends list",[dict objectForKey:@"FIRSTNAME"],[dict objectForKey:@"LASTNAME"]] inView:self.view];
            #if debug
			NSLog(@"friend Added");
            #endif
		}
	} 
	
	if([[[NSUserDefaults standardUserDefaults]stringForKey:@"is_runner"]boolValue])
	{
		//Runner
		[[NSUserDefaults standardUserDefaults]setValue:@"b76cc8ae0270c31e99112e8ec823711a41bec4e508a9d74b76edcc290a5b7f45"forKey:@"_UALastDeviceToken"];
		[[NSUserDefaults standardUserDefaults] setValue:@"Test" forKey:@"FIRSTNAME"];
		[[NSUserDefaults standardUserDefaults] setValue:@"Runner" forKey:@"LASTNAME"];
		[[NSUserDefaults standardUserDefaults] setValue:@"8457297292" forKey:@"NUMBER"];
        [[NSUserDefaults standardUserDefaults] setValue:@"tbass134@gmail.com" forKey:@"EMAIL"];
        
	}
	else
	{
		//Attendee
		[[NSUserDefaults standardUserDefaults]setValue:@"6607b4cc259f117dd348678a50d2e984a1d7a8f8557bf315cd6b45c1c6c904e7"forKey:@"_UALastDeviceToken"];
		[[NSUserDefaults standardUserDefaults] setValue:@"Test" forKey:@"FIRSTNAME"];
		[[NSUserDefaults standardUserDefaults] setValue:@"Attendee" forKey:@"LASTNAME"];
		[[NSUserDefaults standardUserDefaults] setValue:@"8457297292" forKey:@"NUMBER"];
        [[NSUserDefaults standardUserDefaults] setValue:@"tbass134@gmail.com" forKey:@"EMAIL"];
	}
	[friends release];
	
}

#pragma mark -
#pragma mark Core Data 
//Explicitly write Core Data accessors
- (NSManagedObjectContext *) managedObjectContext {
	if (managedObjectContext != nil) {
		return managedObjectContext;
	}
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
	}
	
	return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
	if (managedObjectModel != nil) {
		return managedObjectModel;
	}
	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
	
	return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (persistentStoreCoordinator != nil) {
		return persistentStoreCoordinator;
	}
	NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
											   stringByAppendingPathComponent: @"CoffeeRunSample.sqlite"]];
	#if debug
	NSLog(@"storeUrl %@",storeUrl);
#endif
	NSError *error = nil;
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
								  initWithManagedObjectModel:[self managedObjectModel]];
	if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
												 configuration:nil URL:storeUrl options:nil error:&error]) {
		/*Error for store creation should be handled in here*/
		printf("persistentStoreCoordinator failed");
	}
	
	return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark - 
#pragma mark AdWhirl
-(void)hideAdView
{
    if(adView.view != nil)
    {
        [adView.view removeFromSuperview];
        myTabBarController.view.frame =  CGRectMake(0,0, 320, 480); 
    }
}
-(void)showAdView
{
    if(adView.view != nil)
    {
        if(self.adsLoaded)
            myTabBarController.view.frame =  CGRectMake(0,70, 320, 461-50); 
    }
}
- (NSString *)adWhirlApplicationKey {
    return self.adWhirlKey;
}

- (UIViewController *)viewControllerForPresentingModalView {
    return myTabBarController;
}

- (void)adWhirlWillPresentFullScreenModal{	
	
}
- (void)adWhirlDidDismissFullScreenModal{
    printf("adWhirlDidDismissFullScreenModal");
	myTabBarController.view.frame =  CGRectMake(0,70, 320, 461-50); 
	//adView.view.frame = CGRectMake(0,20, kAdWhirlViewWidth, kAdWhirlViewHeight); 
	
	
}

- (void)adWhirlDidReceiveAd:(AdWhirlView *)awv{
#if debug
	NSLog(@"adWhirlDidReceiveAd");
#endif
	//[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	//	[self performSelector:@selector(resetNav) withObject:nil afterDelay:.3];
	if(!self.adsLoaded) {
		self.adsLoaded=YES;
        //fix for navbar
        [[[myTabBarController.viewControllers objectAtIndex:myTabBarController.selectedIndex] navigationBar] setCenter:CGPointMake(160, 42)];
		//adWhirlView.frame = CGRectMake(0,-30, kAdWhirlViewWidth, kAdWhirlViewHeight); 
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		
		
		adView.view.frame = CGRectMake(0,20, kAdWhirlViewWidth, kAdWhirlViewHeight); 
		
		//tabBarController.navigationController.navigationBar.frame =  CGRectMake(0,-100, 320,44); 
		myTabBarController.view.frame =  CGRectMake(0,70, 320, 461-50); 
        
        [[[myTabBarController.viewControllers objectAtIndex:myTabBarController.selectedIndex] navigationBar] setCenter:CGPointMake(160, 22)];
        
		[UIView commitAnimations];	//[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
        //  self.navigationController.navigationBarHidden = YES;
	}
}

-(void)checkForAppPurchase
{
    if([[[NSUserDefaults standardUserDefaults]valueForKey:@"didPurchaseApp"]boolValue])
    {
        self.didPurchaseApp = YES;
        [self hideAdView];
    }
}

#pragma mark -
#pragma mark Facebook

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[self facebook] handleOpenURL:url];
}

/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    printf("fbDidLogin");
    NSString *accessToken = _facebook.accessToken;
    NSDate *expirationDate = _facebook.expirationDate;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:accessToken forKey:@"facebook-accessToken"];
    [prefs setValue:expirationDate forKey:@"facebook-expirationDate"];
    [prefs synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookDidLogin" object:self];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
}
// FBRequestDelegate

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    //NSLog(@"array %d",[result isKindOfClass:[NSArray class]]);
    //NSLog(@"Dict %d",[result isKindOfClass:[NSDictionary class]]);
    //NSLog(@"result %@",result);
    /*
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
        
    }
     */
    //NSLog(@"fb_tag %@",fb_tag);
     if ([result isKindOfClass:[NSDictionary class]])
    {
        if([fb_tag isEqualToString:@"me/friends"])
        {
            fb_friends = [result objectForKey:@"data"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getFriendsList" object:nil];
        }
        else if([fb_tag isEqualToString:@"me"])
        {
            fb_me = result;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getUserInfo" object:nil];

        }
    }
};

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@",[error localizedDescription]);
     //[[NSNotificationCenter defaultCenter] postNotificationName:@"getFriendsList" object:nil];
};


////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
    NSLog(@"publish successfully");
}


/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
}





#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
	[deviceAlias release];
	[deviceToken release];
	
	//Core Data
	[managedObjectContext release];
	[managedObjectModel release];
	[persistentStoreCoordinator release];
	
	[self.coffee_orders_array release];
    	
    [super dealloc];
}


@end