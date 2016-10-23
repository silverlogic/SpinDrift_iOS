//
//  User.m
//  VendingDemo
//
//  Created by David Hartmann on 10/22/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

#import "User.h"

static UIImage *_placeholderImage = nil;
static User *_currentUser = nil;

@implementation User

- (instancetype)init {
    self = [super init];
    if (self) {
        _gender = GenderMale;
    }
    return self;
}

+ (NSDictionary*)fieldMappings {
    NSDictionary *fields = @{
                             @"id": @"userId",
                             @"email": @"email",
                             @"name": @"name",
                             @"first_name": @"firstName",
                             @"last_name": @"lastName",
                             @"token": @"token",
                             @"avatar.url": @"imageUrl"
                             };
    NSMutableDictionary *fieldMappings = [NSMutableDictionary dictionaryWithDictionary:fields];
    return fieldMappings;
}


+ (User*)currentUser {
    if (!_currentUser) {
        _currentUser = [[User alloc] init];
        _currentUser.userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        _currentUser.firstName = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstName"];
        _currentUser.lastName = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastName"];
        _currentUser.email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    }
    return _currentUser;
}
+ (void)setCurrentUser:(User*)currentUser {
    _currentUser = currentUser;
    
    [[NSUserDefaults standardUserDefaults] setObject:currentUser.userId forKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] setObject:currentUser.firstName forKey:@"firstName"];
    [[NSUserDefaults standardUserDefaults] setObject:currentUser.lastName forKey:@"lastName"];
    [[NSUserDefaults standardUserDefaults] setObject:currentUser.email forKey:@"email"];
}

#pragma mark - Helpers
- (BOOL)isEqual:(id)object {
    if (object == nil)
        return NO;
    
    return [self.userId isEqualToNumber:((User*)object).userId];
}
+ (UIImage*)getPlaceholderImage {
    if (_placeholderImage == nil) {
        _placeholderImage = [UIImage imageNamed:@"placeholder-user.png"];
    }
    return _placeholderImage;
}

- (NSURL*)profilePicUrl {
    NSString *urlString = [NSString stringWithFormat:@"%@", self.imageUrl];
    return [NSURL URLWithString:urlString];
}

@end


