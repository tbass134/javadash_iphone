//
//  AttendeeOrderTableViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/24/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapkuLibrary.h"

@interface AttendeeOrderTableViewController : UITableViewController {

	NSDictionary *run_dict;
	NSMutableArray *run_array;
    NSMutableArray *cells;
}
@property(nonatomic,retain)NSMutableArray *run_array;
@end
