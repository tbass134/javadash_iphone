//
//  CoffeeDetailsView.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/14/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@class SCRSegmentedControl;

@interface CoffeeDetailsView : UIViewController<UITextFieldDelegate,MBProgressHUDDelegate> {

@private
	UILabel *_valueLabel;


	NSDictionary *plistDictionary;
	NSDictionary *coffee_dict;
	
    NSDictionary *drink;
    NSDictionary *edit_order_dict;
    int selected_index;
    NSString *orderType;
	NSMutableArray *sections_array;
	
    CGPoint svos;
    UIScrollView *scroll;
	NSMutableDictionary *savedDrink;
    
    int switchTagInt;
    NSMutableArray *switch_array;
    
    NSMutableArray *options_array;
    BOOL editLocalOrder;
     MBProgressHUD *HUD;
    
	
}
@property(nonatomic,retain) NSDictionary *drink;
@property(nonatomic,retain) NSDictionary *edit_order_dict;
@property(nonatomic,retain)NSString *orderType;
@property(nonatomic,assign)int selected_index;
@property(nonatomic,assign)BOOL editLocalOrder;

//@property (nonatomic, retain) IBOutlet SCRSegmentedControl *oneRowControl, *twoRowControl, *threeRowControl;
//@property (nonatomic, retain) IBOutlet UILabel *valueLabel;

- (IBAction)selectedIndexChanged:(id)sender;

@end
