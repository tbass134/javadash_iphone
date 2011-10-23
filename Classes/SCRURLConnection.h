extern NSString * const kSCRURLConnectionDomain;

enum
{
    SCRURLConnectionCancelled = 1001,
    SCRURLConnectionFailedToInitialize = 1002,
    SCRURLConnectionFailedWithError = 1003
};
typedef NSUInteger SCRURLConnectionErrorType;

@class SCRURLConnection;

typedef void (^ SCRURLCompletedHandler)(SCRURLConnection *connection, NSURLResponse *response, NSData *data);
typedef void (^ SCRURLFailedHandler)(SCRURLConnection *connection, NSError *error);

@interface SCRURLConnection : NSObject <NSURLConnectionDelegate> {
    
@private
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSURLResponse *_response;
    SCRURLCompletedHandler _completedHandler;
    SCRURLFailedHandler _failedHandler;
    
    BOOL _failed;
}

- (id)initWithRequest:(NSURLRequest *)request completedHandler:(SCRURLCompletedHandler)completedHandler
        failedHandler:(SCRURLFailedHandler)failedHandler;
- (id)initWithURL:(NSURL *)url timeoutInterval:(NSTimeInterval)timeoutInterval
 completedHandler:(SCRURLCompletedHandler)completedHandler failedHandler:(SCRURLFailedHandler)failedHandler;
- (void)cancel;

@end

@interface NSError (SCRURLConnectionExtensions) 

- (BOOL)SCRURLConnectionIsCancelled;

@end
