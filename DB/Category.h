//
//  Category.h
//  SoftServeDP
//
//  Created by Bogdan on 29.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Object;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * fontSymbol;
@property (nonatomic, retain) NSNumber * iconId;
@property (nonatomic, retain) NSString * iconMime;
@property (nonatomic, retain) NSString * iconSize;
@property (nonatomic, retain) NSString * iconSrc;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *object;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addObjectObject:(Object *)value;
- (void)removeObjectObject:(Object *)value;
- (void)addObject:(NSSet *)values;
- (void)removeObject:(NSSet *)values;

@end
