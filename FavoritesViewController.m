//
//  FavoritesViewController.m
//  SoftServeDP
//
//  Created by Andrew Gavrish on 23.02.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//


#import "FavoritesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DetailsViewController.h"
#import "AppDelegate.h"
#import "PlaceCell.h"
#import "CDDiscountObject.h"
#import "CDFavorites.h"
#import "CDCoreDataManager.h"
#import "Sortings.h"
#import "CustomViewMaker.h"
#import "JPJsonParser.h"
#import "NSOperationQueue+SharedQueue.h"

@interface FavoritesViewController ()

@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL geoLocationIsON;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation FavoritesViewController

@synthesize currentLocation;
@synthesize geoLocationIsON;
@synthesize selectedRow;

@synthesize discountObjects = _discountObjects;
@synthesize coreDataManager = _coreDataManager;

#pragma mark - General

-(void)viewDidLoad
{
    [CustomViewMaker customNavigationBarForView:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Sending event to analytics service
    [Flurry logEvent:@"FavoritesViewLoaded"];
    
    self.discountObjects = [[self.coreDataManager discountObjectsFromFavorites] copy];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"] boolValue]&&[CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied);
    if(geoLocationIsON)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.distanceFilter = 10;
        [locationManager startUpdatingLocation];
        [self reloadTableWithDistancesValues];
    }
    else
    {
        self.discountObjects = [Sortings sortDiscountObjectByName:self.discountObjects];
        [self.tableView reloadData];
    }
    if (!self.discountObjects.count)
        self.tableView.backgroundView = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"noFavorites"]];
    [self.tableView reloadData];
    
    ////////////////////////////
    if ([[FBSession activeSession] accessToken] && ([self isTimeToUpdate] || ![self.discountObjects count]) ) {
        [self putActivity];
        
        NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
            [self downloadFavorites];
            
            NSDate *currentDate = [[NSDate alloc] init];
            int lastUpdate = [currentDate timeIntervalSince1970];
            [userDefaults setValue:[NSNumber numberWithInt:lastUpdate] forKey:@"favoritesLastUpdate"];
            NSLog(@"%@",[userDefaults valueForKey:@"favoritesLastUpdate"]);
        }];
        [[NSOperationQueue sharedOperationQueue] addOperation:blockOperation1];
        NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.spinner.hidden = YES;
                [self.spinner removeFromSuperview];
                self.discountObjects = [self.coreDataManager discountObjectsFromFavorites];
                if (self.discountObjects.count)
                    self.tableView.backgroundView = nil;
                [self.tableView reloadData];
            });
            
            [userDefaults setValue:@YES forKey:@"isFavoritesDownloaded"];
        }];
        [blockOperation2 addDependency:blockOperation1];
        
        [[NSOperationQueue sharedOperationQueue] addOperation:blockOperation2];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - CoreData

-(CDCoreDataManager *)coreDataManager
{
    return [CDCoreDataManager sharedInstance];
}

#pragma mark - tableView

- (void) reloadTableWithDistancesValues
{
    self.discountObjects = [Sortings sortDiscountObjectByDistance:self.discountObjects toLocation:currentLocation];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.discountObjects count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"detailsFavorites" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifer = @"Cell";
    CDDiscountObject * object = [self.discountObjects objectAtIndex:indexPath.row];
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }

    return [cell customCellFromDiscountObject:object WithTableView:tableView WithCurrentLocation:self.currentLocation];
}


#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {

    [locationManager stopUpdatingLocation];
    self.currentLocation = newLocation;
    [self reloadTableWithDistancesValues];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [locationManager stopUpdatingLocation];
    self.currentLocation = [locations objectAtIndex:0];
    [self reloadTableWithDistancesValues];
}


#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailsViewController *dvc = [segue destinationViewController];
    dvc.discountObject = [self.discountObjects objectAtIndex:selectedRow];
}

#pragma mark - Favorites Update
-(BOOL)isTimeToUpdate
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *currentDate = [[NSDate alloc] init];
    int lastUpdate = [currentDate timeIntervalSince1970];
    
    if (  (lastUpdate - [[userDefaults valueForKey:@"favoritesLastUpdate"] integerValue]) >= 600 ) {
        return YES;
    }
    return NO;
}

-(void)downloadFavorites
{
    
    BOOL downloadedDataBase = NO;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    JPJsonParser *favoriteObjects;
    favoriteObjects = [[JPJsonParser alloc] initWithUrl:[NSString stringWithFormat:@"http://softserve.ua/discount/api/v1/user/favorites/b1d6f099e1b5913e86f0a9bb9fbc10e5?id=%@",[JPJsonParser getUserIDFromFacebook]]];
    if (favoriteObjects.updatedDataBase)
        downloadedDataBase = YES;
    
    while (!downloadedDataBase) {
        [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        if (favoriteObjects.updatedDataBase)
            downloadedDataBase = YES;
    }
    
    if ([[favoriteObjects parsedData] count]) {
        [self.coreDataManager deleteAllFavorites];
        [self.coreDataManager addDiscountObjectToFavoritesWithDictionaryObjects:[favoriteObjects parsedData]];
    }
    
}

-(void)putActivity
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner setFrame:CGRectMake((self.view.frame.size.width/2)-(self.spinner.frame.size.width/2), (self.view.frame.size.height/2)-(self.spinner.frame.size.height/2), self.spinner.frame.size.width, self.spinner.frame.size.height)];
    [self.spinner startAnimating];
    
    [self.view addSubview:self.spinner];
    
}



@end