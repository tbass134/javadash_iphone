//
//  NSMutableArray+SCRQueue.m
//  TouchCustoms
//
//  Created by Aleks Nesterow-Rutkowski on 2/7/10.
//	aleks@screencustoms.com
//

#import "NSMutableArray+SCRQueue.h"

@implementation NSMutableArray (SCRQueue)

- (void)enqueue:(id)object {

	[self insertObject:object atIndex:0];
}

- (id)dequeue {
	
	id lastObject = [self lastObject];
	[self removeLastObject];
	return lastObject;
}

@end
