//
//  FacebookViewController.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 10/16/11.
//  Copyright (c) 2011 Dark Bear Interactive. All rights reserved.
//

#import "FacebookViewController.h"
#import "Constants.h"
#import "CoffeeRunSampleAppDelegate.h"
#import "URLConnection.h"
#import "Utils.h"
#import "FriendsInfo.h"
#define UIAppDelegate \
((CoffeeRunSampleAppDelegate *)[UIApplication sharedApplication].delegate)
@implementation FacebookViewController
@synthesize table_view;
//CoreData
@synthesize fetchedResultsController, managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(facebookDidLogin:) 
                                                     name:@"facebookDidLogin"
                                                   object:nil];

    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getFriendsList) 
                                                     name:@"getFriendsList"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fbFailed) 
                                                     name:@"fbFailed"
                                                   object:nil];
        
        
        cancel_btn = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
        //followAll_btn = [[UIBarButtonItem alloc]initWithTitle:@"Follow all" style:UIBarButtonItemStyleDone target:self action:@selector(followAll)];
        
        self.navigationItem.rightBarButtonItem = cancel_btn;
        
        
        if([UIAppDelegate.facebook isSessionValid])
        {
            //self.navigationItem.rightBarButtonItem = followAll_btn;
            UIAppDelegate.fb_tag = @"me/friends";
            [UIAppDelegate.facebook requestWithGraphPath:@"me/friends" andDelegate:UIAppDelegate];
        }
        else
        {
            [self login];
        }

}
    return self;
}
-(void)goBack
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
-(void)followAll
{
    /*
    followAll_clicked = YES;   
    if([fb_array count]>0)
    {
        for(int i=0;i<[fb_array count];i++)
        {
            NSDictionary *friendDict = [fb_array objectAtIndex:i];
            UIImage *image = [[TKImageCenter sharedImageCenter] imageAtURL:[[fb_array objectAtIndex:i]objectForKey:@"url"] queueIfNeeded:NO];
            for(id user in users_dict)
            {  
                if([[user objectForKey:@"fb_id"] isEqualToString:[friendDict objectForKey:@"id"]])
                {
                    //Save the data
                     [self addUserToList:user withImage:image];
                    break; 
                }
            }
        }
    }
     */
}

-(void)loadFromServer
{
    //Get all the friends device ID's
    friends = [[FriendsInfo alloc]init];
	friends.managedObjectContext = self.managedObjectContext;	
	NSArray *friends_array = [friends getAllFriends];    
    
    if([friends_array count] == 0)
    {
        return;
    }
    NSMutableArray *device_id_array = [[NSMutableArray alloc]init];

    for(int i=0;i<[friends_array count];i++)
    {
        [device_id_array addObject:[[friends_array objectAtIndex:i]valueForKey:@"device_id"]];
    }
    
	
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Facebook/getFacebookUsersOfApp.php",baseDomain]]
														   cachePolicy:NSURLCacheStorageNotAllowed
													   timeoutInterval:60.0];
    
	URLConnection *conn = [[URLConnection alloc]init];
    
    [request setHTTPMethod:@"POST"];
	NSString *post_str = [NSString stringWithFormat:@"device_tokens=%@",[device_id_array componentsJoinedByString:@","]];
    
    NSLog(@"post_str %@",post_str);
    
	[request setHTTPBody:[post_str dataUsingEncoding:NSUTF8StringEncoding]]; 
	conn.tag =@"getFBUsers";
	[conn setDelegate:self];
	[conn initWithRequest:request];
}
- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data
{
    NSLog(@"data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    NSString * json_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SBJSON *parser = [[SBJSON alloc] init];
    users_dict = [[parser objectWithString:json_str error:nil]retain];
    NSLog(@"users_dict %@",users_dict);
    
    [self loadFriendsList];
    [parser release];
    [json_str release];
    
}
-(void)loadFriendsList
{
    self.table_view.hidden = NO;
    urlArray = [[NSMutableArray alloc]init];
    images = [[NSMutableArray alloc] init];
    names = [[NSMutableArray alloc] init];
    
    if([users_dict count]>0)
    {
        //followAll_btn.enabled = YES;
        for(int i=0;i<[users_dict count];i++){
            [images addObject:[NSNull null]];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newImageRetrieved) name:@"newImage" object:nil];
        
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,75)];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectInset(v.bounds, 20, 0)];
        lab.text = @"These are your Facebook friends who are already using Java Dash. Add them to share coffee orders";
        lab.numberOfLines = 3;
        lab.font = [UIFont boldSystemFontOfSize:12];
        lab.textColor = [UIColor grayColor];
        [v addSubview:lab];
        [lab release];
        
        self.table_view.tableHeaderView = v;
        [v release];
        
        [self.table_view reloadData];
    }
    else
    {
       
        
        if(!noUsers)
        {
            printf("no users found");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Users Found" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];
            
            //followAll_btn.enabled = NO;
        }
             noUsers = YES;
    }
}
#pragma mark - Facebook
- (IBAction)fbButtonClick:(id)sender {
    
           
}

-(void)facebookDidLogin:(NSNotification *) notification
{
    [self fbDidLogin];
    
}
- (void)fbDidLogin {
}
- (IBAction)getUserInfo:(id)sender {
    UIAppDelegate.fb_tag = @"me/friends";
    [UIAppDelegate.facebook requestWithGraphPath:@"me/friends" andDelegate:UIAppDelegate];
}
-(void)getFriendsList
{
    if(!dbDataLoaded)
    {
        printf("getFriendsList");
        friends = [UIAppDelegate.fb_friends retain];
        [self loadFromServer];
        dbDataLoaded = YES;
    }
}

- (void)login {
    [UIAppDelegate.facebook authorize:UIAppDelegate.permissions];
}

- (void)logout {
    [UIAppDelegate.facebook logout:UIAppDelegate];
}
-(void)fbFailed {
    [Utils showAlert:@"Could Not Connect To Facebook" withMessage:nil inView:self.view];
}

#pragma mark - Table View Delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [users_dict count];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Follow" forState:UIControlStateNormal];
    CGRect frame = CGRectMake(0.0, 0.0, 70, 40);
    button.frame = frame; 
    button.tag = indexPath.row;
    [button addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;

    
	cell.textLabel.text = [[users_dict objectAtIndex:indexPath.row]objectForKey:@"name"];
	int i = indexPath.row;
	
	if([images objectAtIndex:i] != [NSNull null]) cell.imageView.image = [images objectAtIndex:i];
	else{
		
		int index = i % [users_dict count];
        NSString *img_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[[users_dict objectAtIndex:index]objectForKey:@"fb_id"]];
        UIImage *image = [[TKImageCenter sharedImageCenter] imageAtURL:img_url queueIfNeeded:YES];
		
		if(image != nil){
			[images replaceObjectAtIndex:i withObject:image];
			cell.imageView.image = image;
		}else{
			cell.imageView.image = nil;
		}
		
	}
    
  
    
    return cell;
}

- (void) newImageRetrieved{
    
	for (UITableViewCell * cell in [self.table_view visibleCells]) {
		if(cell.imageView.image == nil){
			
			int i = [self.table_view indexPathForCell:cell].row % [users_dict count];
            NSString *img_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[[users_dict objectAtIndex:i]objectForKey:@"fb_id"]];
            UIImage *image = [[TKImageCenter sharedImageCenter] imageAtURL:img_url queueIfNeeded:YES];
            
			if(image != nil){
				[images replaceObjectAtIndex:i withObject:image];
				cell.imageView.image = image;
				[cell setNeedsLayout];
			}
            
		}
	}
}

-(void)addFriend:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    
    NSString *img_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[[users_dict objectAtIndex:button.tag]objectForKey:@"fb_id"]];
    UIImage *image = [[TKImageCenter sharedImageCenter] imageAtURL:img_url queueIfNeeded:NO];

    NSDictionary *friendDict = [users_dict objectAtIndex:button.tag];
    [self addUserToList:friendDict withImage:image];
        
    
}
-(void)addUserToList:(NSDictionary *)user withImage:(UIImage *)image
{
    NSData *image_data;
    if(image != nil)
        image_data = UIImageJPEGRepresentation(image,90);
    else
        image_data = nil;
    
    //Split the names by the space for the first and last name
    NSArray *name = [[user objectForKey:@"name"] componentsSeparatedByString: @" "];
    
    NSDictionary *user_dict = [[NSDictionary alloc]initWithObjectsAndKeys:
                               [name objectAtIndex:0],@"FIRSTNAME",
                               [name objectAtIndex:1],@"LASTNAME",
                               @"",@"NUMBER",
                               [user objectForKey:@"email"],@"EMAIL",
                               image_data,@"IMAGE",
                               [user objectForKey:@"deviceid"],@"TOKEN",
                               nil];
    
   
    
	FriendsInfo *_friends = [[FriendsInfo alloc]init];
	_friends.managedObjectContext = self.managedObjectContext;
    if(![_friends checkforFriendAdded:user_dict])
	{
		if([_friends insertFriendData:user_dict])
		{
            if(!followAll_clicked)
			[Utils showAlert:@"Added" withMessage:[NSString stringWithFormat:@"%@ %@ has been added to your friends list",[user_dict objectForKey:@"FIRSTNAME"],[user_dict objectForKey:@"LASTNAME"]] inView:self.view];
        }
	}
	else
		[Utils showAlert:nil withMessage:@"User has already been added to friends list" inView:self.view];	
    
    [_friends release];
    
    followAll_clicked = NO;

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.table_view.hidden = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [users_dict release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"facebookDidLogin"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"getFriendsList"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"fbFailed"];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)dealloc
{
    [super dealloc];
}

@end
