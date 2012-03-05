//
//  DBSignupViewController.h
//  DBSignup
//
//  Created by Davide Bettio on 7/4/11.
//  Copyright 2011 03081340121. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "FriendsInfo.h"
#import "MBProgressHUD.h"
@protocol DBSignupViewControllerDelegate <NSObject>
@required
- (void)userDataAdded;
@end

@interface DBSignupViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    ABPeoplePickerNavigationControllerDelegate,MBProgressHUDDelegate> {
        
        MBProgressHUD *HUD;
    //Page 1 View
    IBOutlet UIView *page1;
    IBOutlet UIImageView *page1_bg;

    //Page 2 View
    IBOutlet UIView *page2;
    IBOutlet UIImageView *page2_bg;
    IBOutlet UIButton  *gotoPage3_btn;

    //Page 3 View
    IBOutlet UIView *page3;
    IBOutlet UIImageView *page3_bg;
    IBOutlet UIButton  *gotoContact_btn;
    
    //Contact View
    id <DBSignupViewControllerDelegate> delegate;
    IBOutlet UIView *contact;
    UITextField *nameTextField_;
    UITextField *lastNameTextField_;
    UITextField *emailTextField_;
    UISwitch *enableEmail_;
    UITextField *passwordTextField_;
    UITextField *phoneTextField_;
    UIButton *photoButton_;
    IBOutlet UIButton *signup_btn;
    UITextView *termsTextView_;
    
    UILabel *emailLabel_;
    UILabel *sendemailLabel_;
    UILabel *enableLabel_;
    UILabel *passwordLabel_;
    UILabel *genderLabel_;
    UILabel *phoneLabel_;
    
    UIToolbar *keyboardToolbar_;
    
    UIImage *photo_;
    
    UIButton *getContactInfoButton_;
    IBOutlet UIButton *connectFacebookButton;
    IBOutlet  UIButton *contact_back_btn;
    IBOutlet UIImageView *contactBG;
        
    BOOL gotoContactInfo;    
    UIBarButtonItem *signUp_btn;
    UIBarButtonItem *cancel_btn;
    NSString *fbid;
    BOOL userAdded;
   
    
}
//Help View
@property(nonatomic, retain) IBOutlet UIView *help_view;

//Contact View
@property (retain) id delegate;
@property(nonatomic, retain) IBOutlet UITextField *nameTextField;
@property(nonatomic, retain) IBOutlet UITextField *lastNameTextField;
@property(nonatomic, retain) IBOutlet UITextField *emailTextField;
@property(nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property(nonatomic, retain) IBOutlet UITextField *phoneTextField;
@property(nonatomic, retain) IBOutlet UIButton *photoButton;
@property(nonatomic, retain) IBOutlet UITextView *termsTextView;

@property(nonatomic, retain) IBOutlet UILabel *emailLabel;
@property(nonatomic, retain) IBOutlet UILabel *sendemailLabel;
@property(nonatomic, retain) IBOutlet UILabel *passwordLabel;
@property(nonatomic, retain) IBOutlet UILabel *genderLabel;
@property(nonatomic, retain) IBOutlet UILabel *phoneLabel;
@property(nonatomic, retain) IBOutlet UIButton *getContactInfoButton;

@property(nonatomic, retain) IBOutlet UISwitch *enableEmail;
@property(nonatomic, retain) UIToolbar *keyboardToolbar;

@property(nonatomic, retain) UIImage *photo;
@property(nonatomic, retain) IBOutlet UIImageView *img;

@property(nonatomic) BOOL gotoContactInfo;

-(IBAction)gotoPageContact:(id)sender;
-(IBAction)goBack3:(id)sender;
-(IBAction)skipContact:(id)sender;

//Contact view
- (IBAction)choosePhoto:(id)sender;
- (IBAction)getContactInfo:(id)sender;
-(IBAction)goBackContact:(id)sender;
-(IBAction)signup:(id)sender;
-(IBAction)connectFacebook:(id)sender;
-(void)saveFBId;

- (void)resignKeyboard:(id)sender;
- (void)previousField:(id)sender;
- (void)nextField:(id)sender;
- (id)getFirstResponder;
- (void)animateView:(NSUInteger)tag;
- (void)checkBarButton:(NSUInteger)tag;
- (void)signup:(id)sender;
-(void)doSignUp;

@end
