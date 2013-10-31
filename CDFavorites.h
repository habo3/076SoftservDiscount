//
//  CDFavorites.h
//  SoftServe Discount
//
//  Created by Victor on 31.10.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDDiscountObject;

@interface CDFavorites : NSManagedObject

@property (nonatomic, retain) NSSet *discountObjects;
@end

@interface CDFavorites (CoreDataGeneratedAccessors)

- (void)addDiscountObjectsObject:(CDDiscountObject *)value;
- (void)removeDiscountObjectsObject:(CDDiscountObject *)value;
- (void)addDiscountObjects:(NSSet *)values;
- (void)removeDiscountObjects:(NSSet *)values;

@end
