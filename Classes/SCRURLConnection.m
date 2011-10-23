#import "SCRURLConnection.h"
#import "SCRMemoryManagement.h"

NSString *const kSCRURLConnectionDomain = @"com.screencustoms.SCRURLConnection.ErrorDomain";

@interface SCRURLConnection (/* Private methods */)

- (void)reportError:(NSError *)error;

@end

@implementation SCRURLConnection

- (id)initWithRequest:(NSURLRequest *)request completedHandler:(SCRURLCompletedHandler)completedHandler
        failedHandler:(SCRURLFailedHandler)failedHandler {
    
    self = [super init];
    
    if (self) {
        
        _completedHandler = [completedHandler copy];
        _failedHandler = [failedHandler copy];
        
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (!_connection)
        {
            NSError *error = [NSError errorWithDomain:kSCRURLConnectionDomain code:SCRURLConnectionFailedToInitialize
                                             userInfo:nil];
            [self reportError:error];
        }
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url timeoutInterval:(NSTimeInterval)timeoutInterval
 completedHandler:(SCRURLCompletedHandler)completedHandler failedHandler:(SCRURLFailedHandler)failedHandler
{
    return [self initWithRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:timeoutInterval] completedHandler:completedHandler failedHandler:failedHandler];
}

- (void)dealloc
{
    SCR_RELEASE_SAFELY(_connection);
    SCR_RELEASE_SAFELY(_data);
    SCR_RELEASE_SAFELY(_response);
    SCR_RELEASE_SAFELY(_completedHandler);
    SCR_RELEASE_SAFELY(_failedHandler);
    
    [super dealloc];
}

- (void)cancel
{
    [_connection cancel];
    
    NSError *error = [NSError errorWithDomain:kSCRURLConnectionDomain code:SCRURLConnectionCancelled userInfo:nil];
    [self reportError:error];
}

- (void)reportError:(NSError *)error
{
    if (!_failed)
    {
        _failed = YES;
        
        if (_failedHandler)
        {
            _failedHandler(self, error);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    SCR_RELEASE_SAFELY(_data);
    SCR_RELEASE_SAFELY(_response);
    
    _response = [response retain];
    
    long long expectedContentLength = response.expectedContentLength;
    
    if (expectedContentLength > NSUIntegerMax)
    {
        [self cancel];
    }
    else
    {
        NSUInteger capacity;
        
        if (expectedContentLength < 0)
        {
            capacity = 1024;
        }
        else
        {
            capacity = (NSUInteger)expectedContentLength;
        }
        
        _data = [[NSMutableData alloc] initWithCapacity:capacity];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_completedHandler)
    {
        _completedHandler(self, _response, _data);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self reportError:[NSError errorWithDomain:kSCRURLConnectionDomain code:SCRURLConnectionFailedWithError 
                                      userInfo:[NSDictionary dictionaryWithObject:error forKey:NSUnderlyingErrorKey]]];
}

@end


@implementation NSError (SCRURLConnectionExtensions)

- (BOOL)SCRURLConnectionIsCancelled
{
    BOOL result = [[self domain] isEqualToString:kSCRURLConnectionDomain] && SCRURLConnectionCancelled == [self code];
    return result;
}

@end
