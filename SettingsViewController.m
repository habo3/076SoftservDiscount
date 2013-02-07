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

- (IBAction)insertCities {
    
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

- (IBAction)updateCategories {
    
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

- (IBAction)insertObjects {
    
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
        NSLog(@"count of found cities: %d", cityIdFound.count);
        NSLog(@"city id found and linked: %@", [cityIdFound objectAtIndex:0]);//debug
        discountObject.cities = [cityIdFound objectAtIndex:0];
        
        //relationships to categories
        
        NSArray *categoryIds = [object valueForKey:@"category"];
        NSPredicate *catFind = [NSPredicate predicateWithFormat:@"id IN %@",categoryIds];
        NSFetchRequest *objFetch=[[NSFetchRequest alloc] init];
        [objFetch setEntity:[NSEntityDescription entityForName:@"Category"
                                        inManagedObjectContext:managedObjectContext]];
        [objFetch setPredicate:catFind];
        NSArray *catFound = [managedObjectContext executeFetchRequest:objFetch error:nil];
        NSLog(@"categories found: %@", catFound);//debug
        [discountObject addCategories: [NSSet setWithArray:catFound]];
    }
    
    NSError *err;
    if (![managedObjectContext save:&err]) {
        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
    }
    NSLog(@"Objects in base: %d", [self numberOfObjectsIn:@"DiscountObject"]);
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
    //NSNumber *cityId = [object valueForKey:@"city"];
    //NSPredicate *objectsFind = [NSPredicate predicateWithFormat:@"id == 14"];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Category"
                                 inManagedObjectContext:managedObjectContext]];
    //[fetch setPredicate:objectsFind];
    NSArray *objectsFound = [managedObjectContext executeFetchRequest:fetch error:nil];
    for (Category *cat in objectsFound){
        NSString *name = cat.name;
        NSSet *objects = cat.discountobject;
        for (DiscountObject *object in objects){
            NSLog(@"category :%@, object: %@", name, object.name);//debug            |
        }
    }
}

//debug
- (IBAction)showMeTheMoney {
    
    NSNumber *num1 = [NSNumber numberWithInt:14];
    NSNumber *num2 = [NSNumber numberWithInt:17];
    NSArray *categoryIds = [NSArray arrayWithObjects: num1, num2, nil];
    NSPredicate *catFind = [NSPredicate predicateWithFormat:@"id IN %@",categoryIds];
    NSFetchRequest *objFetch=[[NSFetchRequest alloc] init];
    [objFetch setEntity:[NSEntityDescription entityForName:@"Category"
                                    inManagedObjectContext:managedObjectContext]];
    [objFetch setPredicate:catFind];
    NSArray *catFound = [managedObjectContext executeFetchRequest:objFetch error:nil];
    Category *tmp = [catFound objectAtIndex:1];
    NSLog(@"categories found: %@", tmp.name);

}

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
