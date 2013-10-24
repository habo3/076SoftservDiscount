// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Category.h instead.

#import <CoreData/CoreData.h>


extern const struct CategoryAttributes {
	__unsafe_unretained NSString *attribute;
	__unsafe_unretained NSString *created;
	__unsafe_unretained NSString *fontSymbol;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *updated;
} CategoryAttributes;

extern const struct CategoryRelationships {
	__unsafe_unretained NSString *discountobject;
} CategoryRelationships;

extern const struct CategoryFetchedProperties {
} CategoryFetchedProperties;

@class DiscountObject;

@class NSObject;






@interface CategoryID : NSManagedObjectID {}
@end

@interface _Category : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CategoryID*)objectID;





@property (nonatomic, strong) id attribute;



//- (BOOL)validateAttribute:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* created;



@property int16_t createdValue;
- (int16_t)createdValue;
- (void)setCreatedValue:(int16_t)value_;

//- (BOOL)validateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* fontSymbol;



//- (BOOL)validateFontSymbol:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* id;



@property int16_t idValue;
- (int16_t)idValue;
- (void)setIdValue:(int16_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* updated;



@property int16_t updatedValue;
- (int16_t)updatedValue;
- (void)setUpdatedValue:(int16_t)value_;

//- (BOOL)validateUpdated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *discountobject;

- (NSMutableSet*)discountobjectSet;





@end

@interface _Category (CoreDataGeneratedAccessors)

- (void)addDiscountobject:(NSSet*)value_;
- (void)removeDiscountobject:(NSSet*)value_;
- (void)addDiscountobjectObject:(DiscountObject*)value_;
- (void)removeDiscountobjectObject:(DiscountObject*)value_;

@end

@interface _Category (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveAttribute;
- (void)setPrimitiveAttribute:(id)value;




- (NSNumber*)primitiveCreated;
- (void)setPrimitiveCreated:(NSNumber*)value;

- (int16_t)primitiveCreatedValue;
- (void)setPrimitiveCreatedValue:(int16_t)value_;




- (NSString*)primitiveFontSymbol;
- (void)setPrimitiveFontSymbol:(NSString*)value;




- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int16_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int16_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveUpdated;
- (void)setPrimitiveUpdated:(NSNumber*)value;

- (int16_t)primitiveUpdatedValue;
- (void)setPrimitiveUpdatedValue:(int16_t)value_;





- (NSMutableSet*)primitiveDiscountobject;
- (void)setPrimitiveDiscountobject:(NSMutableSet*)value;


@end
