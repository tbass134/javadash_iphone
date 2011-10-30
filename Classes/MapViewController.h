//
//  MapViewController.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 12/27/10.
//  Copyright 2010 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "CoffeeLocation.h"
#import "URLConnection.h"
#import "Loading.h"
#import "SummaryTableViewController.h"

@interface MapViewController : UIViewController<MKMapViewDelegate,UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate,MKReverseGeocoderDelegate,UITextFieldDelegate/*,UISearchBarDelegate*/> {

    IBOutlet UIView *loadingView;
	IBOutlet MKMapView *mapView;
	IBOutlet UITableView *tableView;
	IBOutlet UISegmentedControl *seg_control;
	IBOutlet UIBarButtonItem *reloadLocation_btn;
    UIBarButtonItem *cancel_btn;
	SummaryTableViewController *parent;

	NSMutableDictionary *yelp_dict;
	CLLocationManager *locationManager;
	MKPlacemark *mPlacemark;
    
	URLConnection *conn;
	
	NSMutableArray *tableDataSource;
	CoffeeLocation *location;
	Loading *load;	
    IBOutlet UILabel *noResultsFound;
    
	//Core Data
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	NSString *searchText;
	NSDictionary *selected_location;
	CLLocation *currentLocation;
	
	NSMutableArray *favorites_array;
    BOOL ischecked;
    
    int limit;
    int offset;
    int sort;
    int total;
    
    NSMutableData *_yelpResponseData;
    
    IBOutlet UIView *search_view;
    IBOutlet UITextField *name_txt;
    IBOutlet UITextField *loc_txt;
    UIToolbar *keyboardToolbar;

}
@property (retain,nonatomic) MKMapView *mapView;
@property (retain,nonatomic) UITableView *tableView;
@property (retain,nonatomic) UISegmentedControl *seg_control;
@property (retain,nonatomic) UIBarButtonItem *reloadLocation_btn;
//@property (retain,nonatomic) UISearchBar *searchBar;

@property(nonatomic,retain)NSMutableArray *tableDataSource;
@property(nonatomic,retain)CLLocation *currentLocation;
@property (nonatomic, retain) NSMutableArray *favorites_array;
@property (nonatomic, retain)UIToolbar *keyboardToolbar;




//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(IBAction)changeSegment:(id)sender;
-(IBAction)reloadLocation:(id)sender;
-(IBAction)showFavorites:(id)sender;

-(void)goNext;

-(void)locationUpdate:(CLLocation *)l;
- (void)stopUpdatingLocation:(NSString *)state;
-(void)locationError:(NSError *)error;

-(BOOL)checkForFavorites:(NSString *)str;
-(void)loadData:(NSString *)term loc:(NSString *)l;
- (void)loadYelp:(NSString *)term loc:(NSString *)l;
-(void)loadDataFromJSONStr:(NSString *)str;
-(void)showDetails:(NSDictionary *)info;
-(void)loadFavoriteLocation:(NSDictionary *)dict;
-(void)updateTable:(NSMutableDictionary *)obj;



- (void)resignKeyboard:(id)sender;
- (void)previousField:(id)sender;
- (void)nextField:(id)sender;
- (id)getFirstResponder;
- (void)animateView:(NSUInteger)tag;
- (void)checkBarButton:(NSUInteger)tag;
-(void)dismissSearchView;
@end
