#import "ParkPlaceMark.h"

@implementation ParkPlaceMark
@synthesize coordinate;
@synthesize cam_title;
@synthesize cam_subtitle;
@synthesize location_id;
@synthesize location_dict;
@synthesize image;
- (NSString *)subtitle{
	return cam_subtitle;
}
- (NSString *)title{
	return cam_title;
}


-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	
	coordinate=c;
	//NSLog(@"%f,%f",c.latitude,c.longitude);

	return self;
}
- (void)dealloc
{
    [image release];
    [super dealloc];
}


@end
