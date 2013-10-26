// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Contacts.m instead.

#import "_Contacts.h"

const struct ContactsAttributes ContactsAttributes = {
	.type = @"type",
	.value = @"value",
};

const struct ContactsRelationships ContactsRelationships = {
	.discountObject = @"discountObject",
};

const struct ContactsFetchedProperties ContactsFetchedProperties = {
};

@implementation ContactsID
@end

@implementation _Contacts

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Contact";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:moc_];
}

- (ContactsID*)objectID {
	return (ContactsID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic type;






@dynamic value;






@dynamic discountObject;

	






@end
