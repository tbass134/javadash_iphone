//
//  CustomOrderViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 2/25/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoffeeRunSampleAppDelegate.h"

@interface CustomOrderViewController : UIViewController<UITextFieldDelegate> {

	IBOutlet UITextField *text_field;
	IBOutlet UILabel *label;
	IBOutlet UIButton *saveBtn;
	CoffeeRunSampleAppDelegate *appDelegate;
}
@property(nonatomic,retain)UITextField *text_field;
@property(nonatomic,retain)UILabel *label;
@property(nonatomic,retain)UIButton *saveBtn;

-(IBAction)saveOrder;
@end
