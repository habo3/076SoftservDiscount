//
//  Category.h
//  SoftServeDP
//
//  Created by Bogdan on 1/29/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiscountObject;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * json_color;
@property (nonatomic, retain) NSDate * json_created;
@property (nonatomic, retain) NSString * json_fontSymbol;
@property (nonatomic, retain) NSNumber * json_iconId;
@property (nonatomic, retain) NSString * json_iconMime;
@property (nonatomic, retain) NSString * json_iconSize;
@property (nonatomic, retain) NSString * json_iconSrc;
@property (nonatomic, retain) NSNumber * json_id;
@property (nonatomic, retain) NSString * json_name;
@property (nonatomic, retain) NSDate * json_updated;
@property (nonatomic, retain) NSSet *discountobject;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addDiscountobjectObject:(DiscountObject *)value;
- (void)removeDiscountobjectObject:(DiscountObject *)value;
- (void)addDiscountobject:(NSSet *)values;
- (void)removeDiscountobject:(NSSet *)values;

@end
