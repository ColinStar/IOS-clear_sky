//
//  GTDouban.h
//   
//
//  Created by admin on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTDoubanAuthor.h"
#import "GTDoubanRequest.h"

@class GTDouban;

@protocol GTDoubanDelegate <NSObject>

@optional
- (void)engineAlreadyLoggedIn:(GTDouban *)engine;
- (void)engineDidLogOut:(GTDouban *)engine;
- (void)engineNotAuthorized:(GTDouban *)engine;
- (void)engineAuthorizeExpired:(GTDouban *)engine;

- (void)engineDidLogIn:(GTDouban *)engine;
- (void)engine:(GTDouban *)engine didFailToLogInWithError:(NSError *)error;
- (void)engine:(GTDouban *)engine didCancel:(BOOL)cancel;

- (void)engine:(GTDouban *)engine requestDidFailWithError:(NSError *)error;
- (void)engine:(GTDouban *)engine requestDidSucceedWithResult:(id)result;

@end

@interface GTDouban : NSObject <GTDoubanAuthorDelegate, GTDoubanRequestDelegate> {
    id<GTDoubanDelegate> delegate;
    NSString        *appKey;
    NSString        *appSecret;
    NSString        *userID;
    NSString        *accessToken;
    NSTimeInterval  expireTime;
    NSString        *redirectURI;    
    // Determine whether user must log out before another logging in.
    BOOL            isUserExclusive;    
    GTDoubanRequest       *request;
    GTDoubanAuthor     *authorize;    
    NSInteger tag;
}
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, assign) NSTimeInterval expireTime;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, assign) BOOL isUserExclusive;
@property (nonatomic, retain) GTDoubanRequest *request;
@property (nonatomic, retain) GTDoubanAuthor *authorize;
@property (nonatomic, assign) id<GTDoubanDelegate> delegate;

- (void)logIn;
- (void)logOut;

- (BOOL)isLoggedIn;
- (BOOL)isAuthorizeExpired;

- (void)sendWeiBoWithText:(NSString *)text;
- (void)sendWeiBoWithText:(NSString *)text imageData:(NSData *)imageData;
- (void)sendWeiBoWithParams:(NSDictionary *)params;
- (void)getFriendShips;
- (void)createFriendWithUserId:(NSString *)_userId;
- (void)getUserInfo;

@end
