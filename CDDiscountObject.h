//
//  DiscountObject.h
//  DiscountJson
//
//  Created by Victor on 10/19/13.
//  Copyright (c) 2013 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDCategory, CDCity;

@interface CDDiscountObject : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) id attachments;
@property (nonatomic, retain) NSDecimalNumber * created;
@property (nonatomic, retain) NSString * descriptionn;
@property (nonatomic, retain) id discount;
@property (nonatomic, retain) id email;
@property (nonatomic, retain) id geoPoint;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) id logo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * parent;
@property (nonatomic, retain) id phone;
@property (nonatomic, retain) NSNumber * published;
@property (nonatomic, retain) NSString * pulse;
@property (nonatomic, retain) NSString * responsiblePersonInfo;
@property (nonatomic, retain) id site;
@property (nonatomic, retain) id skype;
@property (nonatomic, retain) NSDecimalNumber * updated;
@property (nonatomic, retain) id category;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSSet *categorys;
@property (nonatomic, retain) CDCity *cities;
@end

@interface CDDiscountObject (CoreDataGeneratedAccessors)

- (void)addCategorysObject:(CDCategory *)value;
- (void)removeCategorysObject:(CDCategory *)value;
- (void)addCategorys:(NSSet *)values;
- (void)removeCategorys:(NSSet *)values;

@end