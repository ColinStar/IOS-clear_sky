//
//  GTDoubanAuthor.h
//   
//
//  Created by GTL on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTDoubanLoginView.h"
#import "GTDoubanRequest.h"

@class GTDoubanAuthor;

@protocol GTDoubanAuthorDelegate <NSObject>
@required
- (void)authorize:(GTDoubanAuthor *)authorize didSucceedWithAccessToken:(NSString *)accessToken userID:(NSString *)userID expiresIn:(NSInteger)seconds;
- (void)authorize:(GTDoubanAuthor *)authorize didFailWithError:(NSError *)error;
- (void)authorize:(GTDoubanAuthor *)authorize didCancel:(BOOL)cancel;
@end

@interface GTDoubanAuthor : NSObject  <GTDoubanLoginViewDelegate, GTDoubanRequestDelegate> {
    NSString    *appKey;
    NSString    *appSecret;
    GTDoubanRequest   *request;
    id<GTDoubanAuthorDelegate> delegate;
}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) GTDoubanRequest *request;
@property (nonatomic, assign) id<GTDoubanAuthorDelegate> delegate;

- (void)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;
- (void)startAuthorize;

@end
