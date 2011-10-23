//
//  NSError+SCRMethods.h
//  TouchCustoms
//
//  Created by Aleks Nesterow-Rutkowski on 3/14/10.
//	aleks@screencustoms.com
//	
//	Purpose
//	Extension methods for NSError.
//

@interface NSError (SCRMethods)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code
				 description:(NSString *)description failureReason:(NSString *)failReason;

@end
