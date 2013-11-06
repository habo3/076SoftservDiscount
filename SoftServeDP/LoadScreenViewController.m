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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

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
    self.activityIndicator.hidden = TRUE;
}

- (void)downloadDataBaseWithUpdateTime:(int)lastUpdate
{
    BOOL downloadedDataBase = NO;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    JPJsonParser *objects, *cities, *categories;
    
    self.statusLabel.text = @"Downloading Data Base";
    objects = [[JPJsonParser alloc] initWithUrl:[JPJsonParser getUrlWithObjectName:@"object" WithFormat:[NSString stringWithFormat:@"?changed=%d", lastUpdate]]];
    cities = [[JPJsonParser alloc] initWithUrl:[JPJsonParser getUrlWithObjectName:@"city" WithFormat:[NSString stringWithFormat:@"?changed=%d", lastUpdate]]];
    categories = [[JPJsonParser alloc] initWithUrl:[JPJsonParser getUrlWithObjectName:@"category" WithFormat:[NSString stringWithFormat:@"?changed=%d", lastUpdate]]];
    
    while (!downloadedDataBase) {
        self.statusLabel.text = objects.status;
        [runLoop runUntilDate:[NSDate date]];
        if (objects.updatedDataBase && cities.updatedDataBase && categories.updatedDataBase)
            downloadedDataBase = YES;
    }
    
    if (!lastUpdate) {
        [self.coreDataManager deleteAllData];
    }
    
    if ([[categories parsedData] count]) {
        self.coreDataManager.categories = categories.parsedData;
        [self.coreDataManager saveCategoriesToCoreData];
    }
    if ([[cities parsedData] count]) {
        self.coreDataManager.cities = cities.parsedData;
        [self.coreDataManager saveCitiesToCoreData];
    }
    if ([[objects parsedData] count]) {
        self.coreDataManager.discountObject = objects.parsedData;
        [self.coreDataManager saveDiscountObjectsToCoreData];
    }
    
    NSLog(@"AppDelegate items: %@", [NSNumber numberWithUnsignedInt:self.coreDataManager.discountObject.count]);
}

-(void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.activityIndicator.hidden = FALSE;
    [self.activityIndicator startAnimating];
    if (![userDefaults objectForKey:@"DataBaseUpdate"]) {
        [userDefaults setValue:[NSNumber numberWithInt:0] forKey:@"DataBaseUpdate"];
    }
    int lastUpdate = [[userDefaults valueForKey:@"DataBaseUpdate"] intValue];
    [self downloadDataBaseWithUpdateTime:lastUpdate];
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
