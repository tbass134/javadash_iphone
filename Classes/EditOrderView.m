    //
//  EditOrderView.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/27/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import "EditOrderView.h"
#import "Order.h"
#import "JSON.h"
#import "Utils.h"
#import "MyUISegmentController.h"
#import "DataService.h"

#define UITEXTVIEWTAG 1
#define UISWITCHTAG 2

@implementation EditOrderView
@synthesize order_dict,table_index;
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];

    /*
	NSDictionary *plistDictionary = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"plistDictionary"];
	if(!plistDictionary)
	{
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:@"CoffeeList.plist"];
		plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
		
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		if (standardUserDefaults) 
			[standardUserDefaults setObject:plistDictionary forKey:@"plistDictionary"];
		
	}
     */
	
	
	
	UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[self.view addSubview:scroll];
	
	Order *order = [Order sharedOrder];
	order_dict = [[[[[order currentOrder]objectForKey:@"run"]objectForKey:@"orders"]objectAtIndex:table_index]objectForKey:@"drink"];
	NSMutableArray *sections_array = [[NSMutableArray alloc]init];
	//NSLog(@"order_dict %@",order_dict);

	
	int i=0;
    if([order_dict  isKindOfClass:[NSDictionary class]])
    {
        for (id theKey in order_dict) {
		i++;
		[sections_array addObject:theKey];
		
		
		UIView *seg_view = [[UIView alloc]initWithFrame:CGRectMake(0,(i*75)-75,self.view.frame.size.width,75)];
		[scroll addSubview:seg_view];
		UILabel *title_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
		title_label.backgroundColor = [UIColor clearColor];
		title_label.text = theKey;
		[seg_view addSubview:title_label];
		[title_label release];
		
		
		//show 2 arrows if the width of the controller is bigger than the frame width
		UILabel *leftArrow = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 50, 20)];
		leftArrow.hidden = YES;
		leftArrow.backgroundColor = [UIColor clearColor];
		leftArrow.text = @"<--";
		[seg_view addSubview:leftArrow];
		[leftArrow release];
		
		UILabel *rightArrow = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width -20, 20, 50, 20)];
		rightArrow.text = @"-->";
		rightArrow.backgroundColor = [UIColor clearColor];
		rightArrow.hidden = YES;
		[seg_view addSubview:rightArrow];
		[rightArrow release];
		
				
		UIScrollView *segment_scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,60)];
        segment_scroll.delegate = self;
        segment_scroll.tag = i;
		[seg_view addSubview:segment_scroll];
		
		
		//NSString *companyName = [Utils getCompanyName:[[[[order currentOrder] objectForKey:@"run"]objectForKey:@"location"]objectForKey:@"name"]];
		//NSString *beverage  =[order_dict objectForKey:@"beverage"];
		//NSArray *item_dict =[[[[plistDictionary objectForKey:companyName]objectForKey:@"Drinks"]objectForKey:beverage]objectForKey:theKey];
		
		
	
		
		//NSLog(@"companyName %@",companyName);
		//NSLog(@"beverage %@",beverage);
		//NSLog(@"item_dict count %i",[item_dict count]);
		NSMutableArray *keys = [[NSMutableArray alloc]init];
		//NSLog(@"keys %@",keys);
		/*
        if([item_dict count] >0)
        {
            MyUISegmentController *seg = [[MyUISegmentController alloc]initWithItems:item_dict];
            seg.selected_key = theKey;
            if(item_dict != NULL)
            {
                //NSLog(@"current index %i",[self getIndex:[order_dict objectForKey:theKey] withArray:item_dict]);
                [seg setSelectedSegmentIndex:[self getIndex:[order_dict objectForKey:theKey] withArray:item_dict]];
                
            }
            seg.center = CGPointMake(seg.center.x, 40);
            [seg addTarget:self action:@selector(setValueForSegment:) forControlEvents:UIControlEventValueChanged];
            seg.segmentedControlStyle = UISegmentedControlStyleBezeled;
            [segment_scroll addSubview:seg];
            [seg release];
            
            if(seg.frame.size.width > self.view.frame.size.width)
            {
                leftArrow.hidden = NO;
                rightArrow.hidden = NO;
            }
            [segment_scroll setContentSize:CGSizeMake(seg.frame.size.width, seg.frame.size.height)];	
            [segment_scroll release];
            [seg_view release];
		}
        else
        {
            i--;
            [seg_view setHidden:YES];
        }
         */
        [keys release];
	 
	}
    
        if(![[order_dict objectForKey:@"Custom"] isEqualToString:@""])
        {
        //Add a text box for other options
        CGRect options_rect;
        if(i>1)
            options_rect = CGRectMake(0, i*70, self.view.frame.size.width, 50);
        else
            options_rect = CGRectMake(0, i*50, self.view.frame.size.width, 50);
        UILabel *options_label = [[UILabel alloc]initWithFrame:options_rect];
        options_label.backgroundColor = [UIColor clearColor];
        
        if([order_dict objectForKey:@"CustomOrder"] !=NULL)
            options_label.text = @"Custom Order";
        else
            options_label.text = @"Options";
        [scroll addSubview:options_label];
        [options_label release];
        
       options_txt = [[UITextView alloc]initWithFrame:CGRectMake(0, 
                                                                              options_label.frame.origin.y + options_label.frame.size.height,
                                                                              self.view.frame.size.width,
                                                                              50)];
        options_txt.tag = UITEXTVIEWTAG;
        options_txt.layer.borderWidth = 2.0f;
        options_txt.layer.borderColor = [[UIColor grayColor] CGColor];
        
        if([order_dict objectForKey:@"CustomOrder"] !=NULL)
            options_txt.text = [order_dict objectForKey:@"CustomOrder"];
        else
            options_txt.text = [order_dict objectForKey:@"Custom"];
        
        [scroll addSubview:options_txt];
        [options_txt release];
	}
        //NSLog(@"i %i",i);
    }
    else if([order_dict isKindOfClass:[NSArray class]])
    {
        
    }
    int j = 0;
    for (UIView *view in scroll.subviews)
    {
        if(!view.hidden)
            j+=view.frame.size.height;
    }
	//int total_height = (i*100)+options_txt.frame.size.height + setFav_switch.frame.size.height;
	[scroll setContentSize:CGSizeMake(self.view.frame.size.width, j)];
	[scroll release];
	 
    [super viewDidLoad];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the end
    }
    
}
-(int)getIndex:name withArray:(NSArray *)items 
{
	int index = 0;
	
	for(int i=0;i<[items count];i++)
	{
		//NSLog(@"name %@",name);
		//NSLog(@"item %@",[items objectAtIndex:i]);
		if([name isEqualToString:[items objectAtIndex:i]])
		{
			index = i;
			break;
		}
		
	}
	return index;
}
-(void)setValueForSegment:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *key = [segmentedControl selected_key];
	NSString *item = [segmentedControl titleForSegmentAtIndex:[segmentedControl selectedSegmentIndex]];
    
    //NSLog(@"key %@",key);
    //NSLog(@"item %@",item);
    [order_dict setValue:item forKey:key];
/*	
	//add elements to NSDictionary
	if([savedDrink objectForKey:key])
	{
		[savedDrink removeObjectForKey:key];
		[savedDrink setObject:item forKey:key];
	}
	else
		[savedDrink setObject:item forKey:key];
*/
}
-(void)save:(id)sender
{
    Order *order = [Order sharedOrder];
    
    if([order_dict objectForKey:@"CustomOrder"] !=NULL)
        [order_dict setValue:options_txt.text forKey:@"CustomOrder"];
    else
    [order_dict setValue:options_txt.text forKey:@"Custom"];
    
    SBJSON *parser = [[SBJSON alloc] init];	
	NSString *order_str = [parser stringWithObject:order_dict];
	[parser release];
    
    
    //NSLog(@"order_dict %@",order_dict);
    BOOL orderPlaced = [[DataService sharedDataService]placeOrder:
                        [[[order currentOrder]objectForKey:@"run"]objectForKey:@"id"]
                                                            order:order_str
                                                      updateOrder:@"1"
                                                          orderID:nil
                        ];
    
    if(orderPlaced)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Order Saved" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [alert show];
        [alert release];
        [self.navigationController popViewControllerAnimated:YES];
    }

   
	
}
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
