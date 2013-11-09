// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DiscountObject.h instead.

#import <CoreData/CoreData.h>


extern const struct DiscountObjectAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *attachments;
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *city;
	__unsafe_unretained NSString *created;
	__unsafe_unretained NSString *descriptionn;
	__unsafe_unretained NSString *discount;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *geoPoint;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isInFavorites;
	__unsafe_unretained NSString *logo;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *parent;
	__unsafe_unretained NSString *phone;
	__unsafe_unretained NSString *published;
	__unsafe_unretained NSString *pulse;
	__unsafe_unretained NSString *responsiblePersonInfo;
	__unsafe_unretained NSString *site;
	__unsafe_unretained NSString *skype;
	__unsafe_unretained NSString *updated;
} DiscountObjectAttributes;

extern const struct DiscountObjectRelationships {
	__unsafe_unretained NSString *categorys;
	__unsafe_unretained NSString *cities;
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *favorite;
} DiscountObjectRelationships;

extern const struct DiscountObjectFetchedProperties {
} DiscountObjectFetchedProperties;

@class Category;
@class City;
@class CDContent;
@class CDFavorites;


@class NSObject;
@class NSObject;



@class NSObject;
@class NSObject;
@class NSObject;


@class NSObject;


@class NSObject;



@class NSObject;
@class NSObject;


@interface DiscountObjectID : NSManagedObjectID {}
@end

@interface _DiscountObject : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DiscountObjectID*)objectID;





@property (nonatomic, strong) NSString* address;



//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id attachments;



//- (BOOL)validateAttachments:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id category;



//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* city;



//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* created;



//- (BOOL)validateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* descriptionn;



//- (BOOL)validateDescriptionn:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id discount;



//- (BOOL)validateDiscount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id geoPoint;



//- (BOOL)validateGeoPoint:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* id;



//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isInFavorites;



@property BOOL isInFavoritesValue;
- (BOOL)isInFavoritesValue;
- (void)setIsInFavoritesValue:(BOOL)value_;

//- (BOOL)validateIsInFavorites:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id logo;



//- (BOOL)validateLogo:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* parent;



//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id phone;



//- (BOOL)validatePhone:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* published;



@property BOOL publishedValue;
- (BOOL)publishedValue;
- (void)setPublishedValue:(BOOL)value_;

//- (BOOL)validatePublished:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* pulse;



//- (BOOL)validatePulse:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* responsiblePersonInfo;



//- (BOOL)validateResponsiblePersonInfo:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id site;



//- (BOOL)validateSite:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id skype;



//- (BOOL)validateSkype:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* updated;



//- (BOOL)validateUpdated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *categorys;

- (NSMutableSet*)categorysSet;




@property (nonatomic, strong) City *cities;

//- (BOOL)validateCities:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) CDContent *content;

//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) CDFavorites *favorite;

//- (BOOL)validateFavorite:(id*)value_ error:(NSError**)error_;





@end

@interface _DiscountObject (CoreDataGeneratedAccessors)

- (void)addCategorys:(NSSet*)value_;
- (void)removeCategorys:(NSSet*)value_;
- (void)addCategorysObject:(Category*)value_;
- (void)removeCategorysObject:(Category*)value_;

@end

@interface _DiscountObject (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;




- (id)primitiveAttachments;
- (void)setPrimitiveAttachments:(id)value;




- (id)primitiveCategory;
- (void)setPrimitiveCategory:(id)value;




- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;




- (NSDecimalNumber*)primitiveCreated;
- (void)setPrimitiveCreated:(NSDecimalNumber*)value;




- (NSString*)primitiveDescriptionn;
- (void)setPrimitiveDescriptionn:(NSString*)value;




- (id)primitiveDiscount;
- (void)setPrimitiveDiscount:(id)value;




- (id)primitiveEmail;
- (void)setPrimitiveEmail:(id)value;




- (id)primitiveGeoPoint;
- (void)setPrimitiveGeoPoint:(id)value;




- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;




- (NSNumber*)primitiveIsInFavorites;
- (void)setPrimitiveIsInFavorites:(NSNumber*)value;

- (BOOL)primitiveIsInFavoritesValue;
- (void)setPrimitiveIsInFavoritesValue:(BOOL)value_;




- (id)primitiveLogo;
- (void)setPrimitiveLogo:(id)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSDecimalNumber*)primitiveParent;
- (void)setPrimitiveParent:(NSDecimalNumber*)value;




- (id)primitivePhone;
- (void)setPrimitivePhone:(id)value;




- (NSNumber*)primitivePublished;
- (void)setPrimitivePublished:(NSNumber*)value;

- (BOOL)primitivePublishedValue;
- (void)setPrimitivePublishedValue:(BOOL)value_;




- (NSString*)primitivePulse;
- (void)setPrimitivePulse:(NSString*)value;




- (NSString*)primitiveResponsiblePersonInfo;
- (void)setPrimitiveResponsiblePersonInfo:(NSString*)value;




- (id)primitiveSite;
- (void)setPrimitiveSite:(id)value;




- (id)primitiveSkype;
- (void)setPrimitiveSkype:(id)value;




- (NSDecimalNumber*)primitiveUpdated;
- (void)setPrimitiveUpdated:(NSDecimalNumber*)value;





- (NSMutableSet*)primitiveCategorys;
- (void)setPrimitiveCategorys:(NSMutableSet*)value;



- (City*)primitiveCities;
- (void)setPrimitiveCities:(City*)value;



- (CDContent*)primitiveContent;
- (void)setPrimitiveContent:(CDContent*)value;



- (CDFavorites*)primitiveFavorite;
- (void)setPrimitiveFavorite:(CDFavorites*)value;


@end
