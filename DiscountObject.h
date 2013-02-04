//
//  DiscountObject.h
//  SoftServeDP
//
//  Created by Bogdan on 03.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, City;

@interface DiscountObject : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * allPlaces;
@property (nonatomic, retain) NSNumber * allProducts;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * objectDescription;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parent;
@property (nonatomic, retain) NSString * pulse;
@property (nonatomic, retain) NSString * responsiblePersonInfo;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * geoLongitude;
@property (nonatomic, retain) NSNumber * geoLatitude;
@property (nonatomic, retain) NSNumber * logoId;
@property (nonatomic, retain) NSString * logoMime;
@property (nonatomic, retain) NSString * logoSrc;
@property (nonatomic, retain) NSNumber * discountFrom;
@property (nonatomic, retain) NSNumber * discountTo;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) City *cities;
@end

@interface DiscountObject (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addContactsObject:(NSManagedObject *)value;
- (void)removeContactsObject:(NSManagedObject *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
