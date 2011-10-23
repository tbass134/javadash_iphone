//
//  CoffeeDetailsTableViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/14/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SavedDrinksList.h"
#import "SVSegmentedControl.h"

@interface CoffeeDetailsTableViewController : UITableViewController<SVSegmentedControlDelegate> {

	NSDictionary *coffee_dict;
	
	NSString *companyName;
	NSString *beverage;
	NSString *orderType;
	NSMutableArray *sections_array;
	
	NSMutableDictionary *savedDrink;
	SavedDrinksList *list;
	
}
@property(nonatomic,retain)NSString *companyName;
@property(nonatomic,retain)NSString *beverage;
@property(nonatomic,retain)NSString *orderType;
@end
