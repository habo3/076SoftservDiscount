// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDCategory.h instead.

#import <CoreData/CoreData.h>


extern const struct CDCategoryAttributes {
	__unsafe_unretained NSString *created;
	__unsafe_unretained NSString *fontSymbol;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *published;
	__unsafe_unretained NSString *updated;
} CDCategoryAttributes;

extern const struct CDCategoryRelationships {
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *discountObjects;
} CDCategoryRelationships;

extern const struct CDCategoryFetchedProperties {
} CDCategoryFetchedProperties;

@class CDContent;
@class CDDiscountObject;








@interface CDCategoryID : NSManagedObjectID {}
@end

@interface _CDCategory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDCategoryID*)objectID;





@property (nonatomic, strong) NSDecimalNumber* created;



//- (BOOL)validateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* fontSymbol;



//- (BOOL)validateFontSymbol:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* id;



//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* published;



@property BOOL publishedValue;
- (BOOL)publishedValue;
- (void)setPublishedValue:(BOOL)value_;

//- (BOOL)validatePublished:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* updated;



//- (BOOL)validateUpdated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CDContent *content;

//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *discountObjects;

- (NSMutableSet*)discountObjectsSet;





@end

@interface _CDCategory (CoreDataGeneratedAccessors)

- (void)addDiscountObjects:(NSSet*)value_;
- (void)removeDiscountObjects:(NSSet*)value_;
- (void)addDiscountObjectsObject:(CDDiscountObject*)value_;
- (void)removeDiscountObjectsObject:(CDDiscountObject*)value_;

@end

@interface _CDCategory (CoreDataGeneratedPrimitiveAccessors)


- (NSDecimalNumber*)primitiveCreated;
- (void)setPrimitiveCreated:(NSDecimalNumber*)value;




- (NSString*)primitiveFontSymbol;
- (void)setPrimitiveFontSymbol:(NSString*)value;




- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePublished;
- (void)setPrimitivePublished:(NSNumber*)value;

- (BOOL)primitivePublishedValue;
- (void)setPrimitivePublishedValue:(BOOL)value_;




- (NSDecimalNumber*)primitiveUpdated;
- (void)setPrimitiveUpdated:(NSDecimalNumber*)value;





- (CDContent*)primitiveContent;
- (void)setPrimitiveContent:(CDContent*)value;



- (NSMutableSet*)primitiveDiscountObjects;
- (void)setPrimitiveDiscountObjects:(NSMutableSet*)value;


@end
