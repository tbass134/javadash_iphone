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
@synthesize dp,select_time_btn;
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
	[self.dp setDate:[NSDate date]];
    
    
    NSDate *last_minute = [[NSDate date] dateByAddingTimeInterval:(5*60)];
	self.dp.minimumDate = last_minute;
    [super viewDidLoad];
}

-(IBAction)selectTime
{
	DashSummary *dash = [DashSummary instance];
	
   
	NSDateFormatter *newFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [newFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss ZZZ"];
	NSString *dateString = [newFormatter stringFromDate:self.dp.date];
    
	[[dash getDict]setValue:dateString  forKey:@"selected_date"];
	[self.navigationController popViewControllerAnimated:YES];
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
