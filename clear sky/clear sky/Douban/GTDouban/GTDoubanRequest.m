//
//  GTDoubanRequest.m
//   
//
//  Created by GTL on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTDoubanRequest.h"

@interface GTDoubanRequest (Private)
+ (NSString *)stringFromDictionary:(NSDictionary *)dict;
+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString;

- (NSMutableData *)postBody;
- (void)handleResponseData:(NSData *)data;
- (id)parseJSONData:(NSData *)data error:(NSError **)error;
- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;
- (void)failedWithError:(NSError *)error;

@end

@implementation GTDoubanRequest

@synthesize url;
@synthesize httpMethod;
@synthesize params;
@synthesize postDataType;
@synthesize httpHeaderFields;
@synthesize delegate;

#pragma mark Life Circle
- (void)dealloc {
    [url release], url = nil;
    [httpMethod release], httpMethod = nil;
    [params release], params = nil;
    [httpHeaderFields release], httpHeaderFields = nil;
    [responseData release];
	responseData = nil;
    [connection cancel];
    [connection release], connection = nil;
    [super dealloc];
}

#pragma mark Private Methods
+ (NSString *)stringFromDictionary:(NSDictionary *)dict {
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator]) {
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]])) {
			continue;
		}
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dict objectForKey:key] URLEncodedString]]];
	}
	return [pairs componentsJoinedByString:@"&"];
}

+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString {
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSMutableData *)postBody {
    NSMutableData *body = [NSMutableData data];
    if (postDataType == kGTRequestPostDataTypeNormal) {
        [GTDoubanRequest appendUTF8Body:body dataString:[GTDoubanRequest stringFromDictionary:params]];
    }
    else if (postDataType == kGTRequestPostDataTypeMultipart) {
        NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", kGTRequestStringBoundary];
		NSString *bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", kGTRequestStringBoundary];
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        [GTDoubanRequest appendUTF8Body:body dataString:bodyPrefixString];
        for (id key in [params keyEnumerator]) {
			if (([[params valueForKey:key] isKindOfClass:[UIImage class]]) || ([[params valueForKey:key] isKindOfClass:[NSData class]])) {
				[dataDictionary setObject:[params valueForKey:key] forKey:key];
				continue;
			}
			[GTDoubanRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [params valueForKey:key]]];
			[GTDoubanRequest appendUTF8Body:body dataString:bodyPrefixString];
		}
		if ([dataDictionary count] > 0) {
			for (id key in dataDictionary) {
				NSObject *dataParam = [dataDictionary valueForKey:key];
				if ([dataParam isKindOfClass:[UIImage class]]) {
					NSData* imageData = UIImagePNGRepresentation((UIImage *)dataParam);
					[GTDoubanRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.png\"\r\n", key]];
					[GTDoubanRequest appendUTF8Body:body dataString:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
					[body appendData:imageData];
				} 
				else if ([dataParam isKindOfClass:[NSData class]]) {
                    [GTDoubanRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"*.*\"\r\n", key]];
					[GTDoubanRequest appendUTF8Body:body dataString:@"Content-Type: image/jpeg\n\n"];
					[body appendData:(NSData*)dataParam];
				}
				[GTDoubanRequest appendUTF8Body:body dataString:bodySuffixString];
			}
		}
    }
    return body;
}

- (void)handleResponseData:(NSData *)data {
	NSError* error = nil;
	id result = [self parseJSONData:data error:&error];
	if (error) {
		[self failedWithError:error];
	} 
	else {
        if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)]) {
            [delegate request:self didFinishLoadingWithResult:(result == nil ? data : result)];
		}
	}
}

- (id)parseJSONData:(NSData *)data error:(NSError **)error {
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"dataString:%@", dataString);
	SBJSON *jsonParser = [[SBJSON alloc]init];
	NSError *parseError = nil;
	id result = [jsonParser objectWithString:dataString error:&parseError];
	if (parseError) {
        if (error != nil) {
            *error = [self errorWithCode:kGTErrorCodeSDK
                                userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kGTSDKErrorCodeParseError] forKey:kGTSDKErrorCodeKey]];
        }
	}
	[dataString release];
	[jsonParser release];
	
	if ([result isKindOfClass:[NSDictionary class]]) {
		if ([result objectForKey:@"error_code"] != nil && [[result objectForKey:@"error_code"] intValue] != 200) {
			if (error != nil) {
				*error = [self errorWithCode:kGTErrorCodeInterface userInfo:result];
			}
		}
	}
	return result;
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:kGTSDKErrorDomain code:code userInfo:userInfo];
}

- (void)failedWithError:(NSError *)error {
	if ([delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[delegate request:self didFailWithError:error];
	}
}

#pragma mark Public Methods
+ (GTDoubanRequest *)requestWithURL:(NSString *)url 
                   httpMethod:(NSString *)httpMethod 
                       params:(NSDictionary *)params
                 postDataType:(GTDoubanRequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id<GTDoubanRequestDelegate>)delegate {
    
    GTDoubanRequest *request = [[[GTDoubanRequest alloc] init] autorelease];
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.postDataType = postDataType;
    request.httpHeaderFields = httpHeaderFields;
    request.delegate = delegate;
    return request;
}

+ (GTDoubanRequest *)requestWithAccessToken:(NSString *)accessToken
                                  url:(NSString *)url
                           httpMethod:(NSString *)httpMethod 
                               params:(NSDictionary *)params
                         postDataType:(GTDoubanRequestPostDataType)postDataType
                     httpHeaderFields:(NSDictionary *)httpHeaderFields
                             delegate:(id<GTDoubanRequestDelegate>)delegate {
    // add the access token field
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParams setObject:accessToken forKey:@"access_token"];
    return [GTDoubanRequest requestWithURL:url
                          httpMethod:httpMethod
                              params:mutableParams
                        postDataType:postDataType 
                    httpHeaderFields:httpHeaderFields
                            delegate:delegate];
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod {
    if (![httpMethod isEqualToString:@"GET"]) {
        return baseURL;
    }
    
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
	NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString *query = [GTDoubanRequest stringFromDictionary:params];
	NSLog(@"query:%@", query);
	return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

- (void)connect {
    NSString *urlString = [GTDoubanRequest serializeURL:url params:params httpMethod:httpMethod];
    NSLog(@"urlString:%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:kGTRequestTimeOutInterval];
    if (postDataType == kGTRequestPostDataTypeMultipart || postDataType == kGTRequestPostDataTypeNormal) {
        NSString *accessToken = [params objectForKey:@"access_token"];
        NSString *authValue = [NSString stringWithFormat:@"%@ %@", @"Bearer", accessToken];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    [request setHTTPMethod:httpMethod];
    if ([httpMethod isEqualToString:@"POST"]) {
        if (postDataType == kGTRequestPostDataTypeMultipart) {
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kGTRequestStringBoundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
        NSData *data = [self postBody];
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"dataString:%@", dataString);
        [request setHTTPBody:[self postBody]];
    }
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)disconnect {
    [responseData release];
	responseData = nil;
    [connection cancel];
    [connection release], connection = nil;
}

#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
	[self handleResponseData:responseData];
    
	[responseData release];
	responseData = nil;
    [connection cancel];
	[connection release];
	connection = nil;
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
	[self failedWithError:error];
	
	[responseData release];
	responseData = nil;
    [connection cancel];
	[connection release];
	connection = nil;
}

@end
