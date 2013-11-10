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
    return [(AppDelegate*) [[UIApplication sharedApplication] delegate] managedObjectContext];
}

+ (CDCoreDataManager *)sharedInstance
{
    static CDCoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initUniqueInstance];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(instancetype) initUniqueInstance {
    return [super init];
}

#pragma mark - Add to Favorites

-(void)addDiscountObjectToFavoritesWithObject:(CDDiscountObject*)discountObject
{
    CDFavorites *favorites = [self favoritesFromCoreData];
    
    if ([discountObject.isInFavorites isEqual:[NSNumber numberWithBool:YES]]) {
        [favorites.discountObjectsSet removeObject:discountObject];
        discountObject.isInFavorites = @NO;
    }
    else
    {
        [favorites.discountObjectsSet addObject:discountObject];
        discountObject.isInFavorites = @YES;
    }
    [self.managedObjectContex save:nil];
}

-(CDFavorites*)favoritesFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDFavorites"];
    [fetchRequest setFetchLimit:1];
    if (![self.managedObjectContex countForFetchRequest:fetchRequest error:nil]) {
        CDFavorites *newFavorites;
        newFavorites = [NSEntityDescription insertNewObjectForEntityForName:@"CDFavorites" inManagedObjectContext:self.managedObjectContex];
        newFavorites.content = [self contentFromCoreData];
        [self.managedObjectContex save:nil];
    }
    NSArray *resultFavorites = [self.managedObjectContex executeFetchRequest:fetchRequest error:nil];
    return [resultFavorites objectAtIndex:0];
}

-(NSArray*)discountObjectsFromFavorites
{
    CDFavorites *favorites = [self favoritesFromCoreData];
    if (favorites) {
        return [favorites.discountObjects allObjects];
    }
    return nil;
}

#pragma mark - Discount Objects manipulations
-(void)saveDiscountObjectsToCoreData
{
    NSArray *cities = [self citiesFromCoreData];
    NSArray *categories = [self categoriesFromCoreData];
    CDContent *contentFromCoreData = [self contentFromCoreData];
    
    for (NSDictionary *object in _discountObject) {
        CDDiscountObject *newDiscountObject = [CDDiscountObject createWithDictionary:object andContext:self.managedObjectContex];
        if (newDiscountObject) {
#pragma mark - makeRalations
            for (CDCity *city in cities) {
                if ( [[city valueForKey:@"id"] isEqualToString:[object valueForKey:@"city"]]) {
                    newDiscountObject.cities = city;
                }
            }
            for (NSString *objectCategory in [newDiscountObject valueForKey:@"category"]) {
                for (CDCategory *category in categories ) {
                    if ( [objectCategory isEqualToString:[category valueForKey:@"id"]]) {
                        [newDiscountObject.categorysSet addObject:category];
                    }
                }
            }
            newDiscountObject.isInFavorites = @NO;
            newDiscountObject.content = contentFromCoreData;
            [self.managedObjectContex save:nil];
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
    CDContent *contentFromCoreData = [self contentFromCoreData];
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
        newCity.content = contentFromCoreData;
        [self.managedObjectContex save:nil];
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
    CDContent *contentFromCoreData = [self contentFromCoreData];
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
        newCategory.content = contentFromCoreData;
        [self.managedObjectContex save:nil];
    }
}

-(NSArray*)categoriesFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDCategory"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSArray *result = [self.managedObjectContex executeFetchRequest:fetchRequest error:nil];
    return result;
}

#pragma mark - IsCoreDataExist

-(BOOL)isCoreDataEntityExist
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDDiscountObject"];
    [fetchRequest setFetchLimit:1];
    if (![self.managedObjectContex countForFetchRequest:fetchRequest error:nil]) {
        return NO;
    }
    return YES;
}

#pragma mark - Refresh CoreData
//-(void)deleteAllData
//{
//    NSFetchRequest *allDiscountObjects = [NSFetchRequest fetchRequestWithEntityName:@"CDDiscountObject"];
//    allDiscountObjects.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
//    
//    NSArray *discountObjects = [self.managedObjectContex executeFetchRequest:allDiscountObjects error:nil];
//    
//    for (NSManagedObject * obj in discountObjects) {
//        [self.managedObjectContex deleteObject:obj];
//    }
//    
//    NSFetchRequest * allCategories = [[NSFetchRequest alloc] init];
//    [allCategories setEntity:[NSEntityDescription entityForName:@"CDCategory" inManagedObjectContext:self.managedObjectContex]];
//    [allCategories setIncludesPropertyValues:NO]; //only fetch the managedObjectID
//    
//    NSArray * categories = [self.managedObjectContex executeFetchRequest:allCategories error:Nil];
//    
//    for (NSManagedObject * category in categories) {
//        [self.managedObjectContex deleteObject:category];
//    }
//    
//    NSFetchRequest * allCities = [[NSFetchRequest alloc] init];
//    [allCities setEntity:[NSEntityDescription entityForName:@"CDCity" inManagedObjectContext:self.managedObjectContex]];
//    [allCities setIncludesPropertyValues:NO]; //only fetch the managedObjectID
//    
//    NSArray * cities = [self.managedObjectContex executeFetchRequest:allCities error:Nil];
//    
//    for (NSManagedObject * city in cities) {
//        [self.managedObjectContex deleteObject:city];
//    }
//    
//    //Delete Favorites
//    
//    NSFetchRequest * allFavorites = [[NSFetchRequest alloc] init];
//    [allFavorites setEntity:[NSEntityDescription entityForName:@"CDFavorites" inManagedObjectContext:self.managedObjectContex]];
//    [allFavorites setIncludesPropertyValues:NO]; //only fetch the managedObjectID
//    
//    NSArray * favorites = [self.managedObjectContex executeFetchRequest:allFavorites error:Nil];
//    
//    for (NSManagedObject * obj in favorites) {
//        [self.managedObjectContex deleteObject:obj];
//    }
//
//}

-(void)deleteAllCoreData
{
    [self.managedObjectContex deleteObject:(NSManagedObject*)[self contentFromCoreData]];
    [self.managedObjectContex save:nil];
}

#pragma mark - Get CDContent

-(CDContent*)contentFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDContent"];
    [fetchRequest setFetchLimit:1];
    if (![self.managedObjectContex countForFetchRequest:fetchRequest error:nil]) {
        CDContent *newContent;
        newContent = [NSEntityDescription insertNewObjectForEntityForName:@"CDContent" inManagedObjectContext:self.managedObjectContex];
        [self.managedObjectContex save:nil];
    }
    
    NSArray *resultContent = [self.managedObjectContex executeFetchRequest:fetchRequest error:nil];
    
    return [resultContent objectAtIndex:0];
}

//#pragma mark - Now useless
//-(void)makeRelationsBetweenCategoriesAndObjectsAndCities
//{
//    NSArray *discountObjects = [self discountObjectsFromCoreData];
//    NSArray *cities = [self citiesFromCoreData];
//    NSArray *categories = [self categoriesFromCoreData];
//    
//    for (NSManagedObject *object in discountObjects) {
////        NSLog(@"category: %@",[object valueForKey:@"category"]);
//
//        
//        for (NSManagedObject *city in cities) {
//            if ( [[city valueForKey:@"id"] isEqualToString:[object valueForKey:@"city"]]) {
////                NSLog(@"cityID: %@",[[city valueForKey:@"id"] stringValue]);
////                NSLog(@"objectCity: %@",[object valueForKey:@"city"]);
//                [object setValue:city forKey:@"cities"];
//                
//            }
//        }
//        
//        for (NSString *objectCategory in [object valueForKey:@"category"]) {
//            for (NSManagedObject *category in categories ) {
//                if ( [objectCategory isEqualToString:[category valueForKey:@"id"]]) {
////                    NSLog(@"CCC: %@", [category valueForKey:@"id"]);
////                    NSLog(@"DDD: %@", objectCategory);
//                    NSMutableSet *temp = [[NSMutableSet alloc] initWithSet:[object valueForKey:@"categorys"]];
//                    [temp addObject:category];
//                    [object setValue:temp forKey:@"categorys"];
//                }
//            }
//        }
//    }
//    //    NSManagedObject *obj1 = [result objectAtIndex:0];
//    //    [obj1 setValue:@"texter96" forKey:@"skype"];
//    [self.managedObjectContex save:nil];
//}



@end
