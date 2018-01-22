
//
//  MyURLProtocol.m
//  CacheURLResponse
//
//  Created by Karthi A on 21/01/18.
//  Copyright © 2018 Karthi A. All rights reserved.
//

#import "AKURLProtocol.h"
#import "CachedURLResponse+CoreDataClass.h"
#import "AppDelegate.h"

@interface AKURLProtocol () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@end

@implementation AKURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    static NSUInteger requestCount = 0;
    if ([AKURLProtocol propertyForKey:@"MyURLProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    NSLog(@"Request #%u: URL = %@", requestCount++, request.URL.absoluteString);
    return YES;
}
#pragma Mark NSProtocalReq Abstract
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    CachedURLResponse *cachedResponse = [self cachedResponseForCurrentRequest];
    if (cachedResponse) {
        NSData *data = cachedResponse.data;
        NSString *mimeType = cachedResponse.mimeType;
        NSString *encoding = cachedResponse.encoding;
        
        NSURLResponse *response  =  [[NSURLResponse alloc]initWithURL:self.request.URL MIMEType:mimeType expectedContentLength:data.length textEncodingName:encoding];
        
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
        NSLog(@"cachedResponse");
    }
    else
    {
        NSLog(@"new request");
        [AKURLProtocol setProperty:@"YES" forKey:@"MyURLProtocolHandledKey" inRequest:self.request];
        self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    }
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
}
#pragma Mark URLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    self.response = response;
    self.mutableData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self.mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    [self saveCachedResponse];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}
#pragma Mart -hanlde cache data
- (void)saveCachedResponse {
    NSLog(@"saving cached response");
    
    // 1.
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    // 2.
    CachedURLResponse *cachedResponse = [NSEntityDescription insertNewObjectForEntityForName:@"CachedURLResponse"
                                                                      inManagedObjectContext:context];
    cachedResponse.data = self.mutableData;
    cachedResponse.url = self.request.URL.absoluteString;
    cachedResponse.timestamp = [NSDate date];
    cachedResponse.mimeType = self.response.MIMEType;
    cachedResponse.encoding = self.response.textEncodingName;
    
    // 3.
    NSError *error;
    BOOL const success = [context save:&error];
    if (!success) {
        NSLog(@"Could not cache the response.");
    }
}
- (CachedURLResponse *)cachedResponseForCurrentRequest {
    // 1.
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    // 2.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CachedURLResponse"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // 3.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", self.request.URL.absoluteString];
    [fetchRequest setPredicate:predicate];
    
    // 4.
    NSError *error;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    // 5.
    if (result && result.count > 0) {
        return result[0];
    }
    
    return nil;
}
@end
