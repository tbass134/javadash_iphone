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
    //self.dp.timeZone = [NSTimeZone timeZoneWithName:@"EST"];
    
    //NSDate *last_minute = [[NSDate date] dateByAddingTimeInterval:(5*60)];
	//self.dp.minimumDate = [NSDate date] ;
    [super viewDidLoad];
}

-(IBAction)selectTime
{   
	NSDateFormatter *newFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [newFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss ZZZ a"];
	NSString *dateString = [newFormatter stringFromDate:self.dp.date];
    
    NSLog(@"ts %f",[self.dp.date timeIntervalSince1970]);
    NSLog(@"dateString %@",dateString);
    
	[[[DashSummary instance] getDict]setValue:self.dp.date  forKey:@"selected_date"];
    [[[DashSummary instance] getDict]setValue:[NSNumber numberWithFloat:[self.dp.date timeIntervalSince1970]]  forKey:@"selected_timestamp"];
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
