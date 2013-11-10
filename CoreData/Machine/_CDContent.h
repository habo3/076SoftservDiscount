// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDContent.h instead.

#import <CoreData/CoreData.h>


extern const struct CDContentAttributes {
	__unsafe_unretained NSString *apiVersion;
} CDContentAttributes;

extern const struct CDContentRelationships {
	__unsafe_unretained NSString *catrgories;
	__unsafe_unretained NSString *cities;
	__unsafe_unretained NSString *discountObjects;
	__unsafe_unretained NSString *favorites;
} CDContentRelationships;

extern const struct CDContentFetchedProperties {
} CDContentFetchedProperties;

@class CDCategory;
@class CDCity;
@class CDDiscountObject;
@class CDFavorites;



@interface CDContentID : NSManagedObjectID {}
@end

@interface _CDContent : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDContentID*)objectID;





@property (nonatomic, strong) NSDecimalNumber* apiVersion;



//- (BOOL)validateApiVersion:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *catrgories;

- (NSMutableSet*)catrgoriesSet;




@property (nonatomic, strong) NSSet *cities;

- (NSMutableSet*)citiesSet;




@property (nonatomic, strong) NSSet *discountObjects;

- (NSMutableSet*)discountObjectsSet;




@property (nonatomic, strong) NSSet *favorites;

- (NSMutableSet*)favoritesSet;





@end

@interface _CDContent (CoreDataGeneratedAccessors)

- (void)addCatrgories:(NSSet*)value_;
- (void)removeCatrgories:(NSSet*)value_;
- (void)addCatrgoriesObject:(CDCategory*)value_;
- (void)removeCatrgoriesObject:(CDCategory*)value_;

- (void)addCities:(NSSet*)value_;
- (void)removeCities:(NSSet*)value_;
- (void)addCitiesObject:(CDCity*)value_;
- (void)removeCitiesObject:(CDCity*)value_;

- (void)addDiscountObjects:(NSSet*)value_;
- (void)removeDiscountObjects:(NSSet*)value_;
- (void)addDiscountObjectsObject:(CDDiscountObject*)value_;
- (void)removeDiscountObjectsObject:(CDDiscountObject*)value_;

- (void)addFavorites:(NSSet*)value_;
- (void)removeFavorites:(NSSet*)value_;
- (void)addFavoritesObject:(CDFavorites*)value_;
- (void)removeFavoritesObject:(CDFavorites*)value_;

@end

@interface _CDContent (CoreDataGeneratedPrimitiveAccessors)


- (NSDecimalNumber*)primitiveApiVersion;
- (void)setPrimitiveApiVersion:(NSDecimalNumber*)value;





- (NSMutableSet*)primitiveCatrgories;
- (void)setPrimitiveCatrgories:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCities;
- (void)setPrimitiveCities:(NSMutableSet*)value;



- (NSMutableSet*)primitiveDiscountObjects;
- (void)setPrimitiveDiscountObjects:(NSMutableSet*)value;



- (NSMutableSet*)primitiveFavorites;
- (void)setPrimitiveFavorites:(NSMutableSet*)value;


@end
