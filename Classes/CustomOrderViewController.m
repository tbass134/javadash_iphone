//
//  CustomOrderViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 2/25/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "CustomOrderViewController.h"
#import "DrinkOrders.h"

@implementation CustomOrderViewController
@synthesize text_field,label,saveBtn;
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
	appDelegate = [[UIApplication sharedApplication] delegate];
	self.text_field.delegate = self;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)];

	
    [super viewDidLoad];
}
-(IBAction)saveOrder
{
	printf("saveOrder");
	NSMutableDictionary *savedDrink = [[NSMutableDictionary alloc]init];
	NSString *timestamp = [NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]];
	[savedDrink setObject:timestamp forKey:@"timestamp"];
	[savedDrink setObject:text_field.text forKey:@"CustomOrder"];
	
	DrinkOrders *drink_orders = [DrinkOrders instance];
	[[drink_orders getArray]addObject:savedDrink];
	[self.navigationController dismissModalViewControllerAnimated:YES];
}
-(void)close:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)tf {
	[tf resignFirstResponder];
	return YES;
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
