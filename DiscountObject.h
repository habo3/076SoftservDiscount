//
//  DiscountObject.h
//  SoftServeDP
//
//  Created by Bogdan on 2/7/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, City, Contacts;

@interface DiscountObject : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDecimalNumber * created;
@property (nonatomic, retain) NSNumber * discountFrom;
@property (nonatomic, retain) NSNumber * discountTo;
@property (nonatomic, retain) NSNumber * geoLatitude;
@property (nonatomic, retain) NSNumber * geoLongitude;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * responsiblePersonInfo;
@property (nonatomic, retain) NSDecimalNumber * updated;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) City *cities;
@property (nonatomic, retain) NSSet *contacts;
@end

@interface DiscountObject (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addContactsObject:(Contacts *)value;
- (void)removeContactsObject:(Contacts *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
