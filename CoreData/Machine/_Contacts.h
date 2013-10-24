// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Contacts.h instead.

#import <CoreData/CoreData.h>


extern const struct ContactsAttributes {
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *value;
} ContactsAttributes;

extern const struct ContactsRelationships {
	__unsafe_unretained NSString *discountObject;
} ContactsRelationships;

extern const struct ContactsFetchedProperties {
} ContactsFetchedProperties;

@class DiscountObject;




@interface ContactsID : NSManagedObjectID {}
@end

@interface _Contacts : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ContactsID*)objectID;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) DiscountObject *discountObject;

//- (BOOL)validateDiscountObject:(id*)value_ error:(NSError**)error_;





@end

@interface _Contacts (CoreDataGeneratedAccessors)

@end

@interface _Contacts (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;





- (DiscountObject*)primitiveDiscountObject;
- (void)setPrimitiveDiscountObject:(DiscountObject*)value;


@end
