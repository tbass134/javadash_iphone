//
//  DataService.m
//  OnlySimchas
//
//  Created by Matt Ripston on 9/27/11.
//  Copyright 2011 RustyBrick. All rights reserved.
//

#import "DataService.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "Order.h"
#import "Utils.h"
@implementation DataService

//use to quickly turn off NSLogs
#define IN_TESTING 1
#define TIMEOUT_SECONDS    60

    
static DataService* sharedDataService = nil;

-(void)popUpWithMessage:(NSString*)msg {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}
#pragma mark Login

-(BOOL)getOrders
{
    BOOL dataLoaded = NO;
 
    NSString *urlString = [NSString stringWithFormat:@"%@/getorders.php?deviceid=%@",urlPrefix,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"]];
   
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    [request release];
    
    #if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
    #endif
    NSDictionary *retJSON = [[ret JSONValue] retain];
    if(retJSON != NULL){
        [[Order sharedOrder] setOrder:[NSMutableDictionary dictionaryWithDictionary:retJSON]];      
        dataLoaded = YES;
    }else {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Could not connect to server" waitUntilDone:NO];
        dataLoaded = NO;
    }
    return dataLoaded;
}

-(BOOL)addUser:(NSString *)userName deviceID:(NSString *)deviceid email:(NSString *)email emailEnabled:(BOOL)enableEmail facebookID:(NSString *)fbid enablePush:(BOOL)enable_push
{
    BOOL dataLoaded = NO;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/addUser.php",urlPrefix];;    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setPostValue:userName forKey:@"name"];
    if(deviceid != nil)
    {
        if(![[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"])
            [Utils createUniqueDeviceID];
        
        [request setPostValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"] forKey:@"deviceid"];
    }
    else
         [request setPostValue:deviceid forKey:@"deviceid"];
    
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:[NSNumber numberWithBool:enableEmail] forKey:@"enable_email_use"];
    [request setPostValue:@"IOS" forKey:@"platform"];
    [request setPostValue:fbid forKey:@"fbid"];
    [request setPostValue:[NSNumber numberWithBool:enable_push] forKey:@"enable_push"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    [request release];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Return:%@",ret);
#endif
    NSDictionary *retJSON = [[ret JSONValue] retain];
    if([retJSON objectForKey:@"success"]){
        dataLoaded = YES;
    }else {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Could not connect to server" waitUntilDone:NO];
        dataLoaded = NO;
    }
    return dataLoaded;
}
-(BOOL)startRunWithDict:(NSDictionary *)dash_dict
{
    BOOL dataLoaded = NO;
    // NSLog(@"dash_dict %@",dash_dict);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/startrun.php",urlPrefix];   
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableArray *device_id_array = [[NSMutableArray alloc]init];
    
    
	for(int i=0;i<[[dash_dict objectForKey:@"selected_friends"] count];i++)
	{
		[device_id_array addObject:[[[dash_dict objectForKey:@"selected_friends"] objectAtIndex:i]valueForKey:@"device_id"]];
	}
    NSLog(@"device_id_array %@",device_id_array);
    
    NSString *devices = [device_id_array componentsJoinedByString:@","];
    
    NSString *_address = [[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"address"]objectAtIndex:0];
	NSString *_cityState = [NSString stringWithFormat:@"%@,%@",[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"city"],[[[dash_dict objectForKey:@"selected_location"] objectForKey:@"location"]objectForKey:@"state_code"]];
    
	NSString *address = [NSString stringWithFormat:@"%@\n%@",_address,_cityState];
	NSString *selected_yelp_id = [[dash_dict objectForKey:@"selected_location"] objectForKey:@"id"];
    NSString *image_url = @"";
    
    if([[dash_dict objectForKey:@"selected_location"] objectForKey:@"image_url"] != NULL)
        image_url = [[dash_dict objectForKey:@"selected_location"] objectForKey:@"image_url"];

    
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    [request setPostValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"] forKey:@"first_name"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"] forKey:@"last_name"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"] forKey:@"deviceid"];    
    [request setPostValue:[dash_dict objectForKey:@"selected_date"] forKey:@"selected_date"];
    [request setPostValue:[[dash_dict objectForKey:@"selected_location"] objectForKey:@"name"] forKey:@"selected_name"];
    [request setPostValue:address forKey:@"selected_address"];
    [request setPostValue:image_url forKey:@"selected_url"];
    [request setPostValue:selected_yelp_id forKey:@"selected_yelp_id"];
    [request setPostValue:[NSDate date] forKey:@"date_added"];
    [request setPostValue:devices forKey:@"device_tokens"];
    [request setPostValue:@"doOrder" forKey:@"push_type"];
    
    #if IN_TESTING
    NSMutableString *postVars = [[NSMutableString alloc]init];
    [postVars appendString:[NSString stringWithFormat:@"?first_name=%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"]]];
    [postVars appendString:[NSString stringWithFormat:@"&last_name=%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"]]];
    [postVars appendString:[NSString stringWithFormat:@"&deviceid=%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"]]];
    [postVars appendString:[NSString stringWithFormat:@"&selected_date=%@",[dash_dict objectForKey:@"selected_date"]]];
    [postVars appendString:[NSString stringWithFormat:@"&selected_name=%@",[[dash_dict objectForKey:@"selected_location"] objectForKey:@"name"]]];
    [postVars appendString:[NSString stringWithFormat:@"&selected_address=%@",address]];
    [postVars appendString:[NSString stringWithFormat:@"&selected_url=%@",image_url]];
    [postVars appendString:[NSString stringWithFormat:@"&selected_yelp_id=%@",selected_yelp_id]];
    [postVars appendString:[NSString stringWithFormat:@"&date_added=%@",[NSDate date]]];
    [postVars appendString:[NSString stringWithFormat:@"&device_tokens=%@",devices]];
    [postVars appendString:[NSString stringWithFormat:@"&push_type=%@",@"doOrder"]];
    
    NSLog(@"postVars %@",postVars);
    [postVars release];
    
    #endif
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    [request release];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Return:%@",ret);
#endif
    NSDictionary *retJSON = [[ret JSONValue] retain];
    if([[retJSON objectForKey:@"success"]boolValue]){
        dataLoaded = YES;
    }
    return dataLoaded;
}

-(BOOL)placeOrder:(NSString *)run_id order:(NSString *)order updateOrder:(NSString *)update_order orderID:(NSString *)order_id
{
    BOOL dataLoaded = NO;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/placeorder.php",urlPrefix];;    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setPostValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"] forKey:@"device_id"];    
    [request setPostValue:run_id forKey:@"run_id"];
    [request setPostValue:order forKey:@"order"];
    if(update_order != nil)
        [request setPostValue:update_order forKey:@"updateOrder"];
    if(order_id != nil)
        [request setPostValue:order_id forKey:@"order_id"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    [request release];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Return:%@",ret);
#endif
    NSDictionary *retJSON = [[ret JSONValue] retain];
    if([retJSON objectForKey:@"success"]){
        dataLoaded = YES;
    }else {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Run Ended\nYou cannot add an order to a run that has already ended" waitUntilDone:NO];
        dataLoaded = NO;
    }
    return dataLoaded;
}
-(BOOL)completerun:(NSString *)deviceid runID:(NSString *)run_id
{
    BOOL dataLoaded = NO;
    NSString *urlString = [NSString stringWithFormat:@"%@/completerun.php?deviceid=%@&run_id=%@",urlPrefix,deviceid,run_id];
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    [request release];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [[ret JSONValue] retain];
    
    if([retJSON objectForKey:@"success"]){
        dataLoaded = YES;
    }else {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Run Ended\nYou cannot add an order to a run that has already ended" waitUntilDone:NO];
        dataLoaded = NO;
    }
    return dataLoaded;

}
-(BOOL)leaverun:(NSString *)deviceid runID:(NSString *)run_id
{
    BOOL dataLoaded = NO;
    NSString *urlString = [NSString stringWithFormat:@"%@/leaverun.php?deviceid=%@&run_id=%@",urlPrefix,deviceid,run_id];
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    [request release];
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [[ret JSONValue] retain];
    
    if([retJSON objectForKey:@"success"]){
        dataLoaded = YES;
    }else {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Could not connect to server" waitUntilDone:NO];
        dataLoaded = NO;
    }
    return dataLoaded;
    
}
-(BOOL)deleteOrder:(NSString *)order_id
{
    BOOL dataLoaded = NO;
    NSString *urlString = [NSString stringWithFormat:@"%@/deleteOrder.php?order_id=%i",urlPrefix,[order_id intValue]];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    [request release];
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Return:%@",ret);
#endif
    NSDictionary *retJSON = [[ret JSONValue] retain];
    if([retJSON objectForKey:@"success"]){
        dataLoaded = YES;
    }else {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Could not connect to server" waitUntilDone:NO];
        dataLoaded = NO;
    }
    return dataLoaded;

}
-(NSDictionary *)getFacebookUsersOfApp
{
    NSDictionary *fb = [[NSDictionary alloc]init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/Facebook/getFacebookUsersOfApp.php",urlPrefix];
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    [request release];
    #if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
    #endif
    
    NSDictionary *retJSON = [[ret JSONValue] retain];
    if(retJSON != NULL){
        fb = retJSON;
    }else {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Could not connect to server" waitUntilDone:NO];
    }
    return fb;
}

-(BOOL)purchaseApp
{
    BOOL dataLoaded = NO;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/userPurchase.php?deviceid=%@",urlPrefix,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    [request release];
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [[ret JSONValue] retain];
    if(retJSON != NULL){
        [[Order sharedOrder] setOrder:[NSMutableDictionary dictionaryWithDictionary:retJSON]];        
        dataLoaded = YES;
    }else {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Could not connect to server" waitUntilDone:NO];
        dataLoaded = NO;
    }
    return dataLoaded;

}
#pragma mark -
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        NSString *currentVersion = @"1_0";
        urlPrefix = [@"http://dev.javadash.com/JavaDash/php" retain];
        //urlPrefix = [[NSString stringWithFormat:@"http://javadash.com/app/%@/JavaDash/php",currentVersion] retain];
        NSLog(@"urlPrefix %@",urlPrefix);
    }
    
    return self;
}


+ (DataService *)sharedDataService {
    @synchronized(self) {
        if (sharedDataService == nil) {
            sharedDataService = [[super allocWithZone:NULL] init];
            // [[self alloc] init]; // assignment not done here
        }
    }
    return sharedDataService;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        return [[self sharedDataService] retain];
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
