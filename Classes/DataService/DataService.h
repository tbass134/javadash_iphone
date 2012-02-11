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

-(BOOL)addUser:(NSString *)userName  deviceID:(NSString *)deviceid email:(NSString *)email emailEnabled:(BOOL)enableEmail facebookID:(NSString *)fbid enablePush:(BOOL)enable_push;
-(BOOL)startRunWithDict:(NSDictionary *)dash_dict;
-(BOOL)placeOrder:(NSString *)run_id order:(NSString *)order updateOrder:(NSString *)update_order orderID:(NSString *)order_id;
-(BOOL)completerun:(NSString *)deviceid runID:(NSString *)run_id;
-(BOOL)leaverun:(NSString *)deviceid runID:(NSString *)run_id;
-(BOOL)deleteOrder:(NSString *)order_id;

-(NSDictionary *)getFacebookUsersOfApp;
-(BOOL)purchaseApp;
+ (DataService*)sharedDataService;
@end
