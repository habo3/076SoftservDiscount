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

@interface CDCoreDataManager() {
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectModel *_managedObjectModel;
}
@end

@implementation CDCoreDataManager

@synthesize discountObject = _discountObject;
@synthesize cities = _cities;
@synthesize categories = _categories;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;

-(NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewModel19.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NewModel" withExtension:@"momd"];
    //NSLog(@"%@",modelURL);
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (CDCoreDataManager *)sharedInstance
{
    static CDCoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initUniqueInstance];
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
    [self.managedObjectContext save:nil];
}

-(void)addDiscountObjectToFavoritesWithDictionaryObjects:(NSDictionary*)favoriteObjects
{
    for (NSString *key in [favoriteObjects allKeys]) {
        NSDictionary *objDict = [favoriteObjects valueForKey:key];
        CDDiscountObject *favoriteObject = [CDDiscountObject checkDiscountExistForDictionary:objDict andContext:self.managedObjectContext elseCreateNew:NO];
        if (favoriteObject) {
            if ([favoriteObject.isInFavorites isEqual:@NO] || !favoriteObject.isInFavorites) {
                [self addDiscountObjectToFavoritesWithObject:favoriteObject];
            }
        }
    }
}

-(CDFavorites*)favoritesFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDFavorites"];
    [fetchRequest setFetchLimit:1];
    if (![self.managedObjectContext countForFetchRequest:fetchRequest error:nil]) {
        CDFavorites *newFavorites;
        newFavorites = [NSEntityDescription insertNewObjectForEntityForName:@"CDFavorites" inManagedObjectContext:self.managedObjectContext];
        newFavorites.content = [self contentFromCoreData];
        [self.managedObjectContext save:nil];
    }
    NSArray *resultFavorites = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
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
    
    int idx = 0;
    for (NSDictionary *object in _discountObject) {
        
        CDDiscountObject *newDiscountObject = [CDDiscountObject checkDiscountExistForDictionary:object
                                                                                     andContext:self.managedObjectContext
                                                                                  elseCreateNew:YES];
        if (newDiscountObject) {
            for (CDCity *city in cities) {
                if ( [[city valueForKey:@"id"] isEqualToString:[object valueForKey:@"city"]]) {
                    newDiscountObject.cities = city;
                }
            }
            
            NSArray *jsonCategories = [newDiscountObject valueForKey:@"category"];
            for (NSString *objectCategory in jsonCategories) {
                for (CDCategory *category in categories ) {
                    if ( [objectCategory isEqualToString:[category valueForKey:@"id"]]) {
                        [newDiscountObject addCategorysObject:category];
                    }
                }
            }
            newDiscountObject.content = contentFromCoreData;
        }
        ++idx;
        NSLog(@"%d", idx);
    }
    [self.managedObjectContext save:nil];
}


-(NSArray*)discountObjectsFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDDiscountObject"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return result;
}

#pragma mark - City Objects manipulations
-(void)saveCitiesToCoreData
{
    CDContent *contentFromCoreData = [self contentFromCoreData];
    for (NSString *key in _cities.allKeys) {
        NSDictionary *tempCity = [_cities valueForKey:key];
        CDCategory *newCity = [NSEntityDescription insertNewObjectForEntityForName:@"CDCity" inManagedObjectContext:self.managedObjectContext];
        for (NSString *key in tempCity) {
            if ([key isEqualToString:@"id"]) {
                [newCity setValue:[[tempCity valueForKey:key] stringValue] forKey:key];
                continue;
            }
            [newCity setValue:[tempCity valueForKey:key] forKey:key];
        }
        newCity.content = contentFromCoreData;
    }
    [self.managedObjectContext save:nil];
}

-(NSArray*)citiesFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDCity"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return result;
}

#pragma mark - Category Objects manipulations
-(void)saveCategoriesToCoreData
{
    CDContent *contentFromCoreData = [self contentFromCoreData];
    for (NSString *key in _categories.allKeys) {
        NSDictionary *tempCategory = [_categories valueForKey:key];
        CDCategory *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"CDCategory" inManagedObjectContext:self.managedObjectContext];
        for (NSString *key in tempCategory) {
            if ([key isEqualToString:@"id"]) {
                [newCategory setValue:[[tempCategory valueForKey:key] stringValue] forKey:key];
                continue;
            }
            [newCategory setValue:[tempCategory valueForKey:key] forKey:key];
        }
        newCategory.content = contentFromCoreData;
    }
    [self.managedObjectContext save:nil];
}

-(NSArray*)categoriesFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDCategory"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return result;
}

#pragma mark - IsCoreDataExist

-(BOOL)isCoreDataEntityExist
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDDiscountObject"];
    [fetchRequest setFetchLimit:1];
    if (![self.managedObjectContext countForFetchRequest:fetchRequest error:nil]) {
        return NO;
    }
    return YES;
}

#pragma mark - IsImageInObjectExist

-(UIImage*)checkImageInObjectExistForDiscountObject:(CDDiscountObject*)discountObject
{
    if (discountObject.image == nil) {
        NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
        NSString *http = [NSString stringWithString:[dictRoot objectForKey:@"WebSite"]];
        NSString *imageUrl = [http stringByAppendingString:[discountObject.logo valueForKey:@"src"]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        discountObject.image = UIImagePNGRepresentation(image);
    }
    UIImage *objectImage = [UIImage imageWithData:discountObject.image];
    return objectImage;
}

#pragma mark - Refresh CoreData

-(void)deleteAllCoreData
{
    [self.managedObjectContext deleteObject:(NSManagedObject*)[self contentFromCoreData]];
    [self.managedObjectContext save:nil];
}

#pragma mark - Refresh Favorites

-(void)deleteAllFavorites
{
    for (CDDiscountObject *discountObject in [self favoritesFromCoreData].discountObjects) {
        discountObject.isInFavorites = @NO;
    }
    [self.managedObjectContext deleteObject:(NSManagedObject*)[self favoritesFromCoreData]];
    [self.managedObjectContext save:nil];
}

#pragma mark - Get CDContent

-(CDContent*)contentFromCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDContent"];
    [fetchRequest setFetchLimit:1];
    if (![self.managedObjectContext countForFetchRequest:fetchRequest error:nil]) {
        CDContent *newContent;
        newContent = [NSEntityDescription insertNewObjectForEntityForName:@"CDContent" inManagedObjectContext:self.managedObjectContext];
        [self.managedObjectContext save:nil];
    }
    
    NSArray *resultContent = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return [resultContent objectAtIndex:0];
}

-(void)saveData
{
    [self.managedObjectContext save:nil];
}

@end
