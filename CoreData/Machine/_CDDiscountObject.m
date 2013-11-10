// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDDiscountObject.m instead.

#import "_CDDiscountObject.h"

const struct CDDiscountObjectAttributes CDDiscountObjectAttributes = {
	.address = @"address",
	.attachments = @"attachments",
	.category = @"category",
	.city = @"city",
	.created = @"created",
	.descriptionn = @"descriptionn",
	.discount = @"discount",
	.email = @"email",
	.geoPoint = @"geoPoint",
	.id = @"id",
	.isInFavorites = @"isInFavorites",
	.logo = @"logo",
	.name = @"name",
	.parent = @"parent",
	.phone = @"phone",
	.published = @"published",
	.pulse = @"pulse",
	.responsiblePersonInfo = @"responsiblePersonInfo",
	.site = @"site",
	.skype = @"skype",
	.updated = @"updated",
};

const struct CDDiscountObjectRelationships CDDiscountObjectRelationships = {
	.categorys = @"categorys",
	.cities = @"cities",
	.content = @"content",
	.favorite = @"favorite",
};

const struct CDDiscountObjectFetchedProperties CDDiscountObjectFetchedProperties = {
};

@implementation CDDiscountObjectID
@end

@implementation _CDDiscountObject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDDiscountObject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDDiscountObject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDDiscountObject" inManagedObjectContext:moc_];
}

- (CDDiscountObjectID*)objectID {
	return (CDDiscountObjectID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isInFavoritesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isInFavorites"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"publishedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"published"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic address;






@dynamic attachments;






@dynamic category;






@dynamic city;






@dynamic created;






@dynamic descriptionn;






@dynamic discount;






@dynamic email;






@dynamic geoPoint;






@dynamic id;






@dynamic isInFavorites;



- (BOOL)isInFavoritesValue {
	NSNumber *result = [self isInFavorites];
	return [result boolValue];
}

- (void)setIsInFavoritesValue:(BOOL)value_ {
	[self setIsInFavorites:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsInFavoritesValue {
	NSNumber *result = [self primitiveIsInFavorites];
	return [result boolValue];
}

- (void)setPrimitiveIsInFavoritesValue:(BOOL)value_ {
	[self setPrimitiveIsInFavorites:[NSNumber numberWithBool:value_]];
}





@dynamic logo;






@dynamic name;






@dynamic parent;






@dynamic phone;






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





@dynamic pulse;






@dynamic responsiblePersonInfo;






@dynamic site;






@dynamic skype;






@dynamic updated;






@dynamic categorys;

	
- (NSMutableSet*)categorysSet {
	[self willAccessValueForKey:@"categorys"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"categorys"];
  
	[self didAccessValueForKey:@"categorys"];
	return result;
}
	

@dynamic cities;

	

@dynamic content;

	

@dynamic favorite;

	






@end
