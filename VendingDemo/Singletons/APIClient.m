//
//  APIClient.m
//  VendingDemo
//
//  Created by David Hartmann on 10/22/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

#import "APIClient.h"
#import <RestKit/RestKit.h>
#import <RestKit/RKPathMatcher.h>
#import "ExtendedError.h"
#import <YYWebImage/YYWebImage.h>
#import "User.h"

//////////////////////////////////
// Shared Instance
static APIClient  *_sharedClient = nil;
static void (^_defaultFailureBlock)(RKObjectRequestOperation *operation, NSError *error) = nil;
static NSString *const apiUrl = @"http://api.spindrift.tsl.io/v1/";

// Default Headers
static NSString *const kAuthorization = @"Authorization";

// API Parameters
static NSString *const kResults		= @"results";
static NSString *const kPageSize	= @"page_size";
static NSString *const kPage		= @"page";


// Endpoints
static NSString *const kFacebookEndpoint = @"social-auth";
static NSString *const kMeEndpoint = @"users/me";

typedef NS_ENUM(NSUInteger, PageSize) {
    PageSizeDefault  = 20,
    PageSizeSmall    = 10,
    PageSizeMedium   = 300,
    PageSizeLarge    = 1000
};

@interface APIClient ()


@end

@implementation APIClient

- (instancetype)init {
    self = [super init];
    if (self) {
        // initialize stuff here
        [self initRestKit];
        
        [AFRKNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        _defaultFailureBlock = ^(RKObjectRequestOperation *operation, NSError *error) {
            // Transport error or server error handled by errorDescriptor
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.Title.Error", @"Alert Error title") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Alert.OK", @"Alert OK button title") otherButtonTitles:nil] show];
        };
    }
    
    return self;
}

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc] init];
        // Do any other initialisation stuff here
    });
    return _sharedClient;
}

- (void)initRestKit {
#ifdef DEBUG
    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
#endif
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
    
    NSIndexSet *successStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    NSIndexSet *error400StatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError); // Anything in 4xx
    NSIndexSet *error500StatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassServerError); // Anything in 5xx
    
    /* ********************************************* */
    /* ********* MAPPINGS ************************** */
    /* ERROR */
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[ExtendedError class]];
    // The entire value at the source key path containing the errors maps to the message
    [errorMapping addAttributeMappingsFromDictionary:[ExtendedError fieldMappings]];
    // Any response in the 4xx status code range with an "errors" key path uses
    RKResponseDescriptor *error400Descriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:error400StatusCodes];
    RKResponseDescriptor *error500Descriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:error500StatusCodes];
    
    /* EMPTY */
    RKObjectMapping *emptyResponseMapping = [RKObjectMapping mappingForClass:[NSDictionary class]];
    
    /* USER */
    RKObjectMapping *userResponseMapping = [RKObjectMapping mappingForClass:[User class]];
    [userResponseMapping addAttributeMappingsFromDictionary:[User fieldMappings]];
    
    
    /* ********************************************* */
    /* ********* RESPONSE DESCRIPTORS ************** */
    /* FACEBOOK */
    RKResponseDescriptor *facebookResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userResponseMapping method:RKRequestMethodPOST pathPattern:kFacebookEndpoint keyPath:nil statusCodes:successStatusCodes];
     /* USER */
    RKResponseDescriptor *meResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userResponseMapping method:RKRequestMethodGET pathPattern:kMeEndpoint keyPath:nil statusCodes:successStatusCodes];
 
    
    /* ********************************************* */
    /* ********** REQUEST DESCRIPTORS ************** */

    
    /* ********************************************* */
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:apiUrl]];
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    // Add our descriptors to the manager
    [manager addRequestDescriptorsFromArray:@[
                                              
                                              ]];
    [manager addResponseDescriptorsFromArray:@[
                                               facebookResponseDescriptor,
                                               meResponseDescriptor,
                                               error400Descriptor,
                                               error500Descriptor
                                               ]];
    
    // Pagination mapping
    RKObjectMapping *paginationMapping = [RKObjectMapping mappingForClass:[RKPaginator class]];
    [paginationMapping addAttributeMappingsFromDictionary:@{
                                                            @"page_size": @"perPage",
                                                            @"total_pages": @"pageCount",
                                                            @"count": @"objectCount"
                                                            }];
    [manager setPaginationMapping:paginationMapping];
    
    if ([APIClient isAuthenticated]) {
        NSString *token = [APIClient getToken];
        [[manager HTTPClient] setDefaultHeader:kAuthorization value:[NSString stringWithFormat:@"Token %@", token]];
    }
}

#pragma mark - API Endpoints
+ (void)cancelAllRequests {
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
}

+ (void)getMe:(void (^)(User *))success failure:(void (^)(NSError *error, NSHTTPURLResponse *response))failure {
    [[RKObjectManager sharedManager] getObject:[User currentUser] path:kMeEndpoint parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [User setCurrentUser:mappingResult.firstObject];
        if (success) {
            success(mappingResult.firstObject);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error, operation.HTTPRequestOperation.response);
        } else {
            _defaultFailureBlock(operation, error);
        }
    }];
}

+ (void)facebookLoginWithToken:(NSString *)token success:(void (^)(User *))success failure:(void (^)(NSError *error, NSHTTPURLResponse *response))failure {
    NSDictionary *params = @{ @"access_token": token };
    [[RKObjectManager sharedManager] postObject:nil path:kFacebookEndpoint parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User *user = mappingResult.firstObject;
        [APIClient setToken:user.token];
        [APIClient getMe:^(User *user) {
            if (success) {
                success(mappingResult.firstObject);
            }
        } failure:^(NSError *error, NSHTTPURLResponse *response) {
            if (failure) {
                failure(error, operation.HTTPRequestOperation.response);
            } else {
                _defaultFailureBlock(operation, error);
            }
        }];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error, operation.HTTPRequestOperation.response);
        } else {
            _defaultFailureBlock(operation, error);
        }
    }];
}

#pragma mark - Helpers
+ (BOOL)isAuthenticated {
    return ([self getToken] != nil);
}

+ (NSString*)getToken {
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
    return token;
}
+ (void)setToken:(NSString*)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    if (token) {
        [[manager HTTPClient] setDefaultHeader:kAuthorization value:[NSString stringWithFormat:@"Token %@", token]];
    } else {
        [[manager HTTPClient] clearAuthorizationHeader];
    }
}


@end
