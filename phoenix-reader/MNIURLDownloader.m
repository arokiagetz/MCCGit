//
//  MNIURLDownloader.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/7/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#define CERT_PASSPHRASE "!C@lif0rniaDr3amng"

#import "MNIURLDownloader.h"

@implementation MNIURLDownloader

- (id)initWithSession:(NSURLSession *)session
{
    if (self = [super init]) {
        _session = session;
    }
    return self;
}

- (NSURLSession *)session
{
    if (_session != nil) {
        return _session;
    }
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    return _session;
}

- (void)downloadDataFromUrl:(NSURL *)url withDelegate:(id)delegate
{
    _delegate = delegate;
    [self downloadDataFromUrl:url withSuccessBlock:nil andFailureBlock:nil];
}

- (void)downloadDataFromUrl:(NSURL *)url withSuccessBlock:(void (^)(NSData *data))success andFailureBlock:(void (^)(NSError *error))failure
{
    __weak MNIURLDownloader *weakSelf = self;
    __block void (^successBlock)(NSData *) = [success copy];
    __block void (^failureBlock)(NSError *) = [failure copy];
   
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
   
    _dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,  NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (!weakSelf) { return; }
        
        if (error) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didFailWithError:)]) {
                [weakSelf.delegate performSelector:@selector(didFailWithError:) withObject:error];
            }
            if (failureBlock)
                failureBlock(error);
            
            return;
        }
    
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (statusCode < 200 || statusCode >= 400) {
                NSError *httpError = [self customErrorWith:statusCode];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didFailWithError:)]) {
                    [weakSelf.delegate performSelector:@selector(didFailWithError:) withObject:httpError];
                }
                if (failureBlock)
                    failureBlock(httpError);
                
                return;
            }
        
        }
        // all seems legit, call success
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didReceiveData:)]) {
            [weakSelf.delegate performSelector:@selector(didReceiveData:) withObject:data];
        }
        if (successBlock)
            successBlock(data);
        
    }];
    [_dataTask resume];
}

/* -cancel returns immediately, but marks a task as being canceled.
 * The task will signal -URLSession:task:didCompleteWithError: with an
 * error value of { NSURLErrorDomain, NSURLErrorCancelled }.  In some
 * cases, the task may signal other work before it acknowledges the
 * cancelation.  -cancel may be sent to a task that has been suspended.
 */

- (void)cancel
{
    if (_dataTask != nil)
        [_dataTask cancel];
}

/*
When there's no internet connection, nsurlsession task fails with error :
{Error Domain=NSURLErrorDomain Code=-1009 "The Internet connection appears to be offline." UserInfo={NSUnderlyingError=0x7fd439702930 {Error Domain=kCFErrorDomainCFNetwork Code=-1009 "(null)" UserInfo={_kCFStreamErrorCodeKey=8, _kCFStreamErrorDomainKey=12}}, NSErrorFailingURLStringKey=http://www.google.com/, NSErrorFailingURLKey=http://www.google.com/, _kCFStreamErrorDomainKey=12, _kCFStreamErrorCodeKey=8, NSLocalizedDescription=The Internet connection appears to be offline.}
*/

// FIXME
//helpers, centrilize later...

- (NSError *)customErrorWith:(NSInteger)statusCode
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:statusCode]};
    NSError *error = [NSError errorWithDomain:@"MNIHTTPStatusError"
                                         code:statusCode
                                     userInfo:userInfo];
    return error;
}



#pragma mark Certificate Support
#pragma mark - NSURLSessionDelegate
// Certificate support, mainly apple code...

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        
        // Load Certificate
        NSString *path = [[NSBundle mainBundle] pathForResource:@"mobile-cert" ofType:@"p12"];
        NSData *p12data = [NSData dataWithContentsOfFile:path];
        CFDataRef inP12data = (__bridge CFDataRef)p12data;
        
        SecIdentityRef myIdentity;
        SecTrustRef myTrust;
        extractIdentityAndTrust(inP12data, &myIdentity, &myTrust);
        
        SecCertificateRef myCertificate;
        SecIdentityCopyCertificate(myIdentity, &myCertificate);
        const void *certs[] = { myCertificate };
        CFArrayRef certsArray = CFArrayCreate(NULL, certs, 1, NULL);
        
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:myIdentity certificates:(__bridge NSArray*)certsArray persistence:NSURLCredentialPersistenceForSession];
        
        if ( credential == nil )
        {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace,nil);
        }
        else
        {
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
        
    }
    
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        
    }
    
    
}


//C Method extractIdentityAndTrust
OSStatus extractIdentityAndTrust(CFDataRef inP12data, SecIdentityRef *identity, SecTrustRef *trust)
{
    OSStatus securityError = errSecSuccess;
    
    CFStringRef password = CFSTR(CERT_PASSPHRASE);
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12data, options, &items);
    
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemTrust);
        *trust = (SecTrustRef)tempTrust;
    }
    
    if (options) {
        CFRelease(options);
    }
    
    return securityError;
}


@end
