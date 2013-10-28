//
//  CDCoreDataManager.h
//  DiscountJson
//
//  Created by Victor on 10/19/13.
//  Copyright (c) 2013 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface CDCoreDataManager : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContex;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSArray *discountObject;
@property (nonatomic, strong) NSDictionary *cities;
@property (nonatomic, strong) NSDictionary *categories;

-(void)saveDiscountObjectsToCoreData;
-(void)saveCitiesToCoreData;
-(void)saveCategoriesToCoreData;
-(void)deleteAllData;
-(void)makeRelationsBetweenCategoriesAndObjectsAndCities;

-(NSArray*)discountObjectsFromCoreData;
-(NSArray*)citiesFromCoreData;
-(NSArray*)categoriesFromCoreData;

@end
