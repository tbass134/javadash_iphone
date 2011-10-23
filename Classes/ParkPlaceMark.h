#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ParkPlaceMark : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *cam_title;
	NSString *cam_subtitle;
	NSString *location_id;
	NSDictionary *location_dict;
	UIImage *image;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *cam_title;
@property (nonatomic, retain) NSString *cam_subtitle;
@property (nonatomic, retain) NSString *location_id;
@property (nonatomic, retain) NSDictionary *location_dict;
@property (nonatomic, retain) UIImage *image;
-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;
- (NSString *)subtitle;
- (NSString *)title;


@end
