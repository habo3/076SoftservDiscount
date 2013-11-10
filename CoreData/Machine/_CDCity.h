// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDCity.h instead.

#import <CoreData/CoreData.h>


extern const struct CDCityAttributes {
	__unsafe_unretained NSString *bounds;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *published;
} CDCityAttributes;

extern const struct CDCityRelationships {
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *discountObjects;
} CDCityRelationships;

extern const struct CDCityFetchedProperties {
} CDCityFetchedProperties;

@class CDContent;
@class CDDiscountObject;

@class NSObject;




@interface CDCityID : NSManagedObjectID {}
@end

@interface _CDCity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDCityID*)objectID;





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

@interface _CDCity (CoreDataGeneratedAccessors)

- (void)addDiscountObjects:(NSSet*)value_;
- (void)removeDiscountObjects:(NSSet*)value_;
- (void)addDiscountObjectsObject:(CDDiscountObject*)value_;
- (void)removeDiscountObjectsObject:(CDDiscountObject*)value_;

@end

@interface _CDCity (CoreDataGeneratedPrimitiveAccessors)


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
