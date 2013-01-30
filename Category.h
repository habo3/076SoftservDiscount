//
//  Category.h
//  SoftServeDP
//
//  Created by Bogdan on 30.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiscountObject, Icon;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * json_color;
@property (nonatomic, retain) NSNumber * json_created;
@property (nonatomic, retain) NSString * json_fontSymbol;
@property (nonatomic, retain) NSNumber * json_id;
@property (nonatomic, retain) NSString * json_name;
@property (nonatomic, retain) NSNumber * json_updated;
@property (nonatomic, retain) NSNumber * json_listOnly;
@property (nonatomic, retain) NSSet *discountobject;
@property (nonatomic, retain) Icon *icon;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addDiscountobjectObject:(DiscountObject *)value;
- (void)removeDiscountobjectObject:(DiscountObject *)value;
- (void)addDiscountobject:(NSSet *)values;
- (void)removeDiscountobject:(NSSet *)values;

@end
