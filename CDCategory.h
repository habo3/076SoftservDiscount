//
//  Category.h
//  DiscountJson
//
//  Created by Victor on 10/19/13.
//  Copyright (c) 2013 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDDiscountObject;

@interface CDCategory : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * created;
@property (nonatomic, retain) NSString * fontSymbol;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * published;
@property (nonatomic, retain) NSDecimalNumber * updated;
@property (nonatomic, retain) NSSet *discountObjects;
@end

@interface CDCategory (CoreDataGeneratedAccessors)

- (void)addDiscountObjectsObject:(CDDiscountObject *)value;
- (void)removeDiscountObjectsObject:(CDDiscountObject *)value;
- (void)addDiscountObjects:(NSSet *)values;
- (void)removeDiscountObjects:(NSSet *)values;

@end
