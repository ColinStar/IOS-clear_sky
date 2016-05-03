//
//  GTDouban.m
//   
//
//  Created by admin on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTDouban.h"
#import "GTDoubanHeader.h"

@interface GTDouban (Private)
- (NSString *)weiboAuthorPath;
- (void)saveAuthorizeDataToKeychain;
- (void)readAuthorizeDataFromKeychain;
- (void)deleteAuthorizeDataInKeychain;
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(GTDoubanRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields;

@end


@implementation GTDouban

@synthesize tag;
@synthesize appKey;
@synthesize appSecret;
@synthesize userID;
@synthesize accessToken;
@synthesize expireTime;
@synthesize redirectURI;
@synthesize isUserExclusive;
@synthesize request;
@synthesize authorize;
@synthesize delegate;

#pragma mark - GTDouban Life Circle
- (id)init {
    if (self = [super init]) {
        self.appKey = kGTAppKey;
        self.appSecret = kGTAppSecret;    
        self.redirectURI = kGTRedirectURI;
        isUserExclusive = NO;        
        [self readAuthorizeDataFromKeychain];
    }
    return self;
}

- (void)dealloc {
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    [userID release], userID = nil;
    [accessToken release], accessToken = nil;
    [redirectURI release], redirectURI = nil;
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;    
    [authorize setDelegate:nil];
    [authorize release], authorize = nil;    
    delegate = nil;
    [super dealloc];
}

#pragma mark - GTDouban Private Methods
- (NSString *)weiboAuthorPath {
	NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
    NSString *pathString = [NSString stringWithFormat:@"/%@AuthorToken.plist", SHARENAME];
	NSString *sendListPath = [documentsDir stringByAppendingPathComponent:pathString];
	return sendListPath;
}


- (void)saveAuthorizeDataToKeychain {
    NSString *sinaPath = [self weiboAuthorPath];
    NSMutableDictionary *sinaTokenDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    [sinaTokenDic setObject:userID forKey:kGTDoubanUserID];
    [sinaTokenDic setObject:accessToken forKey:kGTDoubanAccessToken];
    [sinaTokenDic setObject:[NSString stringWithFormat:@"%lf", expireTime] forKey:kGTDoubanExpireTime];
    [sinaTokenDic writeToFile:sinaPath atomically:YES];
    [sinaTokenDic release];
}

- (void)readAuthorizeDataFromKeychain {
    NSString *sinaPath = [self weiboAuthorPath];
	NSMutableDictionary *sinaTokenDic = [[NSMutableDictionary alloc] initWithContentsOfFile:sinaPath];
    self.userID = [sinaTokenDic objectForKey:kGTDoubanUserID];
	self.accessToken = [sinaTokenDic objectForKey:kGTDoubanAccessToken];
	self.expireTime = [[sinaTokenDic objectForKey:kGTDoubanExpireTime] doubleValue];
    [sinaTokenDic release];
}

- (void)deleteAuthorizeDataInKeychain {
    self.userID = @"";
    self.accessToken = @"";
    self.expireTime = 0;    
    NSString *sinaPath = [self weiboAuthorPath];
    NSMutableDictionary *sinaTokenDic = [[NSMutableDictionary alloc] initWithContentsOfFile:sinaPath];
    [sinaTokenDic removeAllObjects];
    [sinaTokenDic setObject:userID forKey:kGTDoubanUserID];
    [sinaTokenDic setObject:accessToken forKey:kGTDoubanAccessToken];
    [sinaTokenDic setObject:[NSString stringWithFormat:@"%lf", expireTime] forKey:kGTDoubanExpireTime];
    [sinaTokenDic writeToFile:sinaPath atomically:YES];
    [sinaTokenDic release];
}

#pragma mark - GTDouban Public Methods
#pragma mark Authorization
- (void)logIn {
    if ([self isLoggedIn]) {
        if ([delegate respondsToSelector:@selector(engineAlreadyLoggedIn:)]) {
            [delegate engineAlreadyLoggedIn:self];
        }
        if (isUserExclusive) {
            return;
        }
    }
    
    GTDoubanAuthor *auth = [[GTDoubanAuthor alloc] init];
    [auth setDelegate:self];
    self.authorize = auth;
    [auth release];
    [authorize startAuthorize];
}

- (void)logOut {
    [self deleteAuthorizeDataInKeychain];    
    if ([delegate respondsToSelector:@selector(engineDidLogOut:)]) {
        [delegate engineDidLogOut:self];
    }
}

- (BOOL)isLoggedIn {
    return userID && accessToken && (expireTime > 0);
}

- (BOOL)isAuthorizeExpired {
    if ([[NSDate date] timeIntervalSince1970] > expireTime) {
        // force to log out
        [self deleteAuthorizeDataInKeychain];
        return YES;
    }
    return NO;
}

#pragma mark - GTDoubanAuthorDelegate Methods
- (void)authorize:(GTDoubanAuthor *)authorize didSucceedWithAccessToken:(NSString *)theAccessToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds {
    self.accessToken = theAccessToken;
    self.userID = theUserID;
    self.expireTime = [[NSDate date] timeIntervalSince1970] + seconds;    
    [self saveAuthorizeDataToKeychain];
    if ([delegate respondsToSelector:@selector(engineDidLogIn:)]) {
        [delegate engineDidLogIn:self];
    }
}

- (void)authorize:(GTDoubanAuthor *)authorize didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(engine:didFailToLogInWithError:)]) {
        [delegate engine:self didFailToLogInWithError:error];
    }
}

- (void)authorize:(GTDoubanAuthor *)authorize didCancel:(BOOL)cancel {
    if ([delegate respondsToSelector:@selector(engine:didCancel:)]) {
        [delegate engine:self didCancel:YES];
    }
}

#pragma mark Request
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(GTDoubanRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields {
	if (![self isLoggedIn])	{
        if ([delegate respondsToSelector:@selector(engineNotAuthorized:)]) {
            [delegate engineNotAuthorized:self];
        }
        return;
	}
    if ([self isAuthorizeExpired]) {
        if ([delegate respondsToSelector:@selector(engineAuthorizeExpired:)]) {
            [delegate engineAuthorizeExpired:self];
        }
        return;
    }
    [request disconnect];
    self.request = [GTDoubanRequest requestWithAccessToken:accessToken
                                                 url:[NSString stringWithFormat:@"%@%@", kGTSDKAPIDomain, methodName]
                                          httpMethod:httpMethod
                                              params:params
                                        postDataType:postDataType
                                    httpHeaderFields:httpHeaderFields
                                            delegate:self];
	[request connect];
}

#pragma mark API
- (void)sendWeiBoWithText:(NSString *)text {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   appKey, @"source",
                                   text, @"text",
                                   nil];
    [self loadRequestWithMethodName:@"shuo/v2/statuses/"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kGTRequestPostDataTypeNormal
                   httpHeaderFields:nil];
}

- (void)sendWeiBoWithText:(NSString *)text imageData:(NSData *)imageData {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   appKey, @"source",
                                   imageData, @"image",
                                   text, @"text",
                                   nil];
    [self loadRequestWithMethodName:@"shuo/v2/statuses/"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kGTRequestPostDataTypeMultipart
                   httpHeaderFields:nil];
}

- (void)sendWeiBoWithParams:(NSDictionary *)params {
    if ([params objectForKey:@"image"]) {
        [self loadRequestWithMethodName:@"shuo/v2/statuses/"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kGTRequestPostDataTypeMultipart
                       httpHeaderFields:nil];
    } else {
        [self loadRequestWithMethodName:@"shuo/v2/statuses/"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kGTRequestPostDataTypeNormal
                       httpHeaderFields:nil];
    }
}

- (void)getFriendShips {
    NSString *resquetString = [NSString stringWithFormat:@"shuo/v2/users/%@/following", userID];
    [self loadRequestWithMethodName:resquetString
                         httpMethod:@"GET"
                             params:nil
                       postDataType:kGTRequestPostDataTypeNone
                   httpHeaderFields:nil];
}

// 测试没成功
- (void)createFriendWithUserId:(NSString *)_userId {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   appKey, @"source",
                                   _userId, @"user_id",
                                   nil];
    [self loadRequestWithMethodName:@"shuo/v2/friendships/create"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kGTRequestPostDataTypeNormal
                   httpHeaderFields:nil];
}

- (void)getUserInfo {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.userID, @"uid", nil];
    [self loadRequestWithMethodName:@"v2/user/~me"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kGTRequestPostDataTypeNone
                   httpHeaderFields:nil];
}

#pragma mark - GTDoubanRequestDelegate Methods
- (void)request:(GTDoubanRequest *)request didFinishLoadingWithResult:(id)result {
    if ([delegate respondsToSelector:@selector(engine:requestDidSucceedWithResult:)]) {
        [delegate engine:self requestDidSucceedWithResult:result];
    }
}

- (void)request:(GTDoubanRequest *)request didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(engine:requestDidFailWithError:)]) {
        [delegate engine:self requestDidFailWithError:error];
    }
}

@end
