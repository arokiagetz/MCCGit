//
//  MNIURLDownloader.h
//  phoenix-reader
//
//  Created by Yann Duran on 3/7/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^MNIURLDownloaderCompletionBlock)(id responseResult, NSError *error, BOOL success);

@protocol  MNIURLDownloaderDelegate <NSObject>
@optional

- (void)didReceiveData:(NSData *)data;
- (void)didFailWithError:(NSError *)error;

@end

@interface MNIURLDownloader : NSObject <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, weak) id <MNIURLDownloaderDelegate> delegate;

- (id)initWithSession:(NSURLSession *)session;
- (void)downloadDataFromUrl:(NSURL *)url withDelegate:(id)delegate;
- (void)downloadDataFromUrl:(NSURL *)url withSuccessBlock:(void (^)(NSData *data))success andFailureBlock:(void (^)(NSError *error))failure;
- (void)cancel;

@end
