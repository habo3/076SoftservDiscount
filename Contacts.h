//
//  Contacts.h
//  SoftServeDP
//
//  Created by Bogdan on 03.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiscountObject;

@interface Contacts : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) DiscountObject *discountObject;

@end
