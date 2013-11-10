// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDCity.m instead.

#import "_CDCity.h"

const struct CDCityAttributes CDCityAttributes = {
	.bounds = @"bounds",
	.id = @"id",
	.name = @"name",
	.published = @"published",
};

const struct CDCityRelationships CDCityRelationships = {
	.content = @"content",
	.discountObjects = @"discountObjects",
};

const struct CDCityFetchedProperties CDCityFetchedProperties = {
};

@implementation CDCityID
@end

@implementation _CDCity

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

- (CDCityID*)objectID {
	return (CDCityID*)[super objectID];
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





@dynamic content;

	

@dynamic discountObjects;

	
- (NSMutableSet*)discountObjectsSet {
	[self willAccessValueForKey:@"discountObjects"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"discountObjects"];
  
	[self didAccessValueForKey:@"discountObjects"];
	return result;
}
	






@end
