// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to City.h instead.

#import <CoreData/CoreData.h>


extern const struct CityAttributes {
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *name;
} CityAttributes;

extern const struct CityRelationships {
	__unsafe_unretained NSString *discountobject;
} CityRelationships;

extern const struct CityFetchedProperties {
} CityFetchedProperties;

@class DiscountObject;




@interface CityID : NSManagedObjectID {}
@end

@interface _City : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CityID*)objectID;





@property (nonatomic, strong) NSNumber* id;



@property int16_t idValue;
- (int16_t)idValue;
- (void)setIdValue:(int16_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *discountobject;

- (NSMutableSet*)discountobjectSet;





@end

@interface _City (CoreDataGeneratedAccessors)

- (void)addDiscountobject:(NSSet*)value_;
- (void)removeDiscountobject:(NSSet*)value_;
- (void)addDiscountobjectObject:(DiscountObject*)value_;
- (void)removeDiscountobjectObject:(DiscountObject*)value_;

@end

@interface _City (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int16_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int16_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveDiscountobject;
- (void)setPrimitiveDiscountobject:(NSMutableSet*)value;


@end
