// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to City.m instead.

#import "_City.h"

const struct CityAttributes CityAttributes = {
	.bounds = @"bounds",
	.id = @"id",
	.name = @"name",
	.published = @"published",
};

const struct CityRelationships CityRelationships = {
	.discountObjects = @"discountObjects",
};

const struct CityFetchedProperties CityFetchedProperties = {
};

@implementation CityID
@end

@implementation _City

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDCity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDCity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDCity" inManagedObjectContext:moc_];
}

- (CityID*)objectID {
	return (CityID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"publishedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"published"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic bounds;






@dynamic id;






@dynamic name;






@dynamic published;



- (BOOL)publishedValue {
	NSNumber *result = [self published];
	return [result boolValue];
}

- (void)setPublishedValue:(BOOL)value_ {
	[self setPublished:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePublishedValue {
	NSNumber *result = [self primitivePublished];
	return [result boolValue];
}

- (void)setPrimitivePublishedValue:(BOOL)value_ {
	[self setPrimitivePublished:[NSNumber numberWithBool:value_]];
}





@dynamic discountObjects;

	
- (NSMutableSet*)discountObjectsSet {
	[self willAccessValueForKey:@"discountObjects"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"discountObjects"];
  
	[self didAccessValueForKey:@"discountObjects"];
	return result;
}
	






@end
