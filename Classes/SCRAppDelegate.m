//
//  SCRAppDelegate.m
//  TouchCustoms
//
//  Created by Aleks Nesterow-Rutkowski on 2/25/10.
//	aleks@screencustoms.com
//

#import "SCRAppDelegate.h"

@implementation SCRAppDelegate

static int _ActivityCount = 0;
+ (void)showActivityIndicator
{	
	if (!_ActivityCount)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	
	_ActivityCount++;
}

+ (void)hideActivityIndicator {
	
	_ActivityCount = MAX(_ActivityCount - 1, 0);

	if (!_ActivityCount)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

/** @Overridden
  * We are using NSUserDefaults to store user settings, so it's quite natural to store at this point
  * the values set while the application was running.
  * 
  * If such behavior is harmful for your application, override this method or do not inherit from
  * SCRAppDelegate at all. */
- (void)applicationWillTerminate:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
