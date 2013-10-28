//
//  City.h
//  DiscountJson
//
//  Created by Victor on 10/19/13.
//  Copyright (c) 2013 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDDiscountObject;

@interface CDCity : NSManagedObject

@property (nonatomic, retain) id bounds;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * published;
@property (nonatomic, retain) NSSet *discountObjects;
@end

@interface CDCity (CoreDataGeneratedAccessors)

- (void)addDiscountObjectsObject:(CDDiscountObject *)value;
- (void)removeDiscountObjectsObject:(CDDiscountObject *)value;
- (void)addDiscountObjects:(NSSet *)values;
- (void)removeDiscountObjects:(NSSet *)values;

@end
