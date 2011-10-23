//
//  Utils.m
//  CoffeeRunSample
//
//  Created by Tony Hung on 12/14/10.
//  Copyright 2010 Dark Bear Interactive. All rights reserved.
//

#import "Utils.h"


@implementation Utils

// From: http://www.cocoadev.com/index.pl?BaseSixtyFour
+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}
+(NSString *) urlencode: (NSString *) url
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*",@" ", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A",@"%20", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
		
    return [NSString stringWithString: temp];
}
+(NSString *) replaceCharsWithEmpty: (NSString *) url
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*",@"\"",@"\n", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:@""
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
	
    return [NSString stringWithString: temp];
}
+(void)showAlert:(NSString *)title withMessage:(NSString *)message inView:(UIView *)view
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message  delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}
+ (NSDate *)dateToGMT:(NSDate *)sourceDate {
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    #if debug
	NSLog(@"destinationGMTOffset %i",destinationGMTOffset);
    #endif
    
    NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:destinationGMTOffset sinceDate:sourceDate] autorelease];
    return destinationDate;
}

+(NSString *)getCompanyName:(NSString *)name
{
	name = [name lowercaseString];
	
	NSString *companyName;
	if ([name rangeOfString:@"dunkin"].location != NSNotFound)
		companyName = @"Dunkin Donuts";
	else if ([name rangeOfString:@"starbuck"].location != NSNotFound)
		companyName = @"Starbucks";
	else
		companyName = @"Generic";

	return companyName;
}


+(BOOL)checkIfContactAdded
{
	
	//this will only check to see if the UserDefaults have the first name,last name and #
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTNAME"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"LASTNAME"])
		return YES;
	else
		return NO;
}


+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

// for Debug -- prints contents of NSDictionary
+(void)printDict:(NSDictionary *)ddict {
	NSLog(@"---printing Dictionary---");
	NSArray *keys = [ddict allKeys];
	for (id key in keys) {
        #if debug
		NSLog(@"   key = %@     value = %@",key,[ddict objectForKey:key]);
        #endif
	}	
}
@end
