//
//  APIClient.h
//  VendingDemo
//
//  Created by David Hartmann on 10/22/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class Kid;
@class Card;
@class Transaction;
@class Rule;
@class Chore;

typedef NS_ENUM(NSInteger, StatusCode) {
    StatusCodeUnauthorized = 401
};

@interface APIClient : NSObject

///----------------------------------------------
/// @name Configuring the Shared API Client Instance
///----------------------------------------------

/**
 Return the shared instance of the API Client
 
 @return The shared API client instance.
 */
+ (instancetype)sharedClient;

+ (BOOL)isAuthenticated;
+ (NSString*)getToken;
+ (void)setToken:(NSString*)token;

/// Endpoints
+ (void)cancelAllRequests;
+ (void)getMe:(void (^)(User *user))success failure:(void (^)(NSError *error, NSHTTPURLResponse *response))failure;
+ (void)facebookLoginWithToken:(NSString *)token success:(void (^)(User *user))success failure:(void (^)(NSError *error, NSHTTPURLResponse *response))failure;

@end
