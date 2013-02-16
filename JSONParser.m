//
//  JSONParser.m
//  SoftServeDP
//
//  Created by Bogdan on 09.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "JSONParser.h"
#import "Category.h"
#import "City.h"
#import "DiscountObject.h"
#import "Contacts.h"

@interface DiscountObject (Parsing)

- (void)parseAttribute:(id)attr forKey:(NSString *)key;
- (void)parseContact:(NSArray *)contacts type:(NSString *)type;
- (void)parseCity:(NSNumber *)cityId;
- (void)parseCategory:(NSArray *)catArray;

@end

@implementation DiscountObject (Parsing)

- (void)parseAttribute:(id)attr forKey:(NSString *)key
{
    NSSet *willParse = [NSSet setWithObjects:
                        @"id",
                        @"created",
                        @"updated",
                        @"name",
                        @"address",
                        @"responsiblePersonInfo",
                        @"geoPoint",
                        @"discount",
                        @"city",
                        @"category",
                        @"phone",
                        @"email",
                        @"site", nil];
    
    if (![willParse containsObject:key]) {
        return;
    }
    if ([key isEqualToString:@"phone"] || [key isEqualToString:@"site"] || [key isEqualToString:@"email"]) {
        [self parseContact:attr type:key];
    }
    else if ([key isEqualToString:@"category"]) {
        [self parseCategory:attr];
    }
    else if ([key isEqualToString:@"city"]) {
        if ([attr isKindOfClass:[NSNumber class]]) {
            [self parseCity:attr];
        }
    }
    else if ([key isEqualToString:@"geoPoint"]) {
        NSDictionary *geoPoint = attr;
        self.geoLongitude = [geoPoint valueForKey:@"longitude"];
        self.geoLatitude = [geoPoint valueForKey:@"latitude"];
    }
    else if ([key isEqualToString:@"discount"]) {
        if ([attr isKindOfClass:[NSDictionary class]]) {
            if (!([attr valueForKey:@"from"] == [NSNull null])) {
                self.discountFrom = [attr valueForKey:@"from"];
            }
            if (!([attr valueForKey:@"to"] == [NSNull null])) {
                self.discountTo = [attr valueForKey:@"to"];
            }
        }
    } else {
        [self setValue:attr forKey:key];
    }
}

- (void)parseContact:(NSArray *)contacts type:(NSString *) type
{
    
    for (NSString *key in contacts) {
        Contacts *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                          inManagedObjectContext:self.managedObjectContext];
        contact.type = type;
        contact.value = key;

        //set relations
        [self addContactsObject:contact];
        contact.discountObject = self;
    }
}

- (void)parseCategory:(NSArray *)catArray{

    NSPredicate *catFind = [NSPredicate predicateWithFormat:@"id IN %@",catArray];
    NSFetchRequest *objFetch=[[NSFetchRequest alloc] init];
    [objFetch setEntity:[NSEntityDescription entityForName:@"Category"
                                    inManagedObjectContext:self.managedObjectContext]];
    [objFetch setPredicate:catFind];
    NSArray *catFound = [self.managedObjectContext executeFetchRequest:objFetch error:nil];
    [self addCategories: [NSSet setWithArray:catFound]];
}

- (void)parseCity:(NSNumber *)cityId{
    
    NSPredicate *cityFind = [NSPredicate predicateWithFormat:@"id = %@", cityId];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"City"
                                 inManagedObjectContext:self.managedObjectContext]];
    [fetch setPredicate:cityFind];
    NSArray *cityIdFound = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    self.cities = [cityIdFound objectAtIndex:0];
}

@end

@interface JSONParser ()

@end


@implementation JSONParser

@synthesize managedObjectContext;

- (void)updateDBWithTimer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *updatePeriod = [userDefaults objectForKey:@"updatePeriod"];
    if (updatePeriod > 0) {
        int interval = [updatePeriod intValue];
        [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateDB) userInfo:nil repeats:YES];
    }
    else if (updatePeriod == 0) {
        [self updateDB];
    }
}

- (void)updateDB {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdate = [userDefaults objectForKey:@"lastDBUpdate"];
    int lastUpdateInt =[lastUpdate timeIntervalSince1970];
    NSString *parameterString = [NSString stringWithFormat:@"?changed=%d", lastUpdateInt];
    [self insertCities:parameterString];
    [self updateCategories:parameterString];
    [self insertObject2:parameterString];

}

- (NSDictionary *)getJsonDictionaryFromURL: (NSString *)url{
    
    //make request
    NSHTTPURLResponse *resp = nil;
    NSError *err = nil;
    NSMutableURLRequest *jsonDataRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *jsonObject = [NSURLConnection sendSynchronousRequest: jsonDataRequest returningResponse: &resp error: &err];

    //get server time
    NSDictionary *allHeaderFields = [resp allHeaderFields];
    NSString *dateInStringFormat = [allHeaderFields objectForKey:@"Date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc ]init];
    [dateFormatter setDateFormat:@"EE, d LLLL yyyy HH:mm:ss zzz"];
    NSDate *date = [dateFormatter dateFromString:dateInStringFormat];
    
    //set server time into lastDBUpdate
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:date forKey:@"lastDBUpdate"];
    
    //return deserialized json data
    
    NSDictionary *dictionaryDeserializedFromJsonFormat;
    if (jsonObject) {
         dictionaryDeserializedFromJsonFormat = [NSJSONSerialization JSONObjectWithData: jsonObject options: NSJSONReadingMutableContainers error: &err];
    }
    if (!dictionaryDeserializedFromJsonFormat) {
       // NSLog(@"Error parsing JSON: %@", err);
    }
    return dictionaryDeserializedFromJsonFormat;
    
}

//check values for null's and pass them for parsing
- (void)parseDictionary:(NSDictionary *)dic toObject:(id)obj {

    for (NSString *key in dic.allKeys) {
        id value = [dic valueForKey:key];
        if (value == [NSNull null]) {
            continue;
        }
        [obj parseAttribute:value forKey:key];
    }
}

- (void)insertObject2:(NSString *)param {
    
    //get NSDictionary of objects
    NSString *url = [NSString stringWithFormat:@"https://softserve.ua/api/v1/object/list/b1d6f099e1b5913e86f0a9bb9fbc10e5%@",param];
    NSDictionary *jsonDictionary = [self getJsonDictionaryFromURL:url];
    
    //get existing id`s into array
    NSArray *existingObjectIdsInArray = [self getExistingIdsForEntity:@"DiscountObject"];
    
    //parse Json dictionary
    NSArray *objects = [jsonDictionary objectForKey:@"list"];
    NSLog(@"objects recieved for import: %d", objects.count);
    for (NSMutableDictionary *object in objects) {
        
        //check if incoming object exists in Model (by id). If YES replace existing object with incoming(updated) and goto next object
        NSNumber *incomingObjectId = [object objectForKey:@"id"];
        if ([existingObjectIdsInArray containsObject:incomingObjectId]) {
            NSManagedObject *objectForReplacement = [self getManagedObjectFromEntity:@"DiscountObject" withId:incomingObjectId];
            [self parseDictionary:object toObject:objectForReplacement];
            continue;
        }
        
        //create object entity
        DiscountObject *discountObject = [NSEntityDescription insertNewObjectForEntityForName:@"DiscountObject"
                                                                       inManagedObjectContext:managedObjectContext];
        [self parseDictionary:object toObject:discountObject];
    }
    
    //save context into model
    NSError *err;
    if (![managedObjectContext save:&err]) {
        NSLog(@"Couldn't save: %@", [err localizedDescription]);
    }
    NSLog(@"Objects in base after import: %d", [self numberOfObjectsIn:@"DiscountObject"]);
}


- (void)insertCities:(NSString *)param {

    //get NSDictionary of cities
    NSString *url = [NSString stringWithFormat:@"https://softserve.ua/api/v1/city/list/b1d6f099e1b5913e86f0a9bb9fbc10e5%@",param];
    NSDictionary *jsonDictionary = [self getJsonDictionaryFromURL: url];
    
    //get existing cities id's
     NSArray *existingObjectIdsInArray = [self getExistingIdsForEntity:@"City"];
    
    //get the list of cities
    NSDictionary *dictionaryOfObjects = [jsonDictionary objectForKey:@"list"];
    NSLog(@"Cities recieved for import: %d", dictionaryOfObjects.count);
    
    //parse cities into model context
    for (NSString *objectContainer in dictionaryOfObjects) {
        NSDictionary *json_city = [dictionaryOfObjects objectForKey:objectContainer];
        NSNumber *incomingCityId = [json_city objectForKey:@"id"];
        City *city;
        if ([existingObjectIdsInArray containsObject:incomingCityId]) {
            city = (City *)[self getManagedObjectFromEntity:@"City" withId:incomingCityId];
        }
        else {
            city = [NSEntityDescription insertNewObjectForEntityForName:@"City"
                                                 inManagedObjectContext:managedObjectContext];
        }
        
        city.id = [json_city valueForKey:@"id"];
        city.name = [json_city valueForKey:@"name"];
    }
    
    //save context into model
    NSError* err;
    if (![managedObjectContext save:&err]) {
        NSLog(@"Couldn't save: %@", [err localizedDescription]);
    }
    NSLog(@"Cities in base after import: %d", [self numberOfObjectsIn:@"City"]);//debug
}

- (void)updateCategories:(NSString *) param {
    
    //get NSDictionary of categories
    NSString *url = [NSString stringWithFormat:@"https://softserve.ua/api/v1/category/list/b1d6f099e1b5913e86f0a9bb9fbc10e5%@",param];
    NSDictionary *jsonDictionary = [self getJsonDictionaryFromURL: url];
    NSDictionary *dictionaryOfObjects = [jsonDictionary objectForKey:@"list"];
    NSLog(@"Categories recieved for import: %d", dictionaryOfObjects.count);
    
    //get existing cities id's
    NSArray *existingObjectIdsInArray = [self getExistingIdsForEntity:@"City"];
    
    //parse categories into model context
    for (NSString *objectContainer in dictionaryOfObjects) {
        NSDictionary *categoryDic = [dictionaryOfObjects objectForKey:objectContainer];
        NSNumber *incomingCategoryId = [categoryDic objectForKey:@"id"];
        Category *category;
        if ([existingObjectIdsInArray containsObject:incomingCategoryId]) {
            category = (Category *)[self getManagedObjectFromEntity:@"Category" withId:incomingCategoryId];
        }
        else{
            category = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                                               inManagedObjectContext:managedObjectContext];
        }
        category.created = [categoryDic valueForKey:@"created"];
        category.id = [categoryDic valueForKey:@"id"];
        category.name = [categoryDic valueForKey:@"name"];
        category.updated = [categoryDic valueForKey:@"updated"];
        category.fontSymbol = [categoryDic valueForKey:@"fontSymbol"];
    }
    
    //save context into model
    NSError* err;
    if (![managedObjectContext save:&err]) {
        NSLog(@"Couldn't save: %@", [err localizedDescription]);
    }
    NSLog(@"Categories in base after import: %d", [self numberOfObjectsIn:@"Category"]);//debug
    
}

-(NSManagedObject *)getManagedObjectFromEntity:(NSString *)TheEntity withId: (NSNumber *)objID {
    NSPredicate *findObjectWithId = [NSPredicate predicateWithFormat:@"id == %@",objID];
    NSFetchRequest *objFetch=[[NSFetchRequest alloc] init];
    [objFetch setEntity:[NSEntityDescription entityForName:TheEntity
                                    inManagedObjectContext:self.managedObjectContext]];
    [objFetch setPredicate:findObjectWithId];
    NSArray *objectForReplacement = [self.managedObjectContext executeFetchRequest:objFetch error:nil];
    return [objectForReplacement objectAtIndex:0];
}

- (NSArray *)getExistingIdsForEntity:(NSString *) theEntity {
    NSMutableArray *existingIds = [[NSMutableArray alloc] init];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:theEntity
                                 inManagedObjectContext:self.managedObjectContext]];
    [fetch setResultType:NSDictionaryResultType];
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:@"id", nil]];
    NSArray *existingObjectsIds = [self.managedObjectContext executeFetchRequest:fetch error:nil];//get array of dictionaries
    for (NSDictionary *idDictionary in existingObjectsIds) {
        [existingIds addObject:[idDictionary objectForKey:@"id"]];
    }
    return existingIds;
    
}

- (int) numberOfObjectsIn:(NSString *) theEntity{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:theEntity
                                              inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    if (!error){
        return count;
    }
    else
        return -1;
    
}
- (void)testDB {
    
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"City"
                                 inManagedObjectContext:managedObjectContext]];
    NSArray *objectsFound = [managedObjectContext executeFetchRequest:fetch error:nil];
    for (City *cat in objectsFound){
//        for (DiscountObject *object in cat.discountobject) {
//            if ([object.id isEqualToNumber: [NSNumber numberWithInt:476]]){
//                NSLog(@"%@ - %@ %@", object.id, object.name, object.cities.name);
//                NSLog(@"---------------------------");
//            }
//        }
//        return;
        NSLog(@"name: %@ id: %@", cat.name, cat.id);
    }
}

@end
