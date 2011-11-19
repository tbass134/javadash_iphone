//
//  OrdersViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/14/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Loading.h"
#import <CoreData/CoreData.h>

@interface OrdersViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    Loading *load;
    
    //Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    
    //ViewCurrentOrdersView
    IBOutlet UIView *current_orders_view;
    IBOutlet UITableView *current_orders_table;
    IBOutlet UIView *noOrdersView;
    NSMutableArray *run_array;
    NSMutableArray *cells;
	NSMutableArray *orders_cells;
    UIBarButtonItem *addOrder_btn;
    
    //PlaceOrderView
    IBOutlet UIView *place_over_view;
	IBOutlet UIButton *drink_btn;
	IBOutlet UIButton *custom_btn;
	IBOutlet UIButton *your_order_btn;
	IBOutlet UIButton *favorite_btn;
    
    //Multiple Orders tableView
    IBOutlet UIView *mutiple_orders_view;
    IBOutlet UITableView *multiple_orders_table_view;
    
    UIBarButtonItem *send_order;
    UIBarButtonItem *goback;
    UIBarButtonItem *reload;
    BOOL isEditing;
    UIBarButtonItem *edit;
    BOOL order_ended;

}
//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//ViewCurrentOrdersView
@property(nonatomic,retain)NSMutableArray *run_array;

//Place Order View
@property(nonatomic,retain)UIButton *drink_btn;
@property(nonatomic,retain)UIButton *custom_btn;
@property(nonatomic,retain)UIButton *your_order_btn;
@property(nonatomic,retain)UIButton *favorite_btn;


-(void)checkForOrders;
-(void)gotoScreen;

//ViewCurrentOrdersView
-(void)initViewCurrentOrders;
-(void)loadOrderData;
-(IBAction)showDrinkList;
-(IBAction)showCustomList;
-(IBAction)showYourOrderList;
-(IBAction)showFavoritesList;

//Place Order View
-(void)initPlaceOrder;

@end
