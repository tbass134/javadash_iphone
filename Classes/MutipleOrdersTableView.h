//
//  MutipleOrdersTableView.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 11/5/11.
//  Copyright (c) 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutipleOrdersTableView : UIViewController<UITableViewDelegate>
{
    IBOutlet UITableView *table_view;
    NSMutableArray *cells;
    NSMutableArray *orders_cells;
    int selected_index;

}
@property(nonatomic,assign)int selected_index;
@end
