// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDFavorites.m instead.

#import "_CDFavorites.h"

const struct CDFavoritesAttributes CDFavoritesAttributes = {
};

const struct CDFavoritesRelationships CDFavoritesRelationships = {
	.discountObjects = @"discountObjects",
};

const struct CDFavoritesFetchedProperties CDFavoritesFetchedProperties = {
};

@implementation CDFavoritesID
@end

@implementation _CDFavorites

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDFavorites" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDFavorites";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDFavorites" inManagedObjectContext:moc_];
}

- (CDFavoritesID*)objectID {
	return (CDFavoritesID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic discountObjects;

	
- (NSMutableSet*)discountObjectsSet {
	[self willAccessValueForKey:@"discountObjects"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"discountObjects"];
  
	[self didAccessValueForKey:@"discountObjects"];
	return result;
}
	






@end
