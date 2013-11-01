//
//  CDCoreDataManager.m
//  DiscountJson
//
//  Created by Victor on 10/19/13.
//  Copyright (c) 2013 Victor. All rights reserved.
//

#import "CDCoreDataManager.h"
#import "CDDiscountObject.h"
#import "CDCategory.h"
#import "CDCity.h"
#import "CDFavorites.h"

@implementation CDCoreDataManager

@synthesize discountObject = _discountObject;
@synthesize cities = _cities;
@synthesize categories = _categories;
@synthesize managedObjectContex = _managedObjectContex;

-(NSManagedObjectContext *)managedObjectContex
{
    return [(AppDelegate*) [[UIApplication sharedApplication] delegate] managedObjectContextNew];
}

#pragma mark - Add to Favorites

-(void)addDiscountObjectToFavoritesWithObject:(CDDiscountObject*)discountObject
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDFavorites"];
    [fetchRequest setFetchLimit:1];
    
    if ([discountObject.isInFavorites isEqual:[NSNumber numberWithBool:YES]]) {
//        NSLog(@"Deleted from Favorites");
        NSArray *result = [self.managedObjectContex executeFetchRequest:fetchRequest error:nil];
        NSMutableSet *mutableSetOfFavorites = [NSMutableSet setWithSet:[[result objectAtIndex:0] valueForKey:@"discountObjects"]];
        [mutableSetOfFavorites removeObject:discountObject];
        
        CDFavorites *favorites = [result objectAtIndex:0];
        favorites.discountObjects = mutableSetOfFavorites;
        
        [self.managedObjectContex save:nil];
        discountObject.isInFavorites = @NO;
    }
    else
    {
//        NSLog(@"Added to Favorites");
        
        if (![self.managedObjectContex countForFetchRequest:fetchRequest error:nil]) {
            CDFavorites *newFavorites = [NSEntityDescription insertNewObjectForEntityForName:@"CDFavorites" inManagedObjectContext:self.managedObjectContex];
            [self.managedObjectContex save:nil];
        }
        
        NSArray *result = [self.managedObjectContex executeFetchRequest:fetchRequest error:nil];
        
        NSMutableSet *temp = [[NSMutableSet alloc] initWithSet:[[result objectAtIndex:0] valueForKey:@"discountObjects"]];
        [temp addObject:discountObject];
        
        CDFavorites *favorites = [result objectAtIndex:0];
        favorites.discountObjects = temp;
        
        discountObject.isInFavorites = @YES;
        [self.managedObjectContex save:nil];
        
    }
}

-(NSArray*)discountObjectsFromFavorites
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDFavorites"];
    [fetchRequest setFetchLimit:1];
    NSArray *result = [self.managedObjectContex executeFetchRequest:fetchRequest error:nil];
    if ([self.managedObjectContex countForFetchRequest:fetchRequest error:nil]) {        
        CDFavorites *favoritesSet = [result objectAtIndex:0];
        return [favoritesSet.discountObjects allObjects];
    }
    return nil;
}

#pragma mark - Discount Objects manipulations
-(void)saveDiscountObjectsToCoreData
{
    NSArray *cities = [self citiesFromCoreData];
    NSArray *categories = [self categoriesFromCoreData];
    
    for (NSDictionary *object in _discountObject) {
        if ([self isDiscountObjectValid:object]) {
            CDDiscountObject *newDiscountObject = [NSEntityDescription insertNewObjectForEntityForName:@"CDDiscountObject" inManagedObjectContext:self.managedObjectContex];
            
            for (NSString *key in object) {
                if ([key isEqualToString:@"responsiblePersonInfo"]) {
                    continue;                    
                }
                if ([key isEqualToString:@"description"]) {
                    if (![[object valueForKey:key] isKindOfClass:[NSNull class]]) {
                        [newDiscountObject setValue:[object valueForKey:key] forKey:@"descriptionn"];
                    }
                    continue;
                }
                if ([key isEqualToString:@"pulse"]) {
                    if (![[object valueForKey:key] isKindOfClass:[NSNull class]]) {
                        [newDiscountObject setValue:[object valueForKey:key] forKey:key];
                    }
                    continue;
                }
                if ([key isEqualToString:@"id"]) {
                    [newDiscountObject setValue:[[object valueForKey:key] stringValue] forKey:key];
                    continue;
                }
                if ([key isEqualToString:@"category"]) {
                    NSMutableArray *tempCategory = [[NSMutableArray alloc] init];
                    for (NSNumber *idNumber in [object valueForKey:key]) {
                        [tempCategory addObject:[idNumber stringValue]];
                    }                    
                    [newDiscountObject setValue:tempCategory forKey:key];
                    continue;
                }

                [newDiscountObject setValue:[object valueForKey:key] forKey:key];
                
            }
#pragma mark - makeRalations
            for (NSManagedObject *city in cities) {
                if ( [[city valueForKey:@"id"] isEqualToString:[object valueForKey:@"city"]]) {
                    //                NSLog(@"cityID: %@",[[city valueForKey:@"id"] stringValue]);
                    //                NSLog(@"objectCity: %@",[object valueForKey:@"city"]);
                    [newDiscountObject setValue:city forKey:@"cities"];
                }
            }
            for (NSString *objectCategory in [newDiscountObject valueForKey:@"category"]) { //[object valueForKey:@"category"]
                for (NSManagedObject *category in categories ) {
                    if ( [objectCategory isEqualToString:[category valueForKey:@"id"]]) {
                        //                    NSLog(@"CCC: %@", [category valueForKey:@"id"]);
                        //                    NSLog(@"DDD: %@", objectCategory);
                        NSMutableSet *temp = [[NSMutableSet alloc] initWithSet:[object valueForKey:@"categorys"]];
                        [temp addObject:category];
                        //[object setValue:temp forKey:@"categorys"];
                        [newDiscountObject setValue:temp forKey:@"categorys"];
                    }
                }
            }
            newDiscountObject.isInFavorites = @NO;
            [self.managedObjectContex save:nil];
            // TODO counter
        }
    }
}

-(NSArray*)discountObjectsFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDDiscountObject"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
    
    NSArray *result = [self.managedObjectContex executeFetchRequest:fetchRequest error:nil];
    return result;
}
#pragma mark - City Objects manipulations
-(void)saveCitiesToCoreData
{
    for (NSString *key in _cities.allKeys) {
        NSDictionary *tempCity = [_cities valueForKey:key];
        CDCategory *newCity = [NSEntityDescription insertNewObjectForEntityForName:@"CDCity" inManagedObjectContext:self.managedObjectContex];
        for (NSString *key in tempCity) {
            if ([key isEqualToString:@"id"]) {
                [newCity setValue:[[tempCity valueForKey:key] stringValue] forKey:key];
                continue;
            }
            [newCity setValue:[tempCity valueForKey:key] forKey:key];
        }
        [self.managedObjectContex save:nil];
        // TODO counter
    }
}

-(NSArray*)citiesFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDCity"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray *result = [self.managedObjectContex executeFetchRequest:fetchRequest error:nil];
    return result;
}
#pragma mark - Category Objects manipulations
-(void)saveCategoriesToCoreData
{    
    for (NSString *key in _categories.allKeys) {
        NSDictionary *tempCategory = [_categories valueForKey:key];
        CDCategory *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"CDCategory" inManagedObjectContext:self.managedObjectContex];
        for (NSString *key in tempCategory) {
            if ([key isEqualToString:@"id"]) {
                [newCategory setValue:[[tempCategory valueForKey:key] stringValue] forKey:key];
                continue;
            }
            [newCategory setValue:[tempCategory valueForKey:key] forKey:key];
        }
        [self.managedObjectContex save:nil];
        // TODO counter
    }
}

-(NSArray*)categoriesFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDCategory"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSArray *result = [self.managedObjectContex executeFetchRequest:fetchRequest error:nil];
    return result;
}
#pragma mark - Check is Discount object valid
-(BOOL)isDiscountObjectValid:(NSDictionary*)object
{
    
    if ([[[object valueForKey:@"geoPoint"] valueForKey:@"latitude"] doubleValue]== 0.0 && [[[object valueForKey:@"geoPoint"] valueForKey:@"longitude"] doubleValue] == 0.0)
    {
        return NO;
    }
        
    if (![[object valueForKey:@"logo"] isKindOfClass:[NSDictionary class]])
    {
        return NO;
    }
    
    if (![[object valueForKey:@"address"] isKindOfClass:[NSString class]])
    {
        return NO;
    }
    
    if ([[[object valueForKey:@"discount"] valueForKey:@"from" ] isKindOfClass:[NSNull class]] || [[[object valueForKey:@"discount"] valueForKey:@"to" ] isKindOfClass:[NSNull class]])
    {
        return NO;
    }
    return YES;
}
#pragma mark - Refresh CoreData
-(void)deleteAllData
{
    NSFetchRequest *allDiscountObjects = [NSFetchRequest fetchRequestWithEntityName:@"CDDiscountObject"];
    allDiscountObjects.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
    
    NSArray *discountObjects = [self.managedObjectContex executeFetchRequest:allDiscountObjects error:nil];
    
    for (NSManagedObject * obj in discountObjects) {
        [self.managedObjectContex deleteObject:obj];
    }
    
    NSFetchRequest * allCategories = [[NSFetchRequest alloc] init];
    [allCategories setEntity:[NSEntityDescription entityForName:@"CDCategory" inManagedObjectContext:self.managedObjectContex]];
    [allCategories setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSArray * categories = [self.managedObjectContex executeFetchRequest:allCategories error:Nil];
    
    for (NSManagedObject * category in categories) {
        [self.managedObjectContex deleteObject:category];
    }
    
    NSFetchRequest * allCities = [[NSFetchRequest alloc] init];
    [allCities setEntity:[NSEntityDescription entityForName:@"CDCity" inManagedObjectContext:self.managedObjectContex]];
    [allCities setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSArray * cities = [self.managedObjectContex executeFetchRequest:allCities error:Nil];
    
    for (NSManagedObject * city in cities) {
        [self.managedObjectContex deleteObject:city];
    }
    
    //Delete Favorites
    
    NSFetchRequest * allFavorites = [[NSFetchRequest alloc] init];
    [allFavorites setEntity:[NSEntityDescription entityForName:@"CDFavorites" inManagedObjectContext:self.managedObjectContex]];
    [allFavorites setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSArray * favorites = [self.managedObjectContex executeFetchRequest:allFavorites error:Nil];
    
    for (NSManagedObject * obj in favorites) {
        [self.managedObjectContex deleteObject:obj];
    }

}
#pragma mark - Now useless
-(void)makeRelationsBetweenCategoriesAndObjectsAndCities
{
    NSArray *discountObjects = [self discountObjectsFromCoreData];
    NSArray *cities = [self citiesFromCoreData];
    NSArray *categories = [self categoriesFromCoreData];
    
    for (NSManagedObject *object in discountObjects) {
//        NSLog(@"category: %@",[object valueForKey:@"category"]);

        
        for (NSManagedObject *city in cities) {
            if ( [[city valueForKey:@"id"] isEqualToString:[object valueForKey:@"city"]]) {
//                NSLog(@"cityID: %@",[[city valueForKey:@"id"] stringValue]);
//                NSLog(@"objectCity: %@",[object valueForKey:@"city"]);
                [object setValue:city forKey:@"cities"];
                
            }
        }
        
        for (NSString *objectCategory in [object valueForKey:@"category"]) {
            for (NSManagedObject *category in categories ) {
                if ( [objectCategory isEqualToString:[category valueForKey:@"id"]]) {
//                    NSLog(@"CCC: %@", [category valueForKey:@"id"]);
//                    NSLog(@"DDD: %@", objectCategory);
                    NSMutableSet *temp = [[NSMutableSet alloc] initWithSet:[object valueForKey:@"categorys"]];
                    [temp addObject:category];
                    [object setValue:temp forKey:@"categorys"];
                }
            }
        }
    }
    //    NSManagedObject *obj1 = [result objectAtIndex:0];
    //    [obj1 setValue:@"texter96" forKey:@"skype"];
    [self.managedObjectContex save:nil];
}

@end
