//
//  EditOrderView.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/27/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLConnection.h"

@interface EditOrderView : UIViewController<UIScrollViewDelegate> {

	NSDictionary *order_dict;
	int table_index;
	NSMutableDictionary *order_dict_mutable;
	NSString *selectedElement;
	int selectedIndex;
	URLConnection *conn;
    UITextView *options_txt;
}
@property(nonatomic,retain)NSDictionary *order_dict;
@property(nonatomic,assign)int table_index;
-(void)editItem:(NSString *)selectedItem;
-(void)loadData;
-(int)getIndex:name withArray:(NSArray *)items;

@end
