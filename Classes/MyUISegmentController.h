//
//  MyUISegmentController.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 6/15/11.
//  Copyright 2011 Dark Bear Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCRSegmentedControl.h"
#import "SCRMemoryManagement.h"


@interface MyUISegmentController : SCRSegmentedControl {

	NSString *selected_key;
}
@property(nonatomic,retain)NSString *selected_key;
@end
