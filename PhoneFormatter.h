//
//  PhoneFormatter.h
//  SoftServe Discount
//
//  Created by Maxim on 19.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneFormatter : NSObject

+ (NSString *)numberForCall:(NSString *)phoneNumber withCity:(NSString *)city;
+ (NSString *)numberForView:(NSString *)phoneNumber withCity:(NSString *)city;

@end
