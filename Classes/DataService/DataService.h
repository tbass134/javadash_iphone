//
//  DataService.h
//  OnlySimchas
//
//  Created by Matt Ripston on 9/27/11.
//  Copyright 2011 RustyBrick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataService : NSObject{
    NSString *urlPrefix;
}
-(BOOL)getOrders;
+ (DataService*)sharedDataService;
@end
