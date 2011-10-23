//
//  NSMutableArray+SCRQueue.h
//  TouchCustoms
//
//  Created by Aleks Nesterow-Rutkowski on 2/7/10.
//	aleks@screencustoms.com
//

@interface NSMutableArray (SCRQueue)

- (void)enqueue:(id)object;
- (id)dequeue;

@end
