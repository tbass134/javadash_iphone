//
//  CoffeeRunSampleAppDelegate.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 12/14/10.
//  Copyright 2010 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "DBSignupViewController.h"
#import "FBConnect.h"

#import "AdWhirlView.h"
#import "AdViewController.h"



@interface CoffeeRunSampleAppDelegate : NSObject <UIApplicationDelegate,UITabBarControllerDelegate,FBRequestDelegate,
FBDialogDelegate,
FBSessionDelegate,AdWhirlDelegate> {
	
	//Core Data
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;

	UIImageView *bg;
    UIWindow *window;
	UITabBarController*  myTabBarController;
    DBSignupViewController *dbSignupViewController;
	NSString *deviceToken;
	NSString *deviceAlias;
	//NSMutableArray *coffee_orders_array;
    
    
    
    //FaceBook
    Facebook* facebook;
    NSArray* permissions;
    NSArray *fb_friends;
    NSDictionary *fb_me;
    NSString *fb_tag;
    
    //AdWhirl
    NSString *adWhirlKey;
    AdViewController *adView;
    BOOL adsLoaded;
    BOOL didPurchaseApp;
    
    BOOL UILoaded;

	
}
//Core Data
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSString *deviceAlias;

//@property (nonatomic, retain) NSMutableArray *coffee_orders_array;

@property (nonatomic,assign) BOOL didPurchaseApp;

//FaceBook
@property(readonly) Facebook *facebook;
@property(nonatomic,retain) NSArray* permissions;
@property(nonatomic,retain) NSArray* fb_friends;
@property(nonatomic,retain) NSDictionary* fb_me;
@property(nonatomic,retain) NSString *fb_tag;


//AdWhirl
-(void)resetAdView;
-(void)showAdView;
-(void)hideAdView;
@property (nonatomic,assign) BOOL adsLoaded;
@property (nonatomic, retain) NSString *adWhirlKey;

- (NSString *)applicationDocumentsDirectory;
-(NSDictionary *)getDeviceInfo;

-(void)initTesting;
-(void)loadUI;
-(void)checkForAppPurchase;
- (void)customizeAppearance;
@end

