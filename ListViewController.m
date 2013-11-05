//
//  ViewController.m
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//


#import "ListViewController.h"
#import "PlaceCell.h"
#import "DetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "IconConverter.h"
#import "AppDelegate.h"
#import "CDCoreDataManager.h"
#import "CDDiscountObject.h"
#import "CDCategory.h"
#import <UIKit/UIKit.h>
#import "ActionSheetStringPicker.h"
#import "Sortings.h"

@interface ListViewController ()

@property (nonatomic) UIButton *filterButton;
@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL geoLocationIsON;
@property (nonatomic) NSInteger selectedIndex;

@end

@implementation ListViewController
@synthesize filterButton;
@synthesize selectedRow;
@synthesize currentLocation;
@synthesize geoLocationIsON;
@synthesize discountObjects = _discountObjects;
@synthesize coreDataManager = _coreDataManager;
@synthesize selectedIndex = _selectedIndex;


#pragma mark - General

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationTitle];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.delegate = self;
    _discountObjects = [self.coreDataManager discountObjectsFromCoreData];
    [self initFilterButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    //Sending event to analytics service
    [Flurry logEvent:@"ListViewLoaded"];
    
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
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:filterButton];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [filterButton removeFromSuperview];
}

#pragma mark - CoreData

-(CDCoreDataManager *)coreDataManager
{
    return [(AppDelegate*) [[UIApplication sharedApplication] delegate] coreDataManager];
}

- (NSArray*)getAllObjects
{
    return [self.coreDataManager discountObjectsFromCoreData];
}

- (NSSet *)getObjectsByCategory:(NSInteger)filterNumber
{
    NSArray *categories = [self.coreDataManager categoriesFromCoreData];
    return [[categories objectAtIndex:filterNumber] valueForKey:@"discountObjects"];
}

#pragma mark - customizing view

-(void) setNavigationTitle
{
    UILabel *navigationTitle = [[UILabel alloc] init];
    navigationTitle.backgroundColor = [UIColor clearColor];
    navigationTitle.font = [UIFont boldSystemFontOfSize:20.0];
    navigationTitle.textColor = [UIColor blackColor];
    self.navigationItem.titleView = navigationTitle;
    navigationTitle.text = self.navigationItem.title;
    [navigationTitle sizeToFit];
}

#pragma mark - filter

- (void) initFilterButton
{
    UIImage *filterButtonImage = [UIImage imageNamed:@"filterButton.png"];
    CGRect filterFrame = CGRectMake(self.navigationController.navigationBar.frame.size.width - filterButtonImage.size.width-5 , self.navigationController.navigationBar.frame.size.height- filterButtonImage.size.height-8, filterButtonImage.size.width,filterButtonImage.size.height );
    
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    filterButton.frame = filterFrame;
    [filterButton setBackgroundImage:filterButtonImage forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    filterButton.backgroundColor = [UIColor clearColor];
}

-(void) filterButtonClicked:(UIControl *)sender{
    NSArray *categories = [self.coreDataManager categoriesFromCoreData];
    NSString *categoryNameWithDetails = [NSString stringWithFormat:@"%@ \t % i",@"Усі категорії", [self getAllObjects].count];
    NSMutableArray *names = [[NSMutableArray alloc] initWithObjects:categoryNameWithDetails, nil];
    for (CDCategory *category in categories) {
        categoryNameWithDetails = [NSString stringWithFormat:@"%@ \t % i",category.name, [[category valueForKey:@"discountObjects"] allObjects].count];
        [names addObject:categoryNameWithDetails];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"" rows:names initialSelection:self.selectedIndex target:self successAction:@selector(categoryWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    
    
    /* Example ActionSheetPicker using customButtons
     self.actionSheetPicker = [[ActionSheetPicker alloc] initWithTitle@"Select Animal" rows:self.animals initialSelection:self.selectedIndex target:self successAction:@selector(itemWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender
     
     [self.actionSheetPicker addCustomButtonWithTitle:@"Special" value:[NSNumber numberWithInt:1]];
     self.actionSheetPicker.hideCancel = YES;
     [self.actionSheetPicker showActionSheetPicker];
     */
}

- (void)categoryWasSelected:(NSNumber *)selectedIndex element:(id)element {
    if(self.selectedIndex != [selectedIndex integerValue])
    {
        self.selectedIndex = [selectedIndex integerValue];
        if(self.selectedIndex == 0)
            self.discountObjects = [self getAllObjects];
        else
            self.discountObjects = [[self getObjectsByCategory:self.selectedIndex - 1] allObjects];
        [self.tableView reloadData];
    }
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
    [self performSegueWithIdentifier:@"detailsList" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifer = @"Cell";

    CDDiscountObject * object = [self.discountObjects objectAtIndex:indexPath.row];
    PlaceCell *cell = [[PlaceCell alloc] initPlaceCellWithTable:tableView withIdentifer:cellIdentifer];
    return [cell customCellFromDiscountObject:object WithTableView:tableView WithCurrentLocation:self.currentLocation];
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [locationManager stopUpdatingLocation];
    self.currentLocation = newLocation;
    [self reloadTableWithDistancesValues];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [locationManager stopUpdatingLocation];
    self.currentLocation = [locations objectAtIndex:0];
    [self reloadTableWithDistancesValues];
}

#pragma mark - seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailsViewController *dvc = [segue destinationViewController];
    dvc.discountObject = [self.discountObjects objectAtIndex:selectedRow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
@end