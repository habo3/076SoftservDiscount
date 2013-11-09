// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDFavorites.h instead.

#import <CoreData/CoreData.h>


extern const struct CDFavoritesAttributes {
} CDFavoritesAttributes;

extern const struct CDFavoritesRelationships {
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *discountObjects;
} CDFavoritesRelationships;

extern const struct CDFavoritesFetchedProperties {
} CDFavoritesFetchedProperties;

@class CDContent;
@class DiscountObject;


@interface CDFavoritesID : NSManagedObjectID {}
@end

@interface _CDFavorites : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDFavoritesID*)objectID;





@property (nonatomic, strong) CDContent *content;

//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *discountObjects;

- (NSMutableSet*)discountObjectsSet;





@end

@interface _CDFavorites (CoreDataGeneratedAccessors)

- (void)addDiscountObjects:(NSSet*)value_;
- (void)removeDiscountObjects:(NSSet*)value_;
- (void)addDiscountObjectsObject:(DiscountObject*)value_;
- (void)removeDiscountObjectsObject:(DiscountObject*)value_;

@end

@interface _CDFavorites (CoreDataGeneratedPrimitiveAccessors)



- (CDContent*)primitiveContent;
- (void)setPrimitiveContent:(CDContent*)value;



- (NSMutableSet*)primitiveDiscountObjects;
- (void)setPrimitiveDiscountObjects:(NSMutableSet*)value;


@end
