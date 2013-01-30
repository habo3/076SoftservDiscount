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

-(void) showAllEntities:(NSString *) entityName {
    NSLog(@"---------------------");
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:request error:&error];
    for (NSManagedObject *attribute in fetchedObjects) {
        static int i = 1;
        NSLog(@"%d",i);
        i++;
        NSLog(@"attribute: %@", [attribute valueForKey:@"json_name"]);
    }
    
    	
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
        for (NSString *anOject in dictionaryOfObjects) {
            
            //create core data City entity
            Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"City"
                                                               inManagedObjectContext:managedObjectContext];
            
            //put object into core data
            NSDictionary *theObject = [dictionaryOfObjects objectForKey:anOject];
            [self parseDictionary:theObject toObject:category];
            
        }
    }
    
     NSLog(@"Objects in base: %d", [self numberOfObjectsIn:@"City"]);
    
    if (![managedObjectContext save:&err]) {
        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
    }
[self numberOfObjectsIn:@"City"];

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
        for (NSString *anOject in dictionaryOfObjects) {
            
            NSString *attributeClass = NSStringFromClass([anOject class]);
            NSLog(@"      %@, class: %@", anOject, attributeClass);
            
            //create core data Category entity
            Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                                               inManagedObjectContext:managedObjectContext];
            
            //set entity's attributes:
            NSDictionary *theObject = [dictionaryOfObjects objectForKey:anOject];
            [self parseDictionary:theObject toObject:category];
            
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
    
    
    if (!jsonDictionary) {
        NSLog(@"Error parsing JSON: %@", err);
    }
    else {
        
        //get the list of objects
        NSDictionary *dictionaryOfObjects = [jsonDictionary objectForKey:@"list"];
        for (NSString *anOject in dictionaryOfObjects) {
            
            //create core data City entity
            Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"DiscountObject"
                                                               inManagedObjectContext:managedObjectContext];
            
            //put object into core data
            NSDictionary *theObject = [dictionaryOfObjects objectForKey:anOject];
            [self parseDictionary:theObject toObject:category];
            
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
