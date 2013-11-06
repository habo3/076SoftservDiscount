// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Category.m instead.

#import "_Category.h"

const struct CategoryAttributes CategoryAttributes = {
	.created = @"created",
	.fontSymbol = @"fontSymbol",
	.id = @"id",
	.name = @"name",
	.published = @"published",
	.updated = @"updated",
};

const struct CategoryRelationships CategoryRelationships = {
	.discountObjects = @"discountObjects",
};

const struct CategoryFetchedProperties CategoryFetchedProperties = {
};

@implementation CategoryID
@end

@implementation _Category

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDCategory" inManagedObjectContext:moc_];
}

- (CategoryID*)objectID {
	return (CategoryID*)[super objectID];
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




@dynamic created;






@dynamic fontSymbol;






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





@dynamic updated;






@dynamic discountObjects;

	
- (NSMutableSet*)discountObjectsSet {
	[self willAccessValueForKey:@"discountObjects"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"discountObjects"];
  
	[self didAccessValueForKey:@"discountObjects"];
	return result;
}
	






@end
