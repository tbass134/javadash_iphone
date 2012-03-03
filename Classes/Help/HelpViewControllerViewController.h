//
//  HelpViewControllerViewController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 2/29/12.
//  Copyright (c) 2012 Dark Bear Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewControllerViewController : UIViewController
{
    IBOutlet UIImageView *bg;
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIPageControl* pageControl;
    BOOL pageControlBeingUsed;
}
@property (nonatomic, retain) IBOutlet UIImageView *bg;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
- (IBAction)changePage;
@end
