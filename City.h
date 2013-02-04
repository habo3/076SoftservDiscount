//
//  City.h
//  SoftServeDP
//
//  Created by Bogdan on 03.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiscountObject;

@interface City : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *discountobject;
@end

@interface City (CoreDataGeneratedAccessors)

- (void)addDiscountobjectObject:(DiscountObject *)value;
- (void)removeDiscountobjectObject:(DiscountObject *)value;
- (void)addDiscountobject:(NSSet *)values;
- (void)removeDiscountobject:(NSSet *)values;

@end
