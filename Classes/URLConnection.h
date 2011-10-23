#import <Foundation/Foundation.h>
@protocol URLConnectionDelegate <NSObject>
@required
- (void)processSuccessful:(BOOL)success withTag:(NSString *)tag andData:(NSMutableData *)data;
@end


@interface URLConnection : NSURLConnection 
{
	id <URLConnectionDelegate> delegate;
	NSMutableData *receivedData;
	NSString *tag;
	NSDictionary *dict;
	BOOL success;
}
@property (nonatomic,retain)NSString *tag;
@property (nonatomic,retain)NSDictionary *dict;
@property (retain) id delegate;
-(void)initWithRequest:(NSURLRequest *)request;
@end