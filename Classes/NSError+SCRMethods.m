//
//  NSError+SCRMethods.m
//  TouchCustoms
//
//  Created by Aleks Nesterow-Rutkowski on 3/14/10.
//	aleks@screencustoms.com
//

#import "NSError+SCRMethods.h"

@implementation NSError (SCRMethods)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code
				 description:(NSString *)description failureReason:(NSString *)failureReason {
	
	NSError *result = [NSError errorWithDomain:domain code:code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																		  description, NSLocalizedDescriptionKey,
																		  failureReason, NSLocalizedFailureReasonErrorKey,
																		  nil]];
	return result;
}

@end
