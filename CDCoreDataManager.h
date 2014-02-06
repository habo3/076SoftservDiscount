//
//  CDCoreDataManager.h
//  DiscountJson
//
//  Created by Victor on 10/19/13.
//  Copyright (c) 2013 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@class CDDiscountObject;

@interface CDCoreDataManager : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSArray *discountObject;
@property (nonatomic, strong) NSDictionary *cities;
@property (nonatomic, strong) NSDictionary *categories;

-(void)saveDiscountObjectsToCoreData;
-(void)saveCitiesToCoreData;
-(void)saveCategoriesToCoreData;
-(void)addDiscountObjectToFavoritesWithObject:(CDDiscountObject*)discountObject;
-(void)addDiscountObjectToFavoritesWithDictionaryObjects:(NSDictionary*)favoriteObjects;
-(BOOL)isCoreDataEntityExist;
-(void)deleteAllCoreData;
-(void)deleteAllFavorites;
-(UIImage*)checkImageInObjectExistForDiscountObject:(CDDiscountObject*)discountObject;
-(void)saveData;

-(NSArray*)discountObjectsFromCoreData;
-(NSArray*)citiesFromCoreData;
-(NSArray*)categoriesFromCoreData;
-(NSArray*)discountObjectsFromFavorites;

+ (CDCoreDataManager*)sharedInstance;

+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));


@end
