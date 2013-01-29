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

- (int) numberOfContacts{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *lcontext = managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:lcontext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSUInteger count = [lcontext countForFetchRequest:request error:&error];
    
    if (!error){
        return count;
    }
    else
        return -1;
    
}

- (IBAction)json {
    
    

    
    NSURLResponse *resp = nil;
    NSError *err = nil;
    
    NSString *authStr = [NSString stringWithFormat:@"Basic cm9vdDpAOGNocngh"];
    NSString *url= @"http://ssdp.qubstudio.com/api/v1/object/list/b1d6f099e1b5913e86f0a9bb9fbc10e5/";
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:authStr forHTTPHeaderField:@"Authorization"];
    
    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: response options: NSJSONReadingMutableContainers error: &err];
    
    if (!jsonDictionary) {
        NSLog(@"Error parsing JSON: %@", err);
    } else {
      //  for(NSObject *item in jsonDictionary) {
      //      NSString *theName = NSStringFromClass([[jsonDictionary objectForKey:item] class]);
      //      NSLog(@" %@, class: %@", item, theName);
      //      NSLog(@"+++++++++++++++++++++++++++");
            NSArray *arrayOfObjects = [jsonDictionary objectForKey:@"list"];
            for (NSDictionary *anOject in arrayOfObjects) {
               // NSLog(@"pulse: %@", [anOject objectForKey:@"pulse"]);
                for (NSObject *attribute in anOject){
                    NSString *attributeClass = NSStringFromClass([[anOject objectForKey: attribute] class]);
                    NSLog(@"      %@, class: %@, value: %@", attribute, attributeClass, [anOject objectForKey: attribute]);
                    NSLog(@"---------------------------------");
                }
                NSLog(@"================================");
       //     }
        }
    }
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
    } else {
        NSDictionary *dictionaryOfObjects = [jsonDictionary objectForKey:@"list"];
        for (NSString *anOject in dictionaryOfObjects) {
            
            NSString *attributeClass = NSStringFromClass([anOject class]);
            NSLog(@"      %@, class: %@", anOject, attributeClass);
            
            //create core data Category entity
           // Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
            
            //set entity's attributes:
            NSDictionary *theObject = [dictionaryOfObjects objectForKey:anOject];
            for (NSString *attribute in theObject) {
                NSLog(@"att: %@", attribute);
            
            }
            //save entity
        }
    }
    NSLog(@"IS: %d", [self numberOfContacts]);
    
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
