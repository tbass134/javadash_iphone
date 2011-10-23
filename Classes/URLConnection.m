//
//  URLConnection.m
//  Testing
//
//  Created by Antonio Hung on 2/9/11.
//  Copyright 2011 MRM Worldwide. All rights reserved.
//

#import "URLConnection.h"
#import "Utils.h"


@implementation URLConnection
@synthesize delegate;
@synthesize tag;
@synthesize dict;
-(void)initWithRequest:(NSURLRequest *)request
{
	if([Utils checkIfContactAdded])
	{
		
		NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (theConnection) {
			receivedData = [[NSMutableData data] retain];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			
			
		} else {
			
			// Inform the user that the connection failed.
			printf("Failed");
			
			[[self delegate] processSuccessful:NO withTag:tag andData:receivedData];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
	}
	else {
		[[self delegate] processSuccessful:NO withTag:tag andData:receivedData];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}

}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[receivedData setLength:0];	
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];	
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[connection release];
    [receivedData release];
	[[self delegate] processSuccessful:NO withTag:tag andData:receivedData];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSLog(@"Connection failed! Error - %@ %@",[error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[[self delegate] processSuccessful:YES withTag:tag andData:receivedData];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	[connection release];
    [receivedData release];
}

@end
