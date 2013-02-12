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
//#import <objc/runtime.h>

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
                        //@"description",
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
//    else if ([key isEqualToString:@"description"]) {
//        // NSObject already contains description property
//        [self setValue:attr forKey:@"objectDescription"];
//    }
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
        //set relation
        [self addContactsObject:contact];
        contact.discountObject = self;
    }
}

- (void)parseCategory:(NSArray *)catArray{
    //NSArray *categoryIds = [object valueForKey:@"category"];
    NSPredicate *catFind = [NSPredicate predicateWithFormat:@"id IN %@",catArray];
    NSFetchRequest *objFetch=[[NSFetchRequest alloc] init];
    [objFetch setEntity:[NSEntityDescription entityForName:@"Category"
                                    inManagedObjectContext:self.managedObjectContext]];
    [objFetch setPredicate:catFind];
    NSArray *catFound = [self.managedObjectContext executeFetchRequest:objFetch error:nil];
    //NSLog(@"categories found: %@", catFound);//debug
    [self addCategories: [NSSet setWithArray:catFound]];
}

- (void)parseCity:(NSNumber *)cityId
{
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

- (void)updateDB {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdate = [userDefaults objectForKey:@"lastDBUpdate"];
    int lastUpdateInt =[lastUpdate timeIntervalSince1970];
    NSString *parameterString = [NSString stringWithFormat:@"?changed=%d", lastUpdateInt];
    [self insertCities:parameterString];
    [self updateCategories:parameterString];
    [self insertObject2:parameterString];
//    NSDate *date = [[NSDate alloc]init];
//    [userDefaults setObject:date forKey:@"lastDBUpdate"];
}

- (NSDictionary *)getJsonDictionaryFromURL: (NSString *)url{
    //auth
    NSHTTPURLResponse *resp = nil;
    NSError *err = nil;
//    NSString *authStr = [NSString stringWithFormat:@"Basic cm9vdDpAOGNocngh"];
    
    //make request from inputted URL
    NSMutableURLRequest *jsonDataRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//    [jsonDataRequest setHTTPMethod:@"POST"];
//    [jsonDataRequest setValue:authStr forHTTPHeaderField:@"Authorization"];
    
    //deserialize json to NSDictionary and return
    
    NSData *jsonObject = [NSURLConnection sendSynchronousRequest: jsonDataRequest returningResponse: &resp error: &err];
    NSDictionary *allHeaderFields = [resp allHeaderFields];
    NSString *dateInStringFormat = [allHeaderFields objectForKey:@"Date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc ]init];
    [dateFormatter setDateFormat:@"EE, d LLLL yyyy HH:mm:ss zzz"];
    NSDate *date = [dateFormatter dateFromString:dateInStringFormat];
    //int dateInInt = [date timeIntervalSince1970];
    //NSLog(@"date in int: %d", dateInInt);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:date forKey:@"lastDBUpdate"];
//    const char* className = class_getName([date class]);
//    NSLog(@"yourObject is a: %s", className);
    
    NSDictionary *dictionaryDeserializedFromJsonFormat = [NSJSONSerialization JSONObjectWithData: jsonObject options: NSJSONReadingMutableContainers error: &err];
    if (!dictionaryDeserializedFromJsonFormat) {
        NSLog(@"Error parsing JSON: %@", err);
    }
    return dictionaryDeserializedFromJsonFormat;
    
}

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
    
    //parse Json dictionary
    NSArray *objects = [jsonDictionary objectForKey:@"list"];
    NSLog(@"objects recieved for import: %d", objects.count);
    for (NSMutableDictionary *object in objects) {
        //create object entity
        DiscountObject *discountObject = [NSEntityDescription insertNewObjectForEntityForName:@"DiscountObject"
                                                                       inManagedObjectContext:managedObjectContext];
        [self parseDictionary:object toObject:discountObject];
    }
    
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
    //get the list of cities
    NSDictionary *dictionaryOfObjects = [jsonDictionary objectForKey:@"list"];
    NSLog(@"Cities recieved for import: %d", dictionaryOfObjects.count);
    //parse cities into model context
    for (NSString *objectContainer in dictionaryOfObjects) {
        City *city = [NSEntityDescription insertNewObjectForEntityForName:@"City"
                                                   inManagedObjectContext:managedObjectContext];
        NSDictionary *json_city = [dictionaryOfObjects objectForKey:objectContainer];
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
    //parse categories into model context
    for (NSString *objectContainer in dictionaryOfObjects) {
        NSDictionary *categoryDic = [dictionaryOfObjects objectForKey:objectContainer];
        Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                                           inManagedObjectContext:managedObjectContext];
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
- (int) numberOfObjectsIn:(NSString *) thentity{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:thentity
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
    [fetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
                                 inManagedObjectContext:managedObjectContext]];
    NSArray *objectsFound = [managedObjectContext executeFetchRequest:fetch error:nil];
    for (DiscountObject *obj in objectsFound){
        for (Contacts *contact in obj.contacts) {
            NSLog(@"%@ %@ %@ : %@ ", obj.name, obj.discountTo,  contact.type, contact.value);
            NSLog(@"---------------------------");
        }
    }
}
//- (void)insertObjects {
//
//    //get NSDictionary of objects
//    NSDictionary *jsonDictionary = [self getJsonDictionaryFromURL: @"http://ssdp.qubstudio.com/api/v1/object/list/b1d6f099e1b5913e86f0a9bb9fbc10e5/"];
//
//    //parse Json dictionary
//    NSArray *objects = [jsonDictionary objectForKey:@"list"];
//    NSLog(@"objects in json dictionary: %d", objects.count);
//    for (NSMutableDictionary *object in objects) {
//
//        //Remove nulls
//        NSSet *nullSet = [object keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id key, id obj, BOOL *stop) {
//            return [obj isEqual:[NSNull null]] ? YES : NO;
//        }];
//        [object removeObjectsForKeys:[nullSet allObjects]];
//
//        //create object entity
//        DiscountObject *discountObject = [NSEntityDescription insertNewObjectForEntityForName:@"DiscountObject"
//                                                                       inManagedObjectContext:managedObjectContext];
//        //populate entity with properties
//        discountObject.address = [object valueForKey:@"address"];
//        discountObject.created = [object valueForKey:@"created"];
//        discountObject.id = [object valueForKey:@"id"];
//        discountObject.name = [object valueForKey:@"name"];
//        discountObject.updated = [object valueForKey:@"updated"];
//        NSDictionary *geoPoint = [object valueForKey:@"geoPoint"];
//        discountObject.geoLongitude = [geoPoint valueForKey:@"longitude"];
//        discountObject.geoLatitude = [geoPoint valueForKey:@"latitude"];
//        NSDictionary *objectDiscountValues = [object valueForKey:@"discount"];
//        if (!([objectDiscountValues valueForKey:@"from"] == [NSNull null])) { //nsnull ignore
//            discountObject.discountFrom = [objectDiscountValues valueForKey:@"from"];
//        }
//        if (!([objectDiscountValues valueForKey:@"to"] == [NSNull null])) {
//            discountObject.discountTo = [objectDiscountValues valueForKey:@"to"];
//        }
//
//        //Create, populate and relate with Contact objects.
//        NSArray *phoneNumbers = [object valueForKey:@"phone"];
//        for (NSString *phoneNumber in phoneNumbers) {
//            Contacts *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
//                                                              inManagedObjectContext:managedObjectContext];
//            contact.type = @"phone";
//            contact.value = phoneNumber;
//            //set relation
//            [discountObject addContactsObject:contact];
//            contact.discountObject = discountObject;
//        }
//        NSArray *emails = [object valueForKey:@"email"];
//        for (NSString *email in emails) {
//            Contacts *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
//                                                              inManagedObjectContext:managedObjectContext];
//            contact.type = @"email";
//            contact.value = email;
//            //set relation
//            [discountObject addContactsObject:contact];
//            contact.discountObject = discountObject;
//        }
//        NSArray *sites = [object valueForKey:@"site"];
//        for (NSString *site in sites) {
//            Contacts *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
//                                                              inManagedObjectContext:managedObjectContext];
//            contact.type = @"site";
//            contact.value = site;
//            //set relation
//            [discountObject addContactsObject:contact];
//            contact.discountObject = discountObject;
//        }
//
//        //relationship to city
//        NSNumber *cityId = [object valueForKey:@"city"];
//        NSPredicate *cityFind = [NSPredicate predicateWithFormat:@"id = %@",cityId];
//        NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
//        [fetch setEntity:[NSEntityDescription entityForName:@"City"
//                                     inManagedObjectContext:managedObjectContext]];
//        [fetch setPredicate:cityFind];
//        NSArray *cityIdFound = [managedObjectContext executeFetchRequest:fetch error:nil];
//        //NSLog(@"count of found cities: %d", cityIdFound.count);
//        //NSLog(@"city id found and linked: %@", [cityIdFound objectAtIndex:0]);//debug
//        discountObject.cities = [cityIdFound objectAtIndex:0];
//
//        //relationships to categories
//
//        NSArray *categoryIds = [object valueForKey:@"category"];
//        NSPredicate *catFind = [NSPredicate predicateWithFormat:@"id IN %@",categoryIds];
//        NSFetchRequest *objFetch=[[NSFetchRequest alloc] init];
//        [objFetch setEntity:[NSEntityDescription entityForName:@"Category"
//                                        inManagedObjectContext:managedObjectContext]];
//        [objFetch setPredicate:catFind];
//        NSArray *catFound = [managedObjectContext executeFetchRequest:objFetch error:nil];
//        //NSLog(@"categories found: %@", catFound);//debug
//        [discountObject addCategories: [NSSet setWithArray:catFound]];
//    }
//
//    NSError *err;
//    if (![managedObjectContext save:&err]) {
//        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
//    }
//    NSLog(@"Objects in base: %d", [self numberOfObjectsIn:@"DiscountObject"]);
//}

//debug
//- (IBAction)showMeTheMoney {
//
//    NSNumber *num1 = [NSNumber numberWithInt:14];
//    NSNumber *num2 = [NSNumber numberWithInt:17];
//    NSArray *categoryIds = [NSArray arrayWithObjects: num1, num2, nil];
//    NSPredicate *catFind = [NSPredicate predicateWithFormat:@"id IN %@",categoryIds];
//    NSFetchRequest *objFetch=[[NSFetchRequest alloc] init];
//    [objFetch setEntity:[NSEntityDescription entityForName:@"Category"
//                                    inManagedObjectContext:managedObjectContext]];
//    [objFetch setPredicate:catFind];
//    NSArray *catFound = [managedObjectContext executeFetchRequest:objFetch error:nil];
//    Category *tmp = [catFound objectAtIndex:1];
//    NSLog(@"categories found: %@", tmp.name);
//
//}

//- (void)parseDictionary:(NSDictionary *)dic toObject:(NSObject *)obj {
//    for (NSString *key in dic.allKeys) {
//        id value = [dic valueForKey:key];
//        if (value == [NSNull null]) {
//            value = nil;
//        }
//
//        NSLog(@"value: %@", value);
//        NSString *attrName = [@"json_" stringByAppendingString:key];
//        NSLog(@"attrName: %@", attrName);
//
//
//        //check if backend failed with icon entity
//        if ([value isKindOfClass:[NSArray class]]) {
//            if ([key isEqualToString:@"icon"]) {continue;}
//        }
//
//        //do subentities
//        if ([value isKindOfClass:[NSDictionary class]]) {
//            NSManagedObject *relatedObject = [NSEntityDescription insertNewObjectForEntityForName:[key capitalizedString]
//                                                                           inManagedObjectContext:managedObjectContext];
//            [self parseDictionary:value toObject:relatedObject];
//        } else {
//
//            [obj setValue:value forKey:attrName];
//        }
//    }
//}


@end
