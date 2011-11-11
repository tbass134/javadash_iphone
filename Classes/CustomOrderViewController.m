//
//  CustomOrderViewController.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 2/25/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "CustomOrderViewController.h"
#import "DrinkOrders.h"
#import "Order.h"
#import "URLConnection.h"
#import "JSON.h"
#import "Constants.h"

@implementation CustomOrderViewController
@synthesize text_view,label,saveBtn;
@synthesize edit_order_dict;
@synthesize selected_index;
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
	self.text_view.delegate = self;
    
    if(edit_order_dict != NULL)
        self.text_view.text = [edit_order_dict objectForKey:@"CustomOrder"];

	
    [super viewDidLoad];
}
-(IBAction)saveOrder
{
    if(edit_order_dict != NULL)
    {
        [edit_order_dict setObject:text_view.text forKey:@"CustomOrder"];
        DrinkOrders *drink_orders = [DrinkOrders instance];
        NSLog(@"drink_orders %@",drink_orders);
        
    
        Order *order = [Order sharedOrder];
        //This order was editied, need to send the new data to the server
        int ts = [[NSDate date] timeIntervalSince1970];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/placeorder.php?ts=%i",baseDomain,ts]]
                                                               cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                           timeoutInterval:60.0];
        
        [request setHTTPMethod:@"POST"];
        
        SBJSON *parser = [[SBJSON alloc] init];	
        NSString *order_str = [parser stringWithObject:edit_order_dict];
        [parser release];
        
         NSDictionary *selected_drink = [[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:selected_index];
        
        
        NSString *post_str = [NSString stringWithFormat:@"device_id=%@&run_id=%@&order=%@&updateOrder=1&order_id=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"_UALastDeviceToken"],	[[[order currentOrder]objectForKey:@"run"]objectForKey:@"id"],order_str,[selected_drink objectForKey:@"order_id"]];
        [request setHTTPBody:[post_str dataUsingEncoding:NSUTF8StringEncoding]]; 
        NSLog(@"post_str %@",post_str);
        NSLog(@"url %@", [request URL]);
        
        URLConnection *conn = [[URLConnection alloc]init];
        conn.tag =@"editOrder";
        [conn setDelegate:self];
        [conn initWithRequest:request];
        
    }
    else
    {
        printf("saveOrder");
        NSMutableDictionary *savedDrink = [[NSMutableDictionary alloc]init];
        NSString *timestamp = [NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]];
        [savedDrink setObject:timestamp forKey:@"timestamp"];
        [savedDrink setObject:text_view.text forKey:@"CustomOrder"];
        
        DrinkOrders *drink_orders = [DrinkOrders instance];
        [[drink_orders getArray]addObject:savedDrink];
    }
     
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data
{
    //[Utils showAlert:@"Order Updated" withMessage:nil inView:self.view];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderEdited" object:self];
    
    [self.navigationController popViewControllerAnimated:YES];
}   
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range  replacementText:(NSString *)text
{
	if (range.length==0) {
		if ([text isEqualToString:@"\n"]) {
			[textView resignFirstResponder];
			return NO;
		}
	}
	
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
