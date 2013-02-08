// merge test
//  SettingsViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 28.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "SettingsViewController.h"
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
                        @"description",
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
    } else if ([key isEqualToString:@"site"]) {
        
    } else if ([key isEqualToString:@"email"]) {
        
    } else if ([key isEqualToString:@"category"]) {
        
    } else if ([key isEqualToString:@"city"]) {
        if ([attr isKindOfClass:[NSNumber class]]) {
            [self parseCity:attr];
        }
    } else if ([key isEqualToString:@"description"]) {
        // NSObject already contains description property
        [self setValue:attr forKey:@"objectDescription"];
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

@interface SettingsViewController ()
@end

@implementation SettingsViewController

@synthesize managedObjectContext;

- (NSDictionary *)getJsonDictionaryFromURL: (NSString *)url{
    //auth
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSString *authStr = [NSString stringWithFormat:@"Basic cm9vdDpAOGNocngh"];
    
    //make request from inputted URL
    NSMutableURLRequest *jsonDataRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [jsonDataRequest setHTTPMethod:@"POST"];
    [jsonDataRequest setValue:authStr forHTTPHeaderField:@"Authorization"];
    
    //deserialize json to NSDictionary and return
    NSData *jsonObject = [NSURLConnection sendSynchronousRequest: jsonDataRequest returningResponse: &resp error: &err];
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

- (void)insertObject2 {
    //get NSDictionary of objects
    NSDictionary *jsonDictionary = [self getJsonDictionaryFromURL: @"http://ssdp.qubstudio.com/api/v1/object/list/b1d6f099e1b5913e86f0a9bb9fbc10e5/"];
    
    //parse Json dictionary
    NSArray *objects = [jsonDictionary objectForKey:@"list"];
    NSLog(@"objects in json dictionary: %d", objects.count);
    for (NSMutableDictionary *object in objects) {
        //create object entity
        DiscountObject *discountObject = [NSEntityDescription insertNewObjectForEntityForName:@"DiscountObject"
                                                                       inManagedObjectContext:managedObjectContext];
        [self parseDictionary:object toObject:discountObject];
    }
    
    NSError *err;
    if (![managedObjectContext save:&err]) {
        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
    }
    NSLog(@"Objects in base: %d", [self numberOfObjectsIn:@"DiscountObject"]);
}

- (void)insertObjects {
    
    //get NSDictionary of objects
    NSDictionary *jsonDictionary = [self getJsonDictionaryFromURL: @"http://ssdp.qubstudio.com/api/v1/object/list/b1d6f099e1b5913e86f0a9bb9fbc10e5/"];
    
    //parse Json dictionary
    NSArray *objects = [jsonDictionary objectForKey:@"list"];
    NSLog(@"objects in json dictionary: %d", objects.count);
    for (NSMutableDictionary *object in objects) {
        
        //Remove nulls
        NSSet *nullSet = [object keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id key, id obj, BOOL *stop) {
            return [obj isEqual:[NSNull null]] ? YES : NO;
        }];
        [object removeObjectsForKeys:[nullSet allObjects]];
        
        //create object entity
        DiscountObject *discountObject = [NSEntityDescription insertNewObjectForEntityForName:@"DiscountObject"
                                                                       inManagedObjectContext:managedObjectContext];
        //populate entity with properties
        discountObject.address = [object valueForKey:@"address"];
        discountObject.created = [object valueForKey:@"created"];
        discountObject.id = [object valueForKey:@"id"];
        discountObject.name = [object valueForKey:@"name"];
        discountObject.updated = [object valueForKey:@"updated"];
        NSDictionary *geoPoint = [object valueForKey:@"geoPoint"];
        discountObject.geoLongitude = [geoPoint valueForKey:@"longitude"];
        discountObject.geoLatitude = [geoPoint valueForKey:@"latitude"];
        NSDictionary *objectDiscountValues = [object valueForKey:@"discount"];
        if (!([objectDiscountValues valueForKey:@"from"] == [NSNull null])) { //nsnull ignore
            discountObject.discountFrom = [objectDiscountValues valueForKey:@"from"];
        }
        if (!([objectDiscountValues valueForKey:@"to"] == [NSNull null])) {
            discountObject.discountTo = [objectDiscountValues valueForKey:@"to"];
        }
        
        //Create, populate and relate with Contact objects.
        NSArray *phoneNumbers = [object valueForKey:@"phone"];
        for (NSString *phoneNumber in phoneNumbers) {
            Contacts *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                              inManagedObjectContext:managedObjectContext];
            contact.type = @"phone";
            contact.value = phoneNumber;
            //set relation
            [discountObject addContactsObject:contact];
            contact.discountObject = discountObject;
        }
        NSArray *emails = [object valueForKey:@"email"];
        for (NSString *email in emails) {
            Contacts *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                              inManagedObjectContext:managedObjectContext];
            contact.type = @"email";
            contact.value = email;
            //set relation
            [discountObject addContactsObject:contact];
            contact.discountObject = discountObject;
        }
        NSArray *sites = [object valueForKey:@"site"];
        for (NSString *site in sites) {
            Contacts *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                              inManagedObjectContext:managedObjectContext];
            contact.type = @"site";
            contact.value = site;
            //set relation
            [discountObject addContactsObject:contact];
            contact.discountObject = discountObject;
        }
        
        //relationship to city
        NSNumber *cityId = [object valueForKey:@"city"];
        NSPredicate *cityFind = [NSPredicate predicateWithFormat:@"id = %@",cityId];
        NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:@"City"
                                     inManagedObjectContext:managedObjectContext]];
        [fetch setPredicate:cityFind];
        NSArray *cityIdFound = [managedObjectContext executeFetchRequest:fetch error:nil];
        //NSLog(@"count of found cities: %d", cityIdFound.count);
        //NSLog(@"city id found and linked: %@", [cityIdFound objectAtIndex:0]);//debug
        discountObject.cities = [cityIdFound objectAtIndex:0];
        
        //relationships to categories
        
        NSArray *categoryIds = [object valueForKey:@"category"];
        NSPredicate *catFind = [NSPredicate predicateWithFormat:@"id IN %@",categoryIds];
        NSFetchRequest *objFetch=[[NSFetchRequest alloc] init];
        [objFetch setEntity:[NSEntityDescription entityForName:@"Category"
                                        inManagedObjectContext:managedObjectContext]];
        [objFetch setPredicate:catFind];
        NSArray *catFound = [managedObjectContext executeFetchRequest:objFetch error:nil];
        //NSLog(@"categories found: %@", catFound);//debug
        [discountObject addCategories: [NSSet setWithArray:catFound]];
    }
    
    NSError *err;
    if (![managedObjectContext save:&err]) {
        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
    }
    NSLog(@"Objects in base: %d", [self numberOfObjectsIn:@"DiscountObject"]);
}

- (void)insertCities {
    
    //get NSDictionary of cities
    NSDictionary *jsonDictionary = [self getJsonDictionaryFromURL: @"http://ssdp.qubstudio.com/api/v1/city/list/b1d6f099e1b5913e86f0a9bb9fbc10e5"];
    //get the list of cities
    NSDictionary *dictionaryOfObjects = [jsonDictionary objectForKey:@"list"];
    
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
        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
    }
    NSLog(@"Objects in base: %d", [self numberOfObjectsIn:@"City"]);//debug
}

- (void)updateCategories {
    
    //get NSDictionary of categories
    NSDictionary *jsonDictionary = [self getJsonDictionaryFromURL: @"http://ssdp.qubstudio.com/api/v1/category/list/b1d6f099e1b5913e86f0a9bb9fbc10e5/"];
    NSDictionary *dictionaryOfObjects = [jsonDictionary objectForKey:@"list"];
    
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
        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
    }
    NSLog(@"Objects in base: %d", [self numberOfObjectsIn:@"Category"]);//debug

}


- (IBAction)updateDB {
    
    [self insertCities];
    [self updateCategories ];
//    [self insertObjects];
    [self insertObject2];
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Debug. Testing DB
- (IBAction)showCities {

    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
                                 inManagedObjectContext:managedObjectContext]];
    NSArray *objectsFound = [managedObjectContext executeFetchRequest:fetch error:nil];
    for (DiscountObject *obj in objectsFound){
        for (Contacts *contact in obj.contacts) {
            NSLog(@"%@ %@ %@ : %@ ", obj.name, obj.created,  contact.type, contact.value);
            NSLog(@"---------------------------");
        }
    }
}

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
