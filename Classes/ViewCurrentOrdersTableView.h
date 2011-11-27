//
//  ViewCurrentOrdersTableView.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/11/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdWhirlDelegateProtocol.h"

@class AdWhirlView;

@interface ViewCurrentOrdersTableView : UIViewController<UITableViewDelegate, UITableViewDataSource, AdWhirlDelegate> {

	NSMutableArray *run_array;
    NSMutableArray *cells;
	NSMutableArray *orders_cells;
    AdWhirlView *adView;
    IBOutlet UITableView *tableView;
    IBOutlet UIView *noOrdersView;
}
@property(nonatomic,retain)NSMutableArray *run_array;
@property (nonatomic,retain)IBOutlet UITableView *tableView;
@property (nonatomic,retain) AdWhirlView *adView;
-(void)loadData;
@end
