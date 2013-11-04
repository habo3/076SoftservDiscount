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
#define CELL_HEIGHT 80.0

@interface ListViewController ()
//<UIPickerViewDataSource , UIPickerViewDelegate>

@property (nonatomic) UIButton *filterButton;
//@property (nonatomic,strong) UIPickerView * filterPicker;
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
//@synthesize filterPicker = _filterPicker;

-(CDCoreDataManager *)coreDataManager
{
    return [(AppDelegate*) [[UIApplication sharedApplication] delegate] coreDataManager];
}

#pragma mark - View

- (void)viewDidLoad
{

//    //Trying to include filter to UiTableViewController
//    _filterPicker = [[UIPickerView alloc] init];
//    
//    _filterPicker.showsSelectionIndicator = YES;
//    _filterPicker.dataSource = self;
//    _filterPicker.delegate = self;
//    _filterPicker.frame=CGRectMake(0, 0, 200, 200);
//
//    UIActionSheet *  _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//    _actionSheet.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//
//    UIView *masterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    [masterView addSubview:_filterPicker];
//    masterView.backgroundColor = [UIColor whiteColor];
//    [_actionSheet addSubview:masterView];
//    [_actionSheet showInView:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];

    [super viewDidLoad];
    [self setNavigationTitle];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.delegate = self;
    _discountObjects = [self.coreDataManager discountObjectsFromCoreData];
    
    UIImage *filterButtonImage = [UIImage imageNamed:@"filterButton.png"];
    CGRect filterFrame = CGRectMake(self.navigationController.navigationBar.frame.size.width - filterButtonImage.size.width-5 , self.navigationController.navigationBar.frame.size.height- filterButtonImage.size.height-8, filterButtonImage.size.width,filterButtonImage.size.height );
    
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    filterButton.frame = filterFrame;
    [filterButton setBackgroundImage:filterButtonImage forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterCategory:) forControlEvents:UIControlEventTouchUpInside];
    filterButton.backgroundColor = [UIColor clearColor];
    
    
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
        //        self.objectsFound = [FavoritesViewController sortByName:objectsFound]; Sorting by name when geoLocationOFF
        [self.tableView reloadData];
    }
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:filterButton];
   

}

-(void) viewWillDisappear:(BOOL)animated
{
    [filterButton removeFromSuperview];
}


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

-(void) filterCategory:(UIControl *)sender{
    NSArray *categories = [self.coreDataManager categoriesFromCoreData];
    NSString *categoryNameWithDetails = [NSString stringWithFormat:@"%@ \t % i",@"Усі категорії", [self getAllObjects].count];
    NSMutableArray *names = [[NSMutableArray alloc] initWithObjects:categoryNameWithDetails, nil];
    for (CDCategory *category in categories) {
        categoryNameWithDetails = [NSString stringWithFormat:@"%@ \t % i",category.name, [[category valueForKey:@"discountObjects"] allObjects].count];
        [names addObject:categoryNameWithDetails];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"" rows:names initialSelection:self.selectedIndex target:self successAction:@selector(animalWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    
    
    /* Example ActionSheetPicker using customButtons
     self.actionSheetPicker = [[ActionSheetPicker alloc] initWithTitle@"Select Animal" rows:self.animals initialSelection:self.selectedIndex target:self successAction:@selector(itemWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender
     
     [self.actionSheetPicker addCustomButtonWithTitle:@"Special" value:[NSNumber numberWithInt:1]];
     self.actionSheetPicker.hideCancel = YES;
     [self.actionSheetPicker showActionSheetPicker];
     */
}

- (void)animalWasSelected:(NSNumber *)selectedIndex element:(id)element {
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

- (NSArray*)getAllObjects
{
    return [self.coreDataManager discountObjectsFromCoreData];
}

- (NSSet *)getObjectsByCategory:(NSInteger)filterNumber
{
    NSArray *categories = [self.coreDataManager categoriesFromCoreData];
    return [[categories objectAtIndex:filterNumber] valueForKey:@"discountObjects"];
}

#pragma mark - tableView

-(void) reloadTableWithDistancesValues {
    NSMutableArray *mutableArray = [_discountObjects mutableCopy];
    NSArray *OrderedObjectsByDistance = [mutableArray sortedArrayUsingComparator:^(id a,id b) {
        CDDiscountObject *objectA = (CDDiscountObject *)a;
        CDDiscountObject *objectB = (CDDiscountObject *)b;
        
        CGFloat aLatitude = [[objectA.geoPoint valueForKey:@"latitude"] floatValue];
        CGFloat aLongitude = [[objectA.geoPoint valueForKey:@"longitude"] floatValue];
        CLLocation *objectALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
        
        CGFloat bLatitude = [[objectB.geoPoint valueForKey:@"latitude"] floatValue];
        CGFloat bLongitude = [[objectB.geoPoint valueForKey:@"longitude"] floatValue];
        CLLocation *objectBLocation = [[CLLocation alloc] initWithLatitude:bLatitude longitude:bLongitude];

        CLLocationDistance distanceA = [objectALocation distanceFromLocation:currentLocation];
        CLLocationDistance distanceB = [objectBLocation distanceFromLocation:currentLocation];
        if (distanceA < distanceB) {
            return NSOrderedAscending;
        } else if (distanceA > distanceB) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    _discountObjects = OrderedObjectsByDistance;
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.discountObjects count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  CELL_HEIGHT;
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

#pragma mark - location 

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