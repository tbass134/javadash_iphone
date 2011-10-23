//
//  CoffeeOrderTableViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SavedDrinksList.h"
#import "CoffeeRunSampleAppDelegate.h"

@interface CoffeeOrderTableViewController : UITableViewController {

	NSDictionary *plistDictionary;
	NSDictionary *coffee_dict;
	int lastIndexPath;
	NSString *companyName;
	NSString *beverage;
	NSString *orderType;
	NSMutableArray *sections_array;
	CoffeeRunSampleAppDelegate *appDelegate;
	

	NSMutableDictionary *savedDrink;
	SavedDrinksList *list;
	
}
@property(nonatomic,retain)NSString *companyName;
@property(nonatomic,retain)NSString *beverage;
@property(nonatomic,retain)NSString *orderType;
@end
