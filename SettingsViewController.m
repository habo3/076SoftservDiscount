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

- (void)parseDictionary:(NSDictionary *)dic toObject:(NSObject *)obj {
    for (NSString *key in dic.allKeys) {
        id value = [dic valueForKey:key];
        if (value == [NSNull null]) {
            value = nil;
        }
        
        NSLog(@"value: %@", value);
        NSString *attrName = [@"json_" stringByAppendingString:key];
        NSLog(@"attrName: %@", attrName);
        
        
        //check if backend failed with icon entity
        if ([value isKindOfClass:[NSArray class]]) {
            if ([key isEqualToString:@"icon"]) {continue;}
        }
        
        //do subentities
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSManagedObject *relatedObject = [NSEntityDescription insertNewObjectForEntityForName:[key capitalizedString]
                                                                           	inManagedObjectContext:managedObjectContext];
            [self parseDictionary:value toObject:relatedObject];
        } else {
        
            [obj setValue:value forKey:attrName];
        }
    }
}

//Debug. Testing DB
- (IBAction)showCities {
    //NSNumber *cityId = [object valueForKey:@"city"];
    NSPredicate *objectsFind = [NSPredicate predicateWithFormat:@"id == 14"];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Category"
                                 inManagedObjectContext:managedObjectContext]];
    [fetch setPredicate:objectsFind];
    NSArray *objectsFound = [managedObjectContext executeFetchRequest:fetch error:nil];
    for (Category *cat in objectsFound){
        NSString *name = cat.name;
        NSSet *objects = cat.discountobject;
        for (DiscountObject *object in objects){
            NSLog(@"category :%@, object: %@", name, object.name);//debug            |
        }
    }
}

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
    NSLog(@"categories found: %@", tmp.name);//debug
    
    //          discountObject.cities = [cityIdFound objectAtIndex:0];

//
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DiscountObject"
//                                              inManagedObjectContext:managedObjectContext];
//    [request setEntity:entity];
//    
//    NSError *error = nil;
//    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
//    
//    NSLog(@"There are %d objects of DiscountObject entity.", count);
//    
//    	
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

- (IBAction)insertCities {
    
    //auth
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSString *authStr = [NSString stringWithFormat:@"Basic cm9vdDpAOGNocngh"];
    NSString *url= @"http://ssdp.qubstudio.com/api/v1/city/list/b1d6f099e1b5913e86f0a9bb9fbc10e5";
    
    //getJsonDictionary
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:authStr forHTTPHeaderField:@"Authorization"];
    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: response options: NSJSONReadingMutableContainers error: &err];
    
    
    if (!jsonDictionary) {
        NSLog(@"Error parsing JSON: %@", err);
    }
    else {
        //get the list of objects
        NSDictionary *dictionaryOfObjects = [jsonDictionary objectForKey:@"list"];
        for (NSString *objectContainer in dictionaryOfObjects) {
            
            //create core data City entity
            City *city = [NSEntityDescription insertNewObjectForEntityForName:@"City"
                                                               inManagedObjectContext:managedObjectContext];
            
            //put object into core data
            NSDictionary *json_city = [dictionaryOfObjects objectForKey:objectContainer];
            
            city.id = [json_city valueForKey:@"id"];
            city.name = [json_city valueForKey:@"name"];
            
            
            //[self parseDictionary:json_city toObject:city];
        }
    }
    
     NSLog(@"Objects in base: %d", [self numberOfObjectsIn:@"City"]); //debug
    
    if (![managedObjectContext save:&err]) {
        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
    }
[self numberOfObjectsIn:@"City"]; //debug

}
- (IBAction)updateCategories {
    
    //NSManagedObjectContext *context = [self managedObjectContext];
    
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSString *authStr = [NSString stringWithFormat:@"Basic cm9vdDpAOGNocngh"];
    NSString *url= @"http://ssdp.qubstudio.com/api/v1/category/list/b1d6f099e1b5913e86f0a9bb9fbc10e5/";
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:authStr forHTTPHeaderField:@"Authorization"];
    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: response options: NSJSONReadingMutableContainers error: &err];
    
    if (!jsonDictionary) {
        NSLog(@"Error parsing JSON: %@", err);
    }
    else {
        NSDictionary *dictionaryOfObjects = [jsonDictionary objectForKey:@"list"];

        for (NSString *objectContainer in dictionaryOfObjects) {
            
            NSString *attributeClass = NSStringFromClass([objectContainer class]); //debug
            NSLog(@"      %@, class: %@", objectContainer, attributeClass);        //debug
            
            NSDictionary *theObject = [dictionaryOfObjects objectForKey:objectContainer];
            
            //create core data Category entity
            Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                                               inManagedObjectContext:managedObjectContext];
            
            //set entity's attributes:
            category.created = [theObject valueForKey:@"created"];
            category.id = [theObject valueForKey:@"id"];
            category.name = [theObject valueForKey:@"name"];
            category.updated = [theObject valueForKey:@"updated"];
            category.fontSymbol = [theObject valueForKey:@"fontSymbol"];
            //[self parseDictionary:theObject toObject:category];
            
        }
    }
    NSLog(@"Objects in base: %d", [self numberOfObjectsIn:@"Category"]);
    if (![managedObjectContext save:&err]) {
        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
    }
    
}

- (IBAction)insertObjects {
    
    //auth
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSString *authStr = [NSString stringWithFormat:@"Basic cm9vdDpAOGNocngh"];
    NSString *url= @"http://ssdp.qubstudio.com/api/v1/object/list/b1d6f099e1b5913e86f0a9bb9fbc10e5";
    
    //getJsonDictionary
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:authStr forHTTPHeaderField:@"Authorization"];
    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: response options: NSJSONReadingMutableContainers error: &err];
    
    //parse Json dictionary
    if (!jsonDictionary) {
        NSLog(@"Error parsing JSON: %@", err);
    }
    else {
        //get the list of objects
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
            discountObject.allPlaces = [object valueForKey:@"allPlaces"];
            discountObject.allProducts = [object valueForKey:@"allProducts"];
            discountObject.created = [object valueForKey:@"created"];
            discountObject.objectDescription = [object valueForKey:@"description"]; 
            discountObject.id = [object valueForKey:@"id"];
            discountObject.name = [object valueForKey:@"name"];
            discountObject.parent = [object valueForKey:@"parent"];
            discountObject.pulse = [object valueForKey:@"pulse"];
            discountObject.responsiblePersonInfo = [object valueForKey:@"responsiblePersonInfo"];
            discountObject.updated = [object valueForKey:@"updated"];
            NSDictionary *geoPoint = [object valueForKey:@"geoPoint"];
            discountObject.geoLongitude = [geoPoint valueForKey:@"longitude"];
            NSLog(@"longtitude = %@", discountObject.geoLongitude);
            discountObject.geoLatitude = [geoPoint valueForKey:@"latitude"];
            if ([[object valueForKey:@"logo"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *objectLogo  = [object valueForKey:@"logo"];
                discountObject.logoId = [objectLogo valueForKey:@"id"];
                discountObject.logoMime = [objectLogo valueForKey:@"mime"];
                discountObject.logoSrc = [objectLogo valueForKey:@"src"];
            }
            NSDictionary *objectDiscountValues = [object valueForKey:@"discount"];
            if (!([objectDiscountValues valueForKey:@"from"] == [NSNull null])) { //nsnull ignore
                discountObject.discountFrom = [objectDiscountValues valueForKey:@"from"];            }
            if (!([objectDiscountValues valueForKey:@"to"] == [NSNull null])) {
                discountObject.discountTo = [objectDiscountValues valueForKey:@"to"];
            }
                //Create, populate and related Contact entities.
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
    }
    
    NSLog(@"Objects in base: %d", [self numberOfObjectsIn:@"DiscountObject"]);
    
    if (![managedObjectContext save:&err]) {
        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
    }
    [self numberOfObjectsIn:@"DiscountObject"];
    
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

@end
