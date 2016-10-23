//
//  User.h
//  VendingDemo
//
//  Created by David Hartmann on 10/22/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, Gender) {
    GenderMale = 1,
    GenderFemale = 2
};

@interface User : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, copy) NSString * firstName;
@property (nonatomic, copy) NSString * lastName;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) Gender gender;

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;
+ (UIImage*)getPlaceholderImage;

+ (NSDictionary*)fieldMappings;

@end
