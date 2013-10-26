// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Category.m instead.

#import "_Category.h"

const struct CategoryAttributes CategoryAttributes = {
	.attribute = @"attribute",
	.created = @"created",
	.fontSymbol = @"fontSymbol",
	.id = @"id",
	.name = @"name",
	.updated = @"updated",
};

const struct CategoryRelationships CategoryRelationships = {
	.discountobject = @"discountobject",
};

const struct CategoryFetchedProperties CategoryFetchedProperties = {
};

@implementation CategoryID
@end

@implementation _Category

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Category";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc_];
}

- (CategoryID*)objectID {
	return (CategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"createdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"created"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"updatedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"updated"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic attribute;






@dynamic created;



- (int16_t)createdValue {
	NSNumber *result = [self created];
	return [result shortValue];
}

- (void)setCreatedValue:(int16_t)value_ {
	[self setCreated:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveCreatedValue {
	NSNumber *result = [self primitiveCreated];
	return [result shortValue];
}

- (void)setPrimitiveCreatedValue:(int16_t)value_ {
	[self setPrimitiveCreated:[NSNumber numberWithShort:value_]];
}





@dynamic fontSymbol;






@dynamic id;



- (int16_t)idValue {
	NSNumber *result = [self id];
	return [result shortValue];
}

- (void)setIdValue:(int16_t)value_ {
	[self setId:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIdValue {
	NSNumber *result = [self primitiveId];
	return [result shortValue];
}

- (void)setPrimitiveIdValue:(int16_t)value_ {
	[self setPrimitiveId:[NSNumber numberWithShort:value_]];
}





@dynamic name;






@dynamic updated;



- (int16_t)updatedValue {
	NSNumber *result = [self updated];
	return [result shortValue];
}

- (void)setUpdatedValue:(int16_t)value_ {
	[self setUpdated:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveUpdatedValue {
	NSNumber *result = [self primitiveUpdated];
	return [result shortValue];
}

- (void)setPrimitiveUpdatedValue:(int16_t)value_ {
	[self setPrimitiveUpdated:[NSNumber numberWithShort:value_]];
}





@dynamic discountobject;

	
- (NSMutableSet*)discountobjectSet {
	[self willAccessValueForKey:@"discountobject"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"discountobject"];
  
	[self didAccessValueForKey:@"discountobject"];
	return result;
}
	






@end
