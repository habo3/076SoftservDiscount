// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DiscountObject.m instead.

#import "_DiscountObject.h"

const struct DiscountObjectAttributes DiscountObjectAttributes = {
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

const struct DiscountObjectRelationships DiscountObjectRelationships = {
	.categorys = @"categorys",
	.cities = @"cities",
	.favorite = @"favorite",
};

const struct DiscountObjectFetchedProperties DiscountObjectFetchedProperties = {
};

@implementation DiscountObjectID
@end

@implementation _DiscountObject

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

- (DiscountObjectID*)objectID {
	return (DiscountObjectID*)[super objectID];
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

	

@dynamic favorite;

	






@end
