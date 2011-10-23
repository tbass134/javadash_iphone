//
//  CoffeeLocation.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 12/27/10.
//  Copyright 2010 Dark Bear Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CoffeeLocation : NSObject {

	NSString *rating_img_url;
	NSString *country_code;
	NSString *id;
	NSString *is_closed;
	NSString *city;
	NSString *mobile_url;
	NSString *review_count;
	NSString *zip;
	NSString *state;
	NSString *latitude;
	NSString *rating_img_url_small;
	NSString *address1;
	NSString *address2;
	NSString *address3;
	NSString *phone;
	NSString *state_code;
	NSString *photo_url;
	NSString *distance;
	NSString *name;
	NSString *url;
	NSString *avg_rating;
	NSString *longitude;
	NSString *nearby_url;
	NSString *photo_url_small;
	
	


}
@property (retain,nonatomic) NSString *rating_img_url;
@property (retain,nonatomic) NSString *country_code;
@property (retain,nonatomic) NSString *id;
@property (retain,nonatomic) NSString *is_closed;
@property (retain,nonatomic) NSString *city;
@property (retain,nonatomic) NSString *mobile_url;
@property (retain,nonatomic) NSString *review_count;
@property (retain,nonatomic) NSString *zip;
@property (retain,nonatomic) NSString *state;
@property (retain,nonatomic) NSString *latitude;
@property (retain,nonatomic) NSString *rating_img_url_small;
@property (retain,nonatomic) NSString *address1;
@property (retain,nonatomic) NSString *address2;
@property (retain,nonatomic) NSString *address3;
@property (retain,nonatomic) NSString *phone;
@property (retain,nonatomic) NSString *state_code;
@property (retain,nonatomic) NSString *photo_url;
@property (retain,nonatomic) NSString *distance;
@property (retain,nonatomic) NSString *name;
@property (retain,nonatomic) NSString *url;
@property (retain,nonatomic) NSString *avg_rating;
@property (retain,nonatomic) NSString *longitude;
@property (retain,nonatomic) NSString *nearby_url;
@property (retain,nonatomic) NSString *photo_url_small;

-(void)loadData:(NSString *)term loc:(NSString *)location;

@end
