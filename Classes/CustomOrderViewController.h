//
//  CustomOrderViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 2/25/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoffeeRunSampleAppDelegate.h"
#import "MBProgressHUD.h"

@interface CustomOrderViewController : UIViewController<UITextViewDelegate,MBProgressHUDDelegate>{

    MBProgressHUD *HUD;
	IBOutlet UITextView *text_view;
	IBOutlet UILabel *label;
	IBOutlet UIButton *saveBtn;
	CoffeeRunSampleAppDelegate *appDelegate;
    
    NSDictionary *edit_order_dict;
    int selected_index;
}
@property(nonatomic,retain)UITextView *text_view;
@property(nonatomic,retain)UILabel *label;
@property(nonatomic,retain)UIButton *saveBtn;
@property(nonatomic,assign)int selected_index;
@property(nonatomic,retain)NSDictionary *edit_order_dict;
-(IBAction)saveOrder;
@end
