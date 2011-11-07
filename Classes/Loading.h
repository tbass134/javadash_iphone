//
//  Loading.h
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "TapkuLibrary.h"

@interface Loading : UIView {
TKLoadingView *loading;
	UIView *mainView;
	NSString *mes;
}
@property (readonly) TKLoadingView *loading;
-(void)showLoading:(NSString *)message inView:(UIView *)view;
-(void)hideLoading;
@end
