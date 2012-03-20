//
//  HelpViewControllerViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 2/29/12.
//  Copyright (c) 2012 Dark Bear Interactive. All rights reserved.
//

#import "HelpViewControllerViewController.h"

@interface HelpViewControllerViewController ()

@end

@implementation HelpViewControllerViewController
@synthesize bg;
@synthesize scrollView;
@synthesize pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    NSMutableArray *text_array = [[NSMutableArray alloc]init];
    NSMutableArray *images_array = [[NSMutableArray alloc]init];

    [text_array addObject:@"This is the runs screen where you can start a new dash. To start a dash, tap on 'Current Locations' box to find a coffee location.\n Next, click on 'Run Time' box to set what time you will be going for the dash.\nFinally, tap on 'Attendees' to add friends to your dash.\n When ready to start a dash, just click 'Start Run' on the top to start the dash"];
    [images_array addObject:[UIImage imageNamed:@"Run_View.png"]];

    [text_array addObject:@"Once a order has been started, you will be able to see the current orders placed for the dash. This will show the location of the dash and what time till the dash ends.\nIf you or any friends added a order to the dash, they will appear in the bottom of the screen."];
    [images_array addObject:[UIImage imageNamed:@"Run_View2.png"]];
    
    [text_array addObject:@"On this screen, you will see all the orders placed for this dash. If you are the person who started the dash, you will see all the orders. If not, you will just see your own orders"];
    [images_array addObject:[UIImage imageNamed:@"Orders_View.png"]];
    
    [text_array addObject:@"On the Settings page, you can update your profile and find other Java Dash users on Facebook. \n\nYou can also BUMP with other users to add them to your friends list. \n\nAny friends that are added are shown on this screen."];
    [images_array addObject:[UIImage imageNamed:@"Settings_View.png"]];
    
    
    for (int i = 0; i < text_array.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        //subview.backgroundColor = [colors objectAtIndex:i];
        
        UIImage *image = [images_array objectAtIndex:i];
        NSString *text = [text_array objectAtIndex:i];
        UIImageView *mainImage = [[UIImageView alloc]initWithImage:image];
        mainImage.frame = CGRectMake(0,0,image.size.width,image.size.height);
        [subview addSubview:mainImage];  
        [mainImage release];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(mainImage.frame.size.width+5, 0, 120 , image.size.height)];
        label1.numberOfLines = 999;
        label1.text = text;
        label1.backgroundColor = [UIColor clearColor];
        label1.font = [UIFont boldSystemFontOfSize:11];
        [subview addSubview:label1];
        [label1 release];
              
        [self.scrollView addSubview:subview];
        [subview release];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * text_array.count, 0);

    [text_array release];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(void)close:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}
- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)viewDidUnload
{
    self.scrollView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
