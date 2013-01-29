//
//  DiscountObject.h
//  SoftServeDP
//
//  Created by Bogdan on 1/29/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, City;

@interface DiscountObject : NSManagedObject

@property (nonatomic, retain) NSString * json_address;
@property (nonatomic, retain) NSNumber * json_allPlaces;
@property (nonatomic, retain) NSNumber * json_allProducts;
@property (nonatomic, retain) NSDate * json_created;
@property (nonatomic, retain) NSString * json_descriptionOfObject;
@property (nonatomic, retain) NSNumber * json_discountFrom;
@property (nonatomic, retain) NSNumber * json_discountTo;
@property (nonatomic, retain) NSNumber * json_id;
@property (nonatomic, retain) NSNumber * json_latitude;
@property (nonatomic, retain) NSNumber * json_logoID;
@property (nonatomic, retain) NSString * json_logoMime;
@property (nonatomic, retain) NSString * json_logoSize;
@property (nonatomic, retain) NSString * json_logoSrc;
@property (nonatomic, retain) NSNumber * json_longitude;
@property (nonatomic, retain) NSString * json_name;
@property (nonatomic, retain) NSNumber * json_parent;
@property (nonatomic, retain) NSString * json_pulse;
@property (nonatomic, retain) NSString * json_responsiblePersonInfo;
@property (nonatomic, retain) NSDate * json_updated;
@property (nonatomic, retain) NSSet *category;
@property (nonatomic, retain) City *city;
@end

@interface DiscountObject (CoreDataGeneratedAccessors)

- (void)addCategoryObject:(Category *)value;
- (void)removeCategoryObject:(Category *)value;
- (void)addCategory:(NSSet *)values;
- (void)removeCategory:(NSSet *)values;

@end
