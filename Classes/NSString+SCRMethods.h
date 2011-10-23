//
//  NSString+SCRMethods.h
//  TouchCustoms
//
//  Created by Aleks Nesterow-Rutkowski on 7/19/09.
//  aleks@screencustoms.com
//  
//  Purpose
//  Extension methods for NSString.
//

@interface NSString (SCRMethods)

+ (BOOL)isNullOrEmpty:(NSString *)aString;
+ (NSString *)stringFromInteger:(NSInteger)anInteger;
+ (NSString *)stringFromDouble:(double)aDouble;
- (NSString *)stringByAddingPercentEscapes;
- (NSString *)stringByTruncatingWith:(NSString *)truncateString measuringAgainstFont:(UIFont *)font
							forWidth:(CGFloat)width;
+ (CGFloat)widthOfString:(NSString *)aString withFont:(UIFont *)font;

@end
