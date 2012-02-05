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
@implementation DataService

//use to quickly turn off NSLogs
#define IN_TESTING 0
#define TIMEOUT_SECONDS    60

/*Use this class to connect to their webservices.
 
 Docs Here:
 http://www.onlysimchas.com/v4/m/
 
 */
NSString * const baseDomain = @"http://dev.javadash.com/JavaDash/php";
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
    int ts = [[NSDate date] timeIntervalSince1970];
 
    NSString *urlString = [NSString stringWithFormat:@"%@/getorders.php?deviceid=%@&ts=%i",urlPrefix,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],ts];
   
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    
    #if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
    #endif
    NSDictionary *retJSON = [[ret JSONValue] retain];
    if(retJSON != NULL){
        [[Order sharedOrder] setOrder:retJSON];      
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
        urlPrefix = [@"http://dev.javadash.com/JavaDash/php/" retain];
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
