//
//  LoadScreenViewController.m
//  SoftServe Discount
//
//  Created by Maxim on 3.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "LoadScreenViewController.h"
#import "JPJsonParser.h"
#import "AppDelegate.h"
#import "CDCoreDataManager.h"

@interface LoadScreenViewController ()

@end


@implementation LoadScreenViewController

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

-(void)viewDidAppear:(BOOL)animated
{
    BOOL downloadedDataBase = NO;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    JPJsonParser *objects, *cities, *categories;
    
    objects = [[JPJsonParser alloc] initWithUrl:[JPJsonParser getUrlWithObjectName:@"object"]];
    cities = [[JPJsonParser alloc] initWithUrl:[JPJsonParser getUrlWithObjectName:@"city"]];
    categories = [[JPJsonParser alloc] initWithUrl:[JPJsonParser getUrlWithObjectName:@"category"]];
    
    while (!downloadedDataBase) {
        [runLoop runUntilDate:[NSDate date]];
        if (objects.updatedDataBase && cities.updatedDataBase && categories.updatedDataBase)
            downloadedDataBase = YES;
    }
    
    self.coreDataManager.discountObject = objects.parsedData;
    NSLog(@"AppDelegate items: %@", [NSNumber numberWithUnsignedInt:[[(AppDelegate *)[[UIApplication sharedApplication] delegate] coreDataManager].discountObject count]]);
    
    self.coreDataManager.cities = cities.parsedData;
    self.coreDataManager.categories = categories.parsedData;
    
    [self.coreDataManager deleteAllData];
    [self.coreDataManager saveCategoriesToCoreData];
    [self.coreDataManager saveCitiesToCoreData];
    [self.coreDataManager saveDiscountObjectsToCoreData];
    [self performSegueWithIdentifier:@"Menu" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (CDCoreDataManager *)coreDataManager
{
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] coreDataManager];
}


@end
