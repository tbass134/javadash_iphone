//
//  SelectTimeView.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 5/29/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectTimeView : UIViewController {

	IBOutlet UIDatePicker *dp; 
	IBOutlet UIButton *select_time_btn;
	
}
@property (retain,nonatomic) IBOutlet UIDatePicker *dp; 
@property (retain,nonatomic) IBOutlet UIButton *select_time_btn;
-(IBAction)selectTime;

@end
