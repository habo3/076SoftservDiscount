//
//  Object.h
//  SoftServeDP
//
//  Created by Bogdan on 28.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, City;

@interface Object : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * allPlaces;
@property (nonatomic, retain) NSNumber * allProducts;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * descriptionOfObject;
@property (nonatomic, retain) NSNumber * discountFrom;
@property (nonatomic, retain) NSNumber * discountTo;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * logoID;
@property (nonatomic, retain) NSString * logoMime;
@property (nonatomic, retain) NSString * logoSize;
@property (nonatomic, retain) NSString * logoSrc;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parent;
@property (nonatomic, retain) NSString * pulse;
@property (nonatomic, retain) NSString * responsiblePersonInfo;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *category;
@property (nonatomic, retain) City *city;
@end

@interface Object (CoreDataGeneratedAccessors)

- (void)addCategoryObject:(Category *)value;
- (void)removeCategoryObject:(Category *)value;
- (void)addCategory:(NSSet *)values;
- (void)removeCategory:(NSSet *)values;

@end
