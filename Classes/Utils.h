//
//  Utils.h
//  CoffeeRunSample
//
//  Created by Tony Hung on 12/14/10.
//  Copyright 2010 Dark Bear Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TapkuLibrary.h"

@interface Utils : NSObject {

}
+ (NSString*)base64forData:(NSData*)theData;
+(NSString *) urlencode: (NSString *) url;
+(NSString *) replaceCharsWithEmpty: (NSString *) url;
+ (NSDate *)dateToGMT:(NSDate *)sourceDate;
+(void)showAlert:(NSString *)title withMessage:(NSString *)message inView:(UIView *)view;

+(NSString *)getCompanyName:(NSString *)name;
+(void)printDict:(NSDictionary *)ddict;

+(BOOL)checkIfContactAdded;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+(void)createUniqueDeviceID;
@end
