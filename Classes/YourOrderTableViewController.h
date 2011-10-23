//
//  YourOrderTableViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 2/22/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface YourOrderTableViewController : UITableViewController {

	NSString *type;
	NSMutableArray *coffee_orders_array;
    NSMutableArray *orders_cells;
}
-(void)loadData;
@property(nonatomic,retain)NSString *type;
@property(nonatomic,retain)NSMutableArray *coffee_orders_array;
@end
