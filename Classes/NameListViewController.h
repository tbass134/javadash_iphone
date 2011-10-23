//
//  NameListViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoffeeRunSampleAppDelegate.h"
@interface NameListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {

    IBOutlet UIView *drink_temp_view;
    IBOutlet UIButton *iced_btn;
    IBOutlet UIButton *hot_btn;
    IBOutlet UITableView *table_view;
    IBOutlet UIView *options_view;
	NSString *companyName;
	NSString *company_type;
	NSMutableArray *beverage_array;
	NSString *orderType;
	CoffeeRunSampleAppDelegate *appDelegate;
    NSMutableArray *sections;
    
    NSDictionary *plistDictionary;
	NSDictionary *coffee_dict;
    NSString *drink_type;
}
@property(nonatomic,retain)NSString *companyName; 
@property(nonatomic,retain)NSString *orderType;

-(IBAction)chooseDrinkTemp:(id)sender;
@end
