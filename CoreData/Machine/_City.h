// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to City.h instead.

#import <CoreData/CoreData.h>


extern const struct CityAttributes {
	__unsafe_unretained NSString *bounds;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *published;
} CityAttributes;

extern const struct CityRelationships {
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *discountObjects;
} CityRelationships;

extern const struct CityFetchedProperties {
} CityFetchedProperties;

@class CDContent;
@class DiscountObject;

@class NSObject;




@interface CityID : NSManagedObjectID {}
@end

@interface _City : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CityID*)objectID;





@property (nonatomic, strong) id bounds;



//- (BOOL)validateBounds:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* id;



//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* published;



@property BOOL publishedValue;
- (BOOL)publishedValue;
- (void)setPublishedValue:(BOOL)value_;

//- (BOOL)validatePublished:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CDContent *content;

//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *discountObjects;

- (NSMutableSet*)discountObjectsSet;





@end

@interface _City (CoreDataGeneratedAccessors)

- (void)addDiscountObjects:(NSSet*)value_;
- (void)removeDiscountObjects:(NSSet*)value_;
- (void)addDiscountObjectsObject:(DiscountObject*)value_;
- (void)removeDiscountObjectsObject:(DiscountObject*)value_;

@end

@interface _City (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveBounds;
- (void)setPrimitiveBounds:(id)value;




- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePublished;
- (void)setPrimitivePublished:(NSNumber*)value;

- (BOOL)primitivePublishedValue;
- (void)setPrimitivePublishedValue:(BOOL)value_;





- (CDContent*)primitiveContent;
- (void)setPrimitiveContent:(CDContent*)value;



- (NSMutableSet*)primitiveDiscountObjects;
- (void)setPrimitiveDiscountObjects:(NSMutableSet*)value;


@end
