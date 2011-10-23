//
//  DBSignupViewController.m
//  DBSignup
//
//  Created by Davide Bettio on 7/4/11.
//  Copyright 2011 03081340121. All rights reserved.
//

#import "DBSignupViewController.h"
#import "Utils.h"
#import "Constants.h"
#import "URLConnection.h"
#import "CoffeeRunSampleAppDelegate.h"
#define UIAppDelegate \
((CoffeeRunSampleAppDelegate *)[UIApplication sharedApplication].delegate)

// Safe releases
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

#define FIELDS_COUNT            4
#define BIRTHDAY_FIELD_TAG      5
#define GENDER_FIELD_TAG        6
#define kAnimationDuration 0.5


@implementation DBSignupViewController

@synthesize nameTextField = nameTextField_;
@synthesize lastNameTextField = lastNameTextField_;
@synthesize emailTextField = emailTextField_;
@synthesize passwordTextField = passwordTextField_;
@synthesize phoneTextField = phoneTextField_;
@synthesize photoButton = photoButton_;
@synthesize termsTextView = termsTextView_;

@synthesize emailLabel = emailLabel_;
@synthesize sendemailLabel = sendemailLabel_;
@synthesize passwordLabel = passwordLabel_;
@synthesize genderLabel = genderLabel_;
@synthesize phoneLabel = phoneLabel_;

@synthesize enableEmail = enableEmail_;

@synthesize getContactInfoButton = getContactInfoButton_;

@synthesize keyboardToolbar = keyboardToolbar_;

@synthesize photo = photo_;

@synthesize delegate;

@synthesize gotoContactInfo;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFELY(nameTextField_);
    RELEASE_SAFELY(lastNameTextField_);
    RELEASE_SAFELY(emailTextField_);
    RELEASE_SAFELY(passwordTextField_);
    RELEASE_SAFELY(phoneTextField_);
    RELEASE_SAFELY(photoButton_);
    RELEASE_SAFELY(termsTextView_);
    
    RELEASE_SAFELY(emailLabel_);
    RELEASE_SAFELY(passwordLabel_);
    RELEASE_SAFELY(genderLabel_);
    RELEASE_SAFELY(phoneLabel_);
    
    RELEASE_SAFELY(keyboardToolbar_);

    RELEASE_SAFELY(photo_);
    RELEASE_SAFELY(getContactInfoButton_);
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getUserInfo) 
                                                 name:@"getUserInfo"
                                               object:nil];
    
    // Signup button
    signUp_btn = [[UIBarButtonItem alloc]initWithTitle:@"Update" style:UIBarButtonItemStyleDone target:self action:@selector(signup:)];
    signUp_btn.enabled = NO;
    
    cancel_btn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack)];
    
   if(gotoContactInfo)
   {
        self.navigationItem.rightBarButtonItem = signUp_btn;
       self.navigationItem.leftBarButtonItem =  cancel_btn;
        [self.view addSubview:contact]; 
        contact_back_btn.hidden = YES;
       
       
       CGRect nameOrigin = self.nameTextField.frame;
       nameOrigin.origin.y -=4;
       self.nameTextField.frame = nameOrigin;
       
       CGRect lastnameOrigin = self.lastNameTextField.frame;
       lastnameOrigin.origin.y-=4;
       self.lastNameTextField.frame = lastnameOrigin;
       
       
       CGRect emailOrigin = self.emailTextField.frame;
       emailOrigin.origin.y-=20;
       self.emailTextField.frame = emailOrigin;
       
       CGRect enableEmailOrigin = self.enableEmail.frame;
       enableEmailOrigin.origin.y-=20;
       self.enableEmail.frame = enableEmailOrigin;
      
       
       CGRect EmailLabelOrigin = self.emailLabel.frame;
       EmailLabelOrigin.origin.y-=20;
       self.emailLabel.frame = EmailLabelOrigin;
       
       
       CGRect sendEmailLabelOrigin = self.sendemailLabel.frame;
       sendEmailLabelOrigin.origin.y-=20;
       self.sendemailLabel.frame = sendEmailLabelOrigin;


    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
        contact_back_btn.hidden = NO;
        [self.view addSubview:page1]; 
    }
        [super viewDidLoad];
    
    
       
    // Keyboard toolbar
    if (self.keyboardToolbar == nil) {
        self.keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 38.0f)];
        self.keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
        
        UIBarButtonItem *previousBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"previous", @"")
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(previousField:)];
        
        UIBarButtonItem *nextBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"next", @"")
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(nextField:)];
        
        UIBarButtonItem *spaceBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
        
        UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", @"")
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(resignKeyboard:)];
        
        [self.keyboardToolbar setItems:[NSArray arrayWithObjects:previousBarItem, nextBarItem, spaceBarItem, doneBarItem, nil]];
        
        self.nameTextField.inputAccessoryView = self.keyboardToolbar;
        self.lastNameTextField.inputAccessoryView = self.keyboardToolbar;
        self.emailTextField.inputAccessoryView = self.keyboardToolbar;
        self.passwordTextField.inputAccessoryView = self.keyboardToolbar;
        self.phoneTextField.inputAccessoryView = self.keyboardToolbar;
        self.enableEmail.on = NO;
        self.enableEmail.enabled = NO;
        
        [previousBarItem release];
        [nextBarItem release];
        [spaceBarItem release];
        [doneBarItem release];
    }
    
    // Set localization
    self.nameTextField.placeholder = NSLocalizedString(@"first_name", @"");
    self.lastNameTextField.placeholder = NSLocalizedString(@"last_name", @"");
    self.emailLabel.text = [NSLocalizedString(@"email", @"") uppercaseString]; 
    self.passwordLabel.text = [NSLocalizedString(@"password", @"") uppercaseString];
    self.phoneLabel.text = [NSLocalizedString(@"phone", @"") uppercaseString];
    self.phoneTextField.placeholder = NSLocalizedString(@"optional", @"");
    self.termsTextView.text = NSLocalizedString(@"terms", @"");
    
    
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"] !=NULL)
        self.nameTextField.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"];
    
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"] !=NULL)
        self.lastNameTextField.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"];
    
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"EMAIL"] !=NULL)
        self.emailTextField.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"EMAIL"];
    
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"ENABLE_EMAIL"] !=NULL)
        self.enableEmail.on =  [[[NSUserDefaults standardUserDefaults]valueForKey:@"ENABLE_EMAIL"] boolValue];
        
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"PHONE"] !=NULL)
        self.phoneTextField.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"PHONE"];
    
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"PASS"] !=NULL)
        self.passwordTextField.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"PASS"];
    
    
     if([[NSUserDefaults standardUserDefaults]valueForKey:@"IMAGE"] !=NULL)
     {
         printf("Has image");
         NSData *imageData =[[NSUserDefaults standardUserDefaults]valueForKey:@"IMAGE"];
         self.photo = [[UIImage alloc] initWithData:imageData];
         [self.photoButton setImage:self.photo forState:UIControlStateNormal];
         
     }
}
-(void)viewDidAppear:(BOOL)animated
{
    if( (self.nameTextField.text != NULL && ![self.nameTextField.text isEqualToString:@""]) &&
       (self.lastNameTextField.text != NULL && ![self.lastNameTextField.text isEqualToString:@""]))
        signUp_btn.enabled = YES;
    else
        signUp_btn.enabled = NO;
    
    if(self.emailTextField.text != NULL && ![self.emailTextField.text isEqualToString:@""])
        self.enableEmail.enabled = YES;
    else
        self.enableEmail.enabled = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark View Buttons
//View 1
-(IBAction)gotoPage2:(id)sender
{
    printf("gotoPage2");
    
	[self performSelector:@selector(removeStep1) withObject:nil afterDelay:kAnimationDuration];
	CGRect tempOrigin = page2.frame;
	tempOrigin.origin.x=0;
	CGRect temp = page2.frame;
	temp.origin.x=320;
	page2.frame = temp;
	
	CGRect tempStep1 = page1.frame;
	tempStep1.origin.x=-320;
	[self.view addSubview:page2];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
    
	page2.frame = tempOrigin;
	page1.frame = tempStep1;
	[UIView commitAnimations];
    
}
-(void)removeStep1 {
	[page1 removeFromSuperview];
	
}

//View 2
-(IBAction)gotoPage3:(id)sender
{
    [self performSelector:@selector(removeStep2) withObject:nil afterDelay:kAnimationDuration];
	CGRect tempOrigin = page3.frame;
	tempOrigin.origin.x=0;
	CGRect temp = page3.frame;
	temp.origin.x=320;
	page3.frame = temp;
	
	CGRect tempStep1 = page2.frame;
	tempStep1.origin.x=-320;
	[self.view addSubview:page3];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	
	page3.frame = tempOrigin;
	page2.frame = tempStep1;
	[UIView commitAnimations];
}
-(void)removeStep2 {
	[page2 removeFromSuperview];
	
}
-(IBAction)goBack2:(id)sender
{
    printf("goBack2");
    [self performSelector:@selector(removeStep2) withObject:nil afterDelay:kAnimationDuration];
	
	CGRect tempOrigin = page2.frame;
	tempOrigin.origin.x=0;
	
	CGRect temp = page2.frame;
	temp.origin.x=320;
	
	CGRect tempStep1 = page1.frame;
	tempStep1.origin.x=0;
	[self.view addSubview:page1];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	
	page2.frame = temp;
	page1.frame = tempStep1;
	[UIView commitAnimations];

}

//View 3
-(IBAction)gotoPageContact:(id)sender
{
    self.navigationItem.rightBarButtonItem = signUp_btn;
    [self performSelector:@selector(removeStep3) withObject:nil afterDelay:kAnimationDuration];
	CGRect tempOrigin = contact.frame;
	tempOrigin.origin.x=0;
	CGRect temp = contact.frame;
	temp.origin.x=320;
	contact.frame = temp;
	
	CGRect tempStep1 = page3.frame;
	tempStep1.origin.x=-320;
	[self.view addSubview:contact];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	
	contact.frame = tempOrigin;
	page3.frame = tempStep1;
	[UIView commitAnimations];
}
-(void)removeStep3 {
	[page3 removeFromSuperview];
}
-(IBAction)goBack3:(id)sender
{
    printf("goBack3");
    [self performSelector:@selector(removeStep3) withObject:nil afterDelay:kAnimationDuration];
	
	CGRect tempOrigin = page3.frame;
	tempOrigin.origin.x=0;
	
	CGRect temp = page3.frame;
	temp.origin.x=320;
	
	CGRect tempStep1 = page2.frame;
	tempStep1.origin.x=0;
	[self.view addSubview:page2];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	
	page3.frame = temp;
	page2.frame = tempStep1;
	[UIView commitAnimations];
}



#pragma mark - IBActions

- (IBAction)choosePhoto:(id)sender
{
    UIActionSheet *choosePhotoActionSheet;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        choosePhotoActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose Photo", @"")
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"") 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Take Photo From Camera", @""), NSLocalizedString(@"Take Photo From Library", @""), nil];
    } else {
        choosePhotoActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose Photo", @"")
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"") 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Take Photo From Library", @""), nil];
    }
    
    [choosePhotoActionSheet showInView:self.view];
    [choosePhotoActionSheet release];
}
- (IBAction)getContactInfo:(id)sender
{
    printf("Get Contact");
    printf("getContactInfo");
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	[self presentModalViewController:picker animated:YES];
	[picker release];

}
-(IBAction)goBackContact:(id)sender
{
    printf("goBackContact");
    self.navigationItem.rightBarButtonItem = nil;
    [self performSelector:@selector(removeContact) withObject:nil afterDelay:kAnimationDuration];
	
	CGRect tempOrigin = contact.frame;
	tempOrigin.origin.x=0;
	
	CGRect temp = contact.frame;
	temp.origin.x=320;
	
	CGRect tempStep1 = page3.frame;
	tempStep1.origin.x=0;
	[self.view addSubview:page3];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	
	contact.frame = temp;
	page3.frame = tempStep1;
	[UIView commitAnimations];

}
-(void)removeContact {
	[contact removeFromSuperview];
}

#pragma mark - Others
-(IBAction)connectFacebook:(id)sender
{
    if([UIAppDelegate.facebook isSessionValid])
    {
        UIAppDelegate.fb_tag = @"me";
        [UIAppDelegate.facebook requestWithGraphPath:@"me" andDelegate:UIAppDelegate];
    }
    else
        [UIAppDelegate.facebook authorize:UIAppDelegate.permissions];
}
#pragma mark - FaceBook
-(void)getUserInfo
{
    NSLog(@"getUserInfo %@",UIAppDelegate.fb_me);
    NSString *firstName = [UIAppDelegate.fb_me objectForKey:@"first_name"];
    NSString *lastName = [UIAppDelegate.fb_me objectForKey:@"last_name"];
    
    NSURL *picture_url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[UIAppDelegate.fb_me objectForKey:@"id"]]];

	//Update contact info with FB data
	self.nameTextField.text = firstName;
	self.lastNameTextField.text = lastName;
    
    if( (self.nameTextField.text != NULL && ![self.nameTextField.text isEqualToString:@""]) &&
       (self.lastNameTextField.text != NULL && ![self.lastNameTextField.text isEqualToString:@""]))
        signUp_btn.enabled = YES;
    else
        signUp_btn.enabled = NO;
	
    self.enableEmail.enabled = NO;
    
    
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:picture_url
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:60.0];
    
    NSLog(@"request %@", [request URL]);
	URLConnection *conn = [[URLConnection alloc]init];
	conn.tag =@"getFBImage";
	[conn setDelegate:self];
	[conn initWithRequest:request];
    
    //Upload fb ID to server
    [self saveFBId];
}
-(void)saveFBId
{
    //Store this in a UserDefaults since we'll need it again
    NSString *fbid= [UIAppDelegate.fb_me objectForKey:@"id"];
    
    NSLog(@"fbid %@",fbid);
    return;
    [[NSUserDefaults standardUserDefaults]setValue:@"FB_ID" forKey:fbid];
    
    int ts = [[NSDate date] timeIntervalSince1970];
	NSString *userName = [NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FIRSTNAME"],[[NSUserDefaults standardUserDefaults]valueForKey:@"LASTNAME"]];
    NSString *email =[[NSUserDefaults standardUserDefaults]valueForKey:@"EMAIL"];
    
    BOOL enable_email = [[[NSUserDefaults standardUserDefaults]valueForKey:@"ENABLE_EMAIL"]boolValue];
    
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/saveFBUserInfo.php?deviceid=%@&name=%@&email=%@&enable_email=%d&platform=%@&fb=%@&ts=%i",baseDomain,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],[Utils urlencode:userName],email,enable_email,@"IOS",fbid, ts]]
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:60.0];
    
    NSLog(@"request %@", [request URL]);
	URLConnection *conn = [[URLConnection alloc]init];
	conn.tag =@"saveFB";
	[conn setDelegate:self];
	[conn initWithRequest:request];
}
-(void)signup:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];

    if(self.nameTextField.text != NULL && ![self.nameTextField.text isEqualToString:@""])
		[[NSUserDefaults standardUserDefaults] setValue:self.nameTextField.text forKey:@"FIRSTNAME"];
    
	if(self.lastNameTextField.text != NULL && ![self.lastNameTextField.text isEqualToString:@""])
		[[NSUserDefaults standardUserDefaults] setValue:self.lastNameTextField.text forKey:@"LASTNAME"];
	
	if(self.emailTextField.text != NULL && ![self.emailTextField.text isEqualToString:@""])
    {
        
		[[NSUserDefaults standardUserDefaults] setValue:self.emailTextField.text forKey:@"EMAIL"];
        NSLog(@"self.enableEmail.on %d",self.enableEmail.on);
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.enableEmail.on] forKey:@"ENABLE_EMAIL"];
	}
    
	
	if(self.photo != NULL)
	{
		NSData *image_data = UIImageJPEGRepresentation(self.photo,90);
		[[NSUserDefaults standardUserDefaults] setObject:image_data forKey:@"IMAGE"];
	}
    
    NSString *userName = [NSString stringWithFormat:@"%@ %@",self.nameTextField.text,self.lastNameTextField.text];
     int ts = [[NSDate date] timeIntervalSince1970];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/updateUserInfo.php?deviceid=%@&name=%@&email=%@&enable_email=%d&ts=%i",baseDomain,[[NSUserDefaults standardUserDefaults]valueForKey:@"_UALastDeviceToken"],[Utils urlencode:userName],self.emailTextField.text,self.enableEmail.on,ts]]
														   cachePolicy:NSURLRequestReturnCacheDataElseLoad
													   timeoutInterval:60.0];
    
    NSLog(@"url %@", [request URL]);
	URLConnection *conn = [[URLConnection alloc]init];
	conn.tag =@"GetOrders";
	[conn setDelegate:self];
	[conn initWithRequest:request];

    [self resignKeyboard:nil];    
}
-(void)goBack
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data
{
    if([tag isEqualToString:@"saveFB"])
    {
        
    }
    else if([tag isEqualToString:@"getFBImage"])
    {
        UIImage* _image = [UIImage imageWithData: data];
        CGSize sz = CGSizeMake(80, 80);
        self.photo = [Utils imageWithImage:_image scaledToSize:sz];
        [self.photoButton setImage:self.photo forState:UIControlStateNormal];
        
    }
    else
    {
        if(gotoContactInfo)
        {
            [self.navigationController dismissModalViewControllerAnimated:YES];
            return;
        }
        if([Utils checkIfContactAdded])
        {
            [[self delegate] userDataAdded];
        }
    }

}
- (void)resignKeyboard:(id)sender
{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        [firstResponder resignFirstResponder];
        [self animateView:1];
    }
}

- (void)previousField:(id)sender
{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        NSUInteger tag = [firstResponder tag];
        NSUInteger previousTag = tag == 1 ? 1 : tag - 1;
        [self checkBarButton:previousTag];
        [self animateView:previousTag];
        UITextField *previousField = (UITextField *)[self.view viewWithTag:previousTag];
        [previousField becomeFirstResponder];
        //[self checkSpecialFields:previousTag];
    }
}

- (void)nextField:(id)sender
{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        NSUInteger tag = [firstResponder tag];
        NSUInteger nextTag = tag == FIELDS_COUNT ? FIELDS_COUNT : tag + 1;
        [self checkBarButton:nextTag];
        [self animateView:nextTag];
        UITextField *nextField = (UITextField *)[self.view viewWithTag:nextTag];
        [nextField becomeFirstResponder];
       // [self checkSpecialFields:nextTag];
    }
}

- (id)getFirstResponder
{
    
    if( (self.nameTextField.text != NULL && ![self.nameTextField.text isEqualToString:@""]) &&
       (self.lastNameTextField.text != NULL && ![self.lastNameTextField.text isEqualToString:@""]))
        signUp_btn.enabled = YES;
    else
        signUp_btn.enabled = NO;
    
    if(self.emailTextField.text != NULL && ![self.emailTextField.text isEqualToString:@""])
        self.enableEmail.enabled = YES;
    else
       self.enableEmail.enabled = NO;
       
    NSUInteger index = 0;
    while (index <= FIELDS_COUNT) {
        UITextField *textField = (UITextField *)[self.view viewWithTag:index];
        if ([textField isFirstResponder]) {
            return textField;
        }
        index++;
    }
    
    return NO;
}

- (void)animateView:(NSUInteger)tag
{
    CGRect rect = self.view.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    if (tag > 3) {
        rect.origin.y = -44.0f * (tag - 3);
    } else {
        rect.origin.y = 0;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void)checkBarButton:(NSUInteger)tag
{
    UIBarButtonItem *previousBarItem = (UIBarButtonItem *)[[self.keyboardToolbar items] objectAtIndex:0];
    UIBarButtonItem *nextBarItem = (UIBarButtonItem *)[[self.keyboardToolbar items] objectAtIndex:1];
    
    [previousBarItem setEnabled:tag == 1 ? NO : YES];
    [nextBarItem setEnabled:tag == FIELDS_COUNT ? NO : YES];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSUInteger tag = [textField tag];
    [self animateView:tag];
    [self checkBarButton:tag];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger tag = [textField tag];
    if (tag == BIRTHDAY_FIELD_TAG || tag == GENDER_FIELD_TAG) {
        return NO;
    }
    
    return YES;
}

#pragma mark Address Book
#pragma mark 

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
    NSString *firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);	
	
	self.nameTextField.text = firstName;
	self.lastNameTextField.text = lastName;
    
    if( (self.nameTextField.text != NULL && ![self.nameTextField.text isEqualToString:@""]) &&
       (self.lastNameTextField.text != NULL && ![self.lastNameTextField.text isEqualToString:@""]))
        signUp_btn.enabled = YES;
    else
        signUp_btn.enabled = NO;
	
    
	ABMutableMultiValueRef eMail  = ABRecordCopyValue(person, kABPersonEmailProperty);
	if(ABMultiValueGetCount(eMail) > 0) {
		self.emailTextField.text 	=  (NSString *)ABMultiValueCopyValueAtIndex(eMail, 0);
	}	
  
    if(self.emailTextField.text != NULL && ![self.emailTextField.text isEqualToString:@""])
        self.enableEmail.enabled = YES;
    else
        self.enableEmail.enabled = NO;
    
    
	//Get the users contact image( UNTESTESTED TH 061711)
	NSData* imageData = (NSData*)ABPersonCopyImageData(person);
	if(imageData != NULL)
	{
		UIImage* _image = [UIImage imageWithData: imageData];
		[imageData release];		
		CGSize sz = CGSizeMake(80, 80);
		//UIImage *smallImage = [Utils imageWithImage:_image scaledToSize:sz];
		//image.image = smallImage;
        
        self.photo = [Utils imageWithImage:_image scaledToSize:sz];
        [self.photoButton setImage:self.photo forState:UIControlStateNormal];
	}
    else
    {
        self.photo = nil;
        [self.photoButton setImage:self.photo forState:UIControlStateNormal];

    }
	/*
	//Get mobile phone number
	ABMultiValueRef phones =(NSString*)ABRecordCopyValue(person, kABPersonPhoneProperty);
	NSString* mobile=@"";
	NSString* mobileLabel;
	for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
		mobileLabel = (NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
		if([mobileLabel isEqualToString:@"_$!<Mobile>!$_"]) {
			mobile = (NSString*)ABMultiValueCopyValueAtIndex(phones, i);
		}
	}
	if(![mobile isEqualToString:@""])
	{
		[[NSUserDefaults standardUserDefaults] setValue:mobile forKey:@"NUMBER"];
		self.phoneTextField.text = mobile;
	}
     */
	[self dismissModalViewControllerAnimated:YES];
	return NO;
}



- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}



#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSUInteger sourceType = 0;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
            case 0:
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 1:
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 2:
                return;
        }
    } else {
        if (buttonIndex == 1) {
            return;
        } else {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.delegate = self;
	imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
	[self presentModalViewController:imagePickerController animated:YES];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    UIImage* _image =  [info objectForKey:UIImagePickerControllerEditedImage];
    CGSize sz = CGSizeMake(80, 80);
    self.photo = [Utils imageWithImage:_image scaledToSize:sz];
    [self.photoButton setImage:self.photo forState:UIControlStateNormal];
    [picker dismissModalViewControllerAnimated:YES];
} 


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
    
}
 
@end
