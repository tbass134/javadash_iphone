//
//  SelectTimeView.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 5/29/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "SelectTimeView.h"
#import "DashSummary.h"

@implementation SelectTimeView
@synthesize dp,select_time_btn,date_str;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	newFormatter = [[[NSDateFormatter alloc] init]retain];
    [newFormatter setDateFormat:@"MMM d hh:mm aa"];
    
    NSDate* runDate = [[NSDate date] dateByAddingTimeInterval:self.dp.countDownDuration];
    NSString *dateString = [newFormatter stringFromDate:runDate];
     date_str.text = dateString;
    [super viewDidLoad];
}

-(IBAction)selectTime
{   
    NSDate* runDate = [[NSDate date] dateByAddingTimeInterval:self.dp.countDownDuration];
    NSDateFormatter *jsonFormat = [[[NSDateFormatter alloc] init]autorelease];
    [jsonFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss ZZZ a"];
    NSString *dateString = [jsonFormat stringFromDate:runDate];
    
    //NSLog(@"ts %f",[self.dp.date timeIntervalSince1970]);
    //NSLog(@"dateString %@",dateString);
    
	[[[DashSummary instance] getDict]setValue:runDate forKey:@"selected_date"];
    [[[DashSummary instance] getDict]setValue:[NSNumber numberWithDouble:[runDate timeIntervalSince1970]]  forKey:@"selected_timestamp"];
    
	[self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)timeChanged:(id)sender
{
    NSDate* runDate = [[NSDate date] dateByAddingTimeInterval:self.dp.countDownDuration];
    NSString *dateString = [newFormatter stringFromDate:runDate];
    NSLog(@"ts %f",[self.dp.date timeIntervalSince1970]);
    NSLog(@"dateString %@",dateString);
    date_str.text = dateString;

}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
