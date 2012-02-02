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
@implementation DataService

//use to quickly turn off NSLogs
#define IN_TESTING 0
#define TIMEOUT_SECONDS    60

/*Use this class to connect to their webservices.
 
 Docs Here:
 http://www.onlysimchas.com/v4/m/
 
 */

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
/*Login [login]

username - full email address
password - password
index.cfm/fuseaction:login/username:foo@bar.com/password:12345
Different responses
Success (auth must be provided as params key/value for each secure request, by default it's set in a cookie, so you might not have to send!)
         {"USERID":100004,"MESSAGE":"User 'Dov Katz successfully logged in.","NAME":"Dov Katz","SUBSTATUS":"LOGGED_IN","STATUS":"SUCCESS","AUTH":"CFID=32627748&CFTOKEN=b768c128c6117812-BBAC2177-2219-8090-6E61330ADBFDDA45"}
         Failure types:
         {"MESSAGE":"Login failed because your username(foo@bar.com) was not found as a login in our database.","SUBSTATUS":"USER_NOT_FOUND","STATUS":"ERROR"}
         {"MESSAGE":"Login failed because your password was incorrect.","SUBSTATUS":"INCORRECT_PASSWORD","STATUS":"ERROR"}
         {"USERID":119608,"MESSAGE":"Login failed because your account is suspended. Please contact support.","NAME":"john doe","SUBSTATUS":"ACCOUNT_SUSPENDED","STATUS":"ERROR"}
         {"USERID":100004,"MESSAGE":"Login incomplete. Please Activate Account","NAME":"Dov Katz","SUBSTATUS":"ACCOUNT_PENDING","STATUS":"ERRROR"}
*/
-(BOOL)loginWithUserName:(NSString*)user password:(NSString*)password{
    BOOL loginSuccess = NO;
    
    NSString *action = @"fuseaction:login";
    NSString *params = [NSString stringWithFormat:@"/username:%@/password:%@",[user stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
   
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
    if([[retJSON objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]){
        //login succeed, cache our variables
        userName = [[retJSON objectForKey:@"NAME"] retain];
        userID = [[retJSON objectForKey:@"USERID"] retain];
        authToken = [[retJSON objectForKey:@"AUTH"] retain];
        
        [self saveAuthUserName:userName withUserID:userID andAuthToken:authToken];
        
        loginSuccess = YES;
    }else {
        //failed for some reason
        NSString *errorMessage = [retJSON objectForKey:@"MESSAGE"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        loginSuccess = NO;
    }
    return loginSuccess;
}

-(BOOL)signupWithUserName:(NSString *)username 
                 password:(NSString *)pass 
          retypedPassword:(NSString *)pass2 
             emailAddress:(NSString *)email 
     didAgreeToMembership:(BOOL)agreeMembership 
            getNewsletter:(BOOL) newsletter
{
    #if IN_TESTING
    NSLog(@"username %@",username);
     NSLog(@"pass %@",pass);
     NSLog(@"pass2 %@",pass2);
     NSLog(@"email %@",email);
     NSLog(@"agreeMembership %d",agreeMembership);
    NSLog(@"newsletter %d",newsletter);
    #endif
    
    //Make sure all values are filled out
    if ([username isEqualToString:@""] ||
        [pass isEqualToString:@""] ||
        [pass2 isEqualToString:@""] ||
        [email isEqualToString:@""]) 
    {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Please check all fields" waitUntilDone:NO];
        return NO;
    }
    //Make sure passwords match
    if(![pass isEqualToString:pass2])
    {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Passwords do not match" waitUntilDone:NO];
        return NO;
    }
    
    //Check if agreement button is checked
    if(!agreeMembership)
    {
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:@"Please read the Membership Agreement and select the check box" waitUntilDone:NO];
        return NO;
    }
    
    
    return YES;
}
-(BOOL)checkIfLoggedIn
{
    BOOL success;
    NSString *action = @"fuseaction:ping";
    NSString *urlString = [NSString stringWithFormat:@"%@%@",urlPrefix,action];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [ret JSONValue];
    if([[retJSON objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"])
    {
        if([[retJSON objectForKey:@"MESSAGE"] isEqualToString:@"You do not have an active session at this time."])
            success = NO;
        else
            success = YES;
    }
    else
    {
        success = NO;
    }
    return success;

}
-(void)saveLogin:(NSDictionary *)data
{
    [[NSUserDefaults standardUserDefaults] setValue:[data objectForKey:@"username"] forKey:@"username"];
     [[NSUserDefaults standardUserDefaults] setValue:[data objectForKey:@"password"] forKey:@"password"];
    
    BOOL isSaved = [[data objectForKey:@"isSaved"]boolValue];
     [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:isSaved] forKey:@"isSaved"];
}
-(NSDictionary *)getLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *login = [[NSDictionary alloc]initWithObjectsAndKeys:
    [defaults valueForKey:@"username"],@"username",
    [defaults valueForKey:@"password"],@"password",
    [defaults valueForKey:@"isSaved"],@"isSaved",
    nil];
    
    return login;
}
-(void)saveAuthUserName:(NSString *)u withUserID:(NSString *)_id andAuthToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setValue:u forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setValue:_id forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"AuthToken"];
}
-(NSDictionary *)getAuthInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *auth_dict = [[NSDictionary alloc]initWithObjectsAndKeys:
                           [defaults valueForKey:@"userName"],@"userName",
                           [defaults valueForKey:@"userID"],@"userID",
                           [defaults valueForKey:@"AuthToken"],@"AuthToken",
                           nil];
    
    return auth_dict;
}
#pragma mark

#pragma mark Categories
-(NSDictionary *)getSimchaCategories
{
    
    NSString *action = @"fuseaction:simcha.types";
    NSString *urlString = [NSString stringWithFormat:@"%@%@",urlPrefix,action];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [ret JSONValue];
    if([[retJSON objectForKey:@"message"] isEqualToString:@""])
        return retJSON;
    else
    {
        NSString *errorMessage = [retJSON objectForKey:@"message"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        return NULL;
    }
    
}

-(NSDictionary *)getSimchaTypes
{

    NSString *action = @"fuseaction:simcha.types.covers";
    NSString *urlString = [NSString stringWithFormat:@"%@%@",urlPrefix,action];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [ret JSONValue];
    if([[retJSON objectForKey:@"message"] isEqualToString:@""])
        return retJSON;
    else
    {
        NSString *errorMessage = [retJSON objectForKey:@"message"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        return NULL;
    }
    
}
-(NSDictionary *)getSimchaList:(NSString *)name atStartRow:(int)s
{
    NSString *action = @"fuseaction:simcha.list/";
    NSString *params = [NSString stringWithFormat:@"type:%@/s:%i",[name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],s];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [ret JSONValue];
    if([[retJSON objectForKey:@"message"] isEqualToString:@""])
        return retJSON;
    else
    {
        NSString *errorMessage = [retJSON objectForKey:@"message"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        return NULL;
    }

}
-(NSDictionary *)getSimchaDetails:(int )simchaid
{
    NSString *action = @"fuseaction:simcha.get/";
    NSString *params = [NSString stringWithFormat:@"simchaid:%i/",simchaid];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [ret JSONValue];
    if([[retJSON objectForKey:@"message"] isEqualToString:@""])
        return retJSON;
    else
    {
        NSString *errorMessage = [retJSON objectForKey:@"message"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        return NULL;
    }

}

-(NSDictionary *)getSimchaMessages:(int )simchaid maxRows:(int )m startRow:(int )s
{
    NSString *action = @"fuseaction:simcha.messages/";
    NSString *params = [NSString stringWithFormat:@"simchaid:%i/m:%i/s:%i",simchaid,m,s];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [ret JSONValue];
    if([[retJSON objectForKey:@"message"] isEqualToString:@""])
        return retJSON;
    else
    {
        NSString *errorMessage = [retJSON objectForKey:@"message"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        return NULL;
    }

}
#pragma mark -
#pragma mark Search

-(NSDictionary *)doSearchAtstartRow:(int )sr withSearchTerm:(NSString *)term
{
    NSString *action = @"fuseaction:simcha.search/";
    
    NSString *params = [NSString stringWithFormat:@"t:/sd:/ed:/ct:/c:/s:/st:/global_search:%@/tag:/sr:%i",[term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        sr];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:60];
    [request startSynchronous];
    NSString *ret = [request responseString];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [ret JSONValue];
    if([[retJSON objectForKey:@"message"] isEqualToString:@""])
        return retJSON;
    else
    {
        NSString *errorMessage = [retJSON objectForKey:@"message"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        return NULL;
    }

}
#pragma mark - 
#pragma mark Comments
-(BOOL)addComment:(int )simchaID message:(NSString *)m
{
    BOOL commentSuccess;
    NSString *action = @"fuseaction:secure.simcha.guestbook.post/";
    NSString *params = [NSString stringWithFormat:@"/simchaid:%i/message:%@",simchaID,[m stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
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
    if([[retJSON objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]){
        //login succeed, cache our variables
        commentSuccess = YES;
    }else {
        //failed for some reason
        NSString *errorMessage = [retJSON objectForKey:@"MESSAGE"];
        //[self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        commentSuccess = NO;
    }
    return commentSuccess;
}
-(BOOL)deleteComment:(int )simchaID messageId:(int )messageid
{
    BOOL commentSuccess;
    NSString *action = @"fuseaction:secure.simcha.guestbook.delete/";
    NSString *params = [NSString stringWithFormat:@"/simchaid:%i/messageid:%i",simchaID,messageid];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
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
    if([[retJSON objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]){
        commentSuccess = YES;
    }else {
        //failed for some reason
        NSString *errorMessage = [retJSON objectForKey:@"MESSAGE"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        commentSuccess = NO;
    }
    return commentSuccess;
}

#pragma mark - 
#pragma mark View Gallery
-(NSDictionary *)getPhotos:(int )simchaid
{
    NSString *action = @"fuseaction:simcha.photos/";
    NSString *params = [NSString stringWithFormat:@"simchaid:%i/",simchaid];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest  *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    
#if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
#endif
    NSDictionary *retJSON = [ret JSONValue];
    if([[retJSON objectForKey:@"message"] isEqualToString:@""])
        return retJSON;
    else
    {
        NSString *errorMessage = [retJSON objectForKey:@"message"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        return NULL;
    }

}
-(BOOL)PhotoUpload:(int )galleryID withPhoto:(UIImage *)photo
{
    BOOL uploadSuccess;
    NSData *imageData = UIImageJPEGRepresentation(photo, 90);
	// setting up the URL to post to
    
    NSString *action = @"fuseaction:secure.photo.upload/";
    NSString *params = [NSString stringWithFormat:@"galleryid:%i/",galleryID];
	NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
    
    NSURL *url = [NSURL URLWithString: urlString];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    int ts = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%i.jpg",ts];
    [request addPostValue:fileName forKey:@"name"];
    
    // Upload an image
    [request setData:imageData withFileName:fileName andContentType:@"image/jpeg" forKey:@"filedata"];
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request startSynchronous];
    NSString *ret = [request responseString];
    
    #if IN_TESTING
    NSLog(@"urlString %@",urlString);
    NSLog(@"Login Return:%@",ret);
    #endif
    NSDictionary *retJSON = [[ret JSONValue] retain];
    if([[retJSON objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]){
        uploadSuccess = YES;
    }else {
        //failed for some reason
        NSString *errorMessage = [retJSON objectForKey:@"MESSAGE"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        uploadSuccess = NO;
    }
    return uploadSuccess;
}
#pragma mark - 
#pragma mark Favorite
-(BOOL)addFavorite:(int )simchaID
{
    BOOL commentSuccess;
    NSString *action = @"fuseaction:secure.favorites.add/";
    NSString *params = [NSString stringWithFormat:@"simchaid:%i",simchaID];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
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
    if([[retJSON objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]){
        commentSuccess = YES;
    }else {
        //failed for some reason
        NSString *errorMessage = [retJSON objectForKey:@"MESSAGE"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        commentSuccess = NO;
    }
    return commentSuccess;
}
-(BOOL)deleteFavorite:(int )simchaID
{
    BOOL commentSuccess;
    NSString *action = @"fuseaction:secure.favorites.delete/";
    NSString *params = [NSString stringWithFormat:@"simchaid:%i",simchaID];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",urlPrefix,action,params];
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
    if([[retJSON objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]){
        commentSuccess = YES;
    }else {
        //failed for some reason
        NSString *errorMessage = [retJSON objectForKey:@"MESSAGE"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        commentSuccess = NO;
    }
    return commentSuccess;
}
-(NSDictionary *)getFavorites
{
    NSDictionary *favs;
    NSString *action = @"fuseaction:secure.favorites.list/";
    NSString *urlString = [NSString stringWithFormat:@"%@%@",urlPrefix,action];
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
    if([[retJSON objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]){
        favs = retJSON;
    }else {
        //failed for some reason
        NSString *errorMessage = [retJSON objectForKey:@"MESSAGE"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        favs = NULL;
    }
    return favs;

}
#pragma mark -
#pragma mark GetMySimchas
-(NSDictionary *)getMySimchas
{
    NSDictionary *mysimchas;
    NSString *action = @"fuseaction:secure.simcha.list/";
    NSString *urlString = [NSString stringWithFormat:@"%@%@",urlPrefix,action];
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
    if([[retJSON objectForKey:@"status"] isEqualToString:@""]){
        mysimchas = retJSON;
    }else {
        //failed for some reason
        NSString *errorMessage = [retJSON objectForKey:@"MESSAGE"];
        [self performSelectorOnMainThread:@selector(popUpWithMessage:) withObject:errorMessage waitUntilDone:NO];
        mysimchas = NULL;
    }
    return mysimchas;
    
}
#pragma mark -
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        urlPrefix = [@"http://www.onlysimchas.com/v4/m/index.cfm/" retain];
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
