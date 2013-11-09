// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDContent.m instead.

#import "_CDContent.h"

const struct CDContentAttributes CDContentAttributes = {
	.apiVersion = @"apiVersion",
};

const struct CDContentRelationships CDContentRelationships = {
	.catrgories = @"catrgories",
	.cities = @"cities",
	.discountObjects = @"discountObjects",
	.favorites = @"favorites",
};

const struct CDContentFetchedProperties CDContentFetchedProperties = {
};

@implementation CDContentID
@end

@implementation _CDContent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDContent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDContent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDContent" inManagedObjectContext:moc_];
}

- (CDContentID*)objectID {
	return (CDContentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic apiVersion;






@dynamic catrgories;

	
- (NSMutableSet*)catrgoriesSet {
	[self willAccessValueForKey:@"catrgories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"catrgories"];
  
	[self didAccessValueForKey:@"catrgories"];
	return result;
}
	

@dynamic cities;

	
- (NSMutableSet*)citiesSet {
	[self willAccessValueForKey:@"cities"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"cities"];
  
	[self didAccessValueForKey:@"cities"];
	return result;
}
	

@dynamic discountObjects;

	
- (NSMutableSet*)discountObjectsSet {
	[self willAccessValueForKey:@"discountObjects"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"discountObjects"];
  
	[self didAccessValueForKey:@"discountObjects"];
	return result;
}
	

@dynamic favorites;

	
- (NSMutableSet*)favoritesSet {
	[self willAccessValueForKey:@"favorites"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"favorites"];
  
	[self didAccessValueForKey:@"favorites"];
	return result;
}
	






@end
