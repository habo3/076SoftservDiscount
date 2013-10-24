// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DiscountObject.m instead.

#import "_DiscountObject.h"

const struct DiscountObjectAttributes DiscountObjectAttributes = {
	.address = @"address",
	.created = @"created",
	.discountFrom = @"discountFrom",
	.discountTo = @"discountTo",
	.geoLatitude = @"geoLatitude",
	.geoLongitude = @"geoLongitude",
	.id = @"id",
	.inFavorites = @"inFavorites",
	.name = @"name",
	.responsiblePersonInfo = @"responsiblePersonInfo",
	.updated = @"updated",
};

const struct DiscountObjectRelationships DiscountObjectRelationships = {
	.categories = @"categories",
	.cities = @"cities",
	.contacts = @"contacts",
};

const struct DiscountObjectFetchedProperties DiscountObjectFetchedProperties = {
};

@implementation DiscountObjectID
@end

@implementation _DiscountObject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DiscountObject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DiscountObject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DiscountObject" inManagedObjectContext:moc_];
}

- (DiscountObjectID*)objectID {
	return (DiscountObjectID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"discountFromValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"discountFrom"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"discountToValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"discountTo"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"geoLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"geoLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"geoLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"geoLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"inFavoritesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"inFavorites"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic address;






@dynamic created;






@dynamic discountFrom;



- (int16_t)discountFromValue {
	NSNumber *result = [self discountFrom];
	return [result shortValue];
}

- (void)setDiscountFromValue:(int16_t)value_ {
	[self setDiscountFrom:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveDiscountFromValue {
	NSNumber *result = [self primitiveDiscountFrom];
	return [result shortValue];
}

- (void)setPrimitiveDiscountFromValue:(int16_t)value_ {
	[self setPrimitiveDiscountFrom:[NSNumber numberWithShort:value_]];
}





@dynamic discountTo;



- (int16_t)discountToValue {
	NSNumber *result = [self discountTo];
	return [result shortValue];
}

- (void)setDiscountToValue:(int16_t)value_ {
	[self setDiscountTo:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveDiscountToValue {
	NSNumber *result = [self primitiveDiscountTo];
	return [result shortValue];
}

- (void)setPrimitiveDiscountToValue:(int16_t)value_ {
	[self setPrimitiveDiscountTo:[NSNumber numberWithShort:value_]];
}





@dynamic geoLatitude;



- (double)geoLatitudeValue {
	NSNumber *result = [self geoLatitude];
	return [result doubleValue];
}

- (void)setGeoLatitudeValue:(double)value_ {
	[self setGeoLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveGeoLatitudeValue {
	NSNumber *result = [self primitiveGeoLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveGeoLatitudeValue:(double)value_ {
	[self setPrimitiveGeoLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic geoLongitude;



- (double)geoLongitudeValue {
	NSNumber *result = [self geoLongitude];
	return [result doubleValue];
}

- (void)setGeoLongitudeValue:(double)value_ {
	[self setGeoLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveGeoLongitudeValue {
	NSNumber *result = [self primitiveGeoLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveGeoLongitudeValue:(double)value_ {
	[self setPrimitiveGeoLongitude:[NSNumber numberWithDouble:value_]];
}





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





@dynamic inFavorites;



- (BOOL)inFavoritesValue {
	NSNumber *result = [self inFavorites];
	return [result boolValue];
}

- (void)setInFavoritesValue:(BOOL)value_ {
	[self setInFavorites:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveInFavoritesValue {
	NSNumber *result = [self primitiveInFavorites];
	return [result boolValue];
}

- (void)setPrimitiveInFavoritesValue:(BOOL)value_ {
	[self setPrimitiveInFavorites:[NSNumber numberWithBool:value_]];
}





@dynamic name;






@dynamic responsiblePersonInfo;






@dynamic updated;






@dynamic categories;

	
- (NSMutableSet*)categoriesSet {
	[self willAccessValueForKey:@"categories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"categories"];
  
	[self didAccessValueForKey:@"categories"];
	return result;
}
	

@dynamic cities;

	

@dynamic contacts;

	
- (NSMutableSet*)contactsSet {
	[self willAccessValueForKey:@"contacts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"contacts"];
  
	[self didAccessValueForKey:@"contacts"];
	return result;
}
	






@end
