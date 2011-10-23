//
//  Loading.m
//  CoffeeRunSample
//
//  Created by Antonio Hung on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Loading.h"


@implementation Loading


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}
-(void)showLoading:(NSString *)message inView:(UIView *)view;
{
	mainView = view;
	mes = message;
	[mainView addSubview:self.loading];
}
-(void)hideLoading
{
	[self.loading removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
- (TKLoadingView *) loading{
	if(loading==nil){
		loading  = [[TKLoadingView alloc] initWithTitle:mes];
		[loading startAnimating];
		loading.center = CGPointMake(mainView.bounds.size.width/2, mainView.bounds.size.height/2);
	}
	return loading;
}

- (void)dealloc {
    [super dealloc];
}


@end
