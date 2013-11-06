//
//  FavoritesViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 23.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
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

@interface FavoritesViewController ()

@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL geoLocationIsON;
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
    PlaceCell *cell = [[PlaceCell alloc] initPlaceCellWithTable:tableView withIdentifer:cellIdentifer];
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

@end