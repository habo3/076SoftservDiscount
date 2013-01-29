// merge test
//  SettingsViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 28.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize managedObjectContext;

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
