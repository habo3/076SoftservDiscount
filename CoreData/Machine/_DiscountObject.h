// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DiscountObject.h instead.

#import <CoreData/CoreData.h>


extern const struct DiscountObjectAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *created;
	__unsafe_unretained NSString *discountFrom;
	__unsafe_unretained NSString *discountTo;
	__unsafe_unretained NSString *geoLatitude;
	__unsafe_unretained NSString *geoLongitude;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *inFavorites;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *responsiblePersonInfo;
	__unsafe_unretained NSString *updated;
} DiscountObjectAttributes;

extern const struct DiscountObjectRelationships {
	__unsafe_unretained NSString *categories;
	__unsafe_unretained NSString *cities;
	__unsafe_unretained NSString *contacts;
} DiscountObjectRelationships;

extern const struct DiscountObjectFetchedProperties {
} DiscountObjectFetchedProperties;

@class Category;
@class City;
@class Contacts;













@interface DiscountObjectID : NSManagedObjectID {}
@end

@interface _DiscountObject : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DiscountObjectID*)objectID;





@property (nonatomic, strong) NSString* address;



//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* created;



//- (BOOL)validateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* discountFrom;



@property int16_t discountFromValue;
- (int16_t)discountFromValue;
- (void)setDiscountFromValue:(int16_t)value_;

//- (BOOL)validateDiscountFrom:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* discountTo;



@property int16_t discountToValue;
- (int16_t)discountToValue;
- (void)setDiscountToValue:(int16_t)value_;

//- (BOOL)validateDiscountTo:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* geoLatitude;



@property double geoLatitudeValue;
- (double)geoLatitudeValue;
- (void)setGeoLatitudeValue:(double)value_;

//- (BOOL)validateGeoLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* geoLongitude;



@property double geoLongitudeValue;
- (double)geoLongitudeValue;
- (void)setGeoLongitudeValue:(double)value_;

//- (BOOL)validateGeoLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* id;



@property int16_t idValue;
- (int16_t)idValue;
- (void)setIdValue:(int16_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* inFavorites;



@property BOOL inFavoritesValue;
- (BOOL)inFavoritesValue;
- (void)setInFavoritesValue:(BOOL)value_;

//- (BOOL)validateInFavorites:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* responsiblePersonInfo;



//- (BOOL)validateResponsiblePersonInfo:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* updated;



//- (BOOL)validateUpdated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *categories;

- (NSMutableSet*)categoriesSet;




@property (nonatomic, strong) City *cities;

//- (BOOL)validateCities:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *contacts;

- (NSMutableSet*)contactsSet;





@end

@interface _DiscountObject (CoreDataGeneratedAccessors)

- (void)addCategories:(NSSet*)value_;
- (void)removeCategories:(NSSet*)value_;
- (void)addCategoriesObject:(Category*)value_;
- (void)removeCategoriesObject:(Category*)value_;

- (void)addContacts:(NSSet*)value_;
- (void)removeContacts:(NSSet*)value_;
- (void)addContactsObject:(Contacts*)value_;
- (void)removeContactsObject:(Contacts*)value_;

@end

@interface _DiscountObject (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;




- (NSDecimalNumber*)primitiveCreated;
- (void)setPrimitiveCreated:(NSDecimalNumber*)value;




- (NSNumber*)primitiveDiscountFrom;
- (void)setPrimitiveDiscountFrom:(NSNumber*)value;

- (int16_t)primitiveDiscountFromValue;
- (void)setPrimitiveDiscountFromValue:(int16_t)value_;




- (NSNumber*)primitiveDiscountTo;
- (void)setPrimitiveDiscountTo:(NSNumber*)value;

- (int16_t)primitiveDiscountToValue;
- (void)setPrimitiveDiscountToValue:(int16_t)value_;




- (NSNumber*)primitiveGeoLatitude;
- (void)setPrimitiveGeoLatitude:(NSNumber*)value;

- (double)primitiveGeoLatitudeValue;
- (void)setPrimitiveGeoLatitudeValue:(double)value_;




- (NSNumber*)primitiveGeoLongitude;
- (void)setPrimitiveGeoLongitude:(NSNumber*)value;

- (double)primitiveGeoLongitudeValue;
- (void)setPrimitiveGeoLongitudeValue:(double)value_;




- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int16_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int16_t)value_;




- (NSNumber*)primitiveInFavorites;
- (void)setPrimitiveInFavorites:(NSNumber*)value;

- (BOOL)primitiveInFavoritesValue;
- (void)setPrimitiveInFavoritesValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveResponsiblePersonInfo;
- (void)setPrimitiveResponsiblePersonInfo:(NSString*)value;




- (NSDecimalNumber*)primitiveUpdated;
- (void)setPrimitiveUpdated:(NSDecimalNumber*)value;





- (NSMutableSet*)primitiveCategories;
- (void)setPrimitiveCategories:(NSMutableSet*)value;



- (City*)primitiveCities;
- (void)setPrimitiveCities:(City*)value;



- (NSMutableSet*)primitiveContacts;
- (void)setPrimitiveContacts:(NSMutableSet*)value;


@end
