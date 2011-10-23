//
//  NSArray+Linq.h
//  TouchCustoms
//
//  Created by Aleks Nesterow-Rutkowski on 8/10/10.
//	aleks@screencustoms.com
//	
//	Purpose
//	Contains LINQ-like operators for arrays.
//

@interface NSArray (Linq)

+ (id)aggregate:(NSArray *)array usingBlock:(id (^)(id accumulator, id currentItem))block;
- (id)aggregateUsingBlock:(id (^)(id accumulator, id currentItem))block;

+ (NSArray *)select:(NSArray *)array usingBlock:(id (^)(id currentItem))block;
- (NSArray *)selectUsingBlock:(id (^)(id currentItem))block;

@end
