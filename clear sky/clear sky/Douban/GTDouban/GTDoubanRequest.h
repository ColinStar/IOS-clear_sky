//
//  GTDoubanRequest.h
//   
//
//  Created by GTL on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBUtil.h"
#import "JSON.h"
#import "GTDoubanHeader.h"

typedef enum
{
    kGTRequestPostDataTypeNone,
	kGTRequestPostDataTypeNormal,			// for normal data post, such as "user=name&password=psd"
	kGTRequestPostDataTypeMultipart,        // for uploading images and files.
}GTDoubanRequestPostDataType;


@class GTDoubanRequest;

@protocol GTDoubanRequestDelegate <NSObject>
@optional

- (void)request:(GTDoubanRequest *)request didFailWithError:(NSError *)error;
- (void)request:(GTDoubanRequest *)request didFinishLoadingWithResult:(id)result;

@end

@interface GTDoubanRequest : NSObject {
    id<GTDoubanRequestDelegate>   delegate;
    NSString                *url;
    NSString                *httpMethod;
    NSDictionary            *params;
    GTDoubanRequestPostDataType   postDataType;
    NSDictionary            *httpHeaderFields;
    NSURLConnection         *connection;
    NSMutableData           *responseData;
}
@property (nonatomic, assign) id<GTDoubanRequestDelegate> delegate;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSDictionary *params;
@property GTDoubanRequestPostDataType postDataType;
@property (nonatomic, retain) NSDictionary *httpHeaderFields;

+ (GTDoubanRequest *)requestWithURL:(NSString *)url 
                   httpMethod:(NSString *)httpMethod 
                       params:(NSDictionary *)params
                 postDataType:(GTDoubanRequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id<GTDoubanRequestDelegate>)delegate;

+ (GTDoubanRequest *)requestWithAccessToken:(NSString *)accessToken
                                  url:(NSString *)url
                           httpMethod:(NSString *)httpMethod 
                               params:(NSDictionary *)params
                         postDataType:(GTDoubanRequestPostDataType)postDataType
                     httpHeaderFields:(NSDictionary *)httpHeaderFields
                             delegate:(id<GTDoubanRequestDelegate>)delegate;

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;

- (void)connect;
- (void)disconnect;

@end
