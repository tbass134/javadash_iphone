//
//  FacebookViewController.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 10/16/11.
//  Copyright (c) 2011 Dark Bear Interactive. All rights reserved.
//

#import "FacebookViewController.h"
#import "CoffeeRunSampleAppDelegate.h"
#import "Utils.h"
#import "FriendsInfo.h"
#import "DataService.h"
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

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.navigationController.view addSubview:HUD];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    [HUD show:YES];
    NSDictionary *allFBUsers = [[DataService sharedDataService]getFacebookUsersOfApp];
    NSLog(@"allFBUsers %@",allFBUsers);
    if(![allFBUsers objectForKey:@"success"])
    {
        [HUD hide:YES];
        loading_txt.hidden = YES;
        for(int i =0;i<[friends count];i++)
        {
            
            NSDictionary *friend = [friends objectAtIndex:i];
            //NSLog(@"id %@",[friend objectForKey:@"id"]);
            int fbID = [[friend objectForKey:@"id"]intValue];
            for(int j=0;j<[allFBUsers count];j++)
            {
                NSDictionary *jdFriend = [allFBUsers objectAtIndex:j];
                //NSLog(@"jdFriend %@",jdFriend);
                int jdFriendID = [[jdFriend objectForKey:@"fb_id"]intValue];
                
                //NSLog(@"fbID %i",fbID);
                //NSLog(@"jdFriendID %i",jdFriendID);
                if(fbID == jdFriendID)
                {
                    printf("FOund Frined");
                    [users addObject:jdFriend];
                    break;
                }
            }
        }
        [self loadFriendsList];
    }
    else {
         [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Users Found" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
        
}
-(void)loadFriendsList
{
    self.table_view.hidden = NO;
    urlArray = [[NSMutableArray alloc]init];
    images = [[NSMutableArray alloc] init];
    names = [[NSMutableArray alloc] init];
    
    if([users count]>0)
    {
        //followAll_btn.enabled = YES;
        for(int i=0;i<[users count];i++){
            [images addObject:[NSNull null]];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newImageRetrieved) name:@"newImage" object:nil];
        
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,75)];
        v.backgroundColor = [UIColor clearColor];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectInset(v.bounds, 20, 0)];
        lab.text = @"These are your Facebook friends who are already using Java Dash. Add them to share coffee orders";
        lab.numberOfLines = 3;
        lab.font = [UIFont boldSystemFontOfSize:12];
        lab.textColor = [UIColor grayColor];
        lab.backgroundColor = [UIColor clearColor];
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
    printf("facebookDidLogin");
    UIAppDelegate.fb_tag = @"me/friends";
    [UIAppDelegate.facebook requestWithGraphPath:@"me/friends" andDelegate:UIAppDelegate];
    
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
    return [users count];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    NSDictionary *friendDict = [users objectAtIndex:indexPath.row];
    NSLog(@"friendDict %@",friendDict);

    
    UIImage *bg = [UIImage imageNamed:@"wood_btn.png"]; 
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0,0.0, 70.0, 40.0)];
    [button setBackgroundImage:bg forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    if([_friends checkFriendAdded:friendDict])
    {
        [button setTitle:@"Following" forState:UIControlStateNormal];
        button.enabled = NO;
        
    }
    else
    {
        [button setTitle:@"Follow" forState:UIControlStateNormal];
        button.enabled = YES;

    }
    button.tag = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];

    cell.accessoryView = button;

    
	cell.textLabel.text = [[users objectAtIndex:indexPath.row]objectForKey:@"name"];
	int i = indexPath.row;
	
	if([images objectAtIndex:i] != [NSNull null]) cell.imageView.image = [images objectAtIndex:i];
	else{
		
		int index = i % [users count];
        NSString *img_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[[users objectAtIndex:index]objectForKey:@"fb_id"]];
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
			
			int i = [self.table_view indexPathForCell:cell].row % [users count];
            NSString *img_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[[users objectAtIndex:i]objectForKey:@"fb_id"]];
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
    
    NSString *img_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[[users objectAtIndex:button.tag]objectForKey:@"fb_id"]];
    UIImage *image = [[TKImageCenter sharedImageCenter] imageAtURL:img_url queueIfNeeded:NO];

    NSDictionary *friendDict = [users objectAtIndex:button.tag];
    [self addUserToList:friendDict withImage:image];
        
    
}
-(void)addUserToList:(NSDictionary *)user withImage:(UIImage *)image
{
    NSData *image_data;
    if(image != nil)
        image_data = UIImageJPEGRepresentation(image,90);
    else
        image_data = nil;
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@" "] invertedSet];
    
    NSString *fname;
    NSString *lname;
    
    if ([[user objectForKey:@"name"] rangeOfCharacterFromSet:set].location != NSNotFound) {
    
        printf("found space");
        //Split the names by the space for the first and last name
        NSArray *name = [[user objectForKey:@"name"] componentsSeparatedByString:@" "];
        if([name count]>1)
        {
            fname = [name objectAtIndex:0];
            lname = [name objectAtIndex:1];
        }
        else
        {
            fname = [user objectForKey:@"name"];
            lname = @"";
        }
    }
    else
    {
        fname = [user objectForKey:@"name"];
        lname = @"";
    }
    
        NSDictionary *user_dict = [[NSDictionary alloc]initWithObjectsAndKeys:
                                   fname,@"FIRSTNAME",
                                   lname,@"LASTNAME",
                                   @"",@"NUMBER",
                                   [user objectForKey:@"email"],@"EMAIL",
                                   image_data,@"IMAGE",
                                   [user objectForKey:@"deviceid"],@"TOKEN",
                                   nil];
	
	
    if(![_friends checkforFriendAdded:user_dict])
	{
		if([_friends insertFriendData:user_dict])
		{
            if(!followAll_clicked)
			[Utils showAlert:@"Added" withMessage:[NSString stringWithFormat:@"%@ %@ has been added to your friends list",[user_dict objectForKey:@"FIRSTNAME"],[user_dict objectForKey:@"LASTNAME"]] inView:self.view];
        }
        [self.table_view reloadData];
	}
	else
		[Utils showAlert:nil withMessage:@"User has already been added to friends list" inView:self.view];	

    
    followAll_clicked = NO;

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    _friends = [[FriendsInfo alloc]init];
    _friends.managedObjectContext = self.managedObjectContext;
    users = [[NSMutableArray alloc]init];
    self.table_view.hidden = YES;
    
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
    loading_txt.hidden = NO;
    
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

    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [users release];
    
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
