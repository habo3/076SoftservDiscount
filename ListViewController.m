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

#define CELL_HEIGHT 80.0

@interface ListViewController ()
//<UIPickerViewDataSource , UIPickerViewDelegate>

@property (nonatomic) UIButton *filterButton;
//@property (nonatomic,strong) UIPickerView * filterPicker;
@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL geoLocationIsON;
@end

@implementation ListViewController
@synthesize filterButton;
@synthesize selectedRow;
@synthesize currentLocation;
@synthesize geoLocationIsON;
@synthesize discountObjects = _discountObjects;
@synthesize coreDataManager = _coreDataManager;
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
        [self reloadTableWithDistancesValues];
        [locationManager startUpdatingLocation];
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

-(void) filterCategory:(UIControl *)sender
{
//    _filterPicker.hidden = false;
}

- (NSArray*)getAllObjects
{
    return [self.coreDataManager discountObjectsFromCoreData];
}

- (NSArray*)getObjectsByCategory:(NSInteger)filterNumber
{
    NSArray *categories = [self.coreDataManager categoriesFromCoreData];
    for (CDCategory *category in categories) {
        if ([[category valueForKey:@"id"] integerValue] == filterNumber  ) {
            return [category valueForKey:@"discountObjects"];
        }
    }
    return nil;
}

// Just test
//- (NSInteger)numberOfComponentsInPickerView:
//(UIPickerView *)pickerView
//{
//    return 1;
//}
//- (NSInteger)pickerView:(UIPickerView *)pickerView
//numberOfRowsInComponent:(NSInteger)component
//{
//    return 5;
//}
//- (NSString *)pickerView:(UIPickerView *)pickerView
//             titleForRow:(NSInteger)row
//            forComponent:(NSInteger)component
//{
//    return @"dsdsd";
//}
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    
//    
//}

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
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    // Init style of rrectangleView and circleView
    [cell initViews];
    //here forms search object
    CDDiscountObject * object = [self.discountObjects objectAtIndex:indexPath.row];
 
    cell.nameLabel.text = object.name ;
    cell.addressLabel.text = object.address;
    
    if(geoLocationIsON)
    {
            CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:[[object.geoPoint valueForKey:@"latitude" ] doubleValue]
                                                                    longitude:[[object.geoPoint valueForKey:@"longitude" ]  doubleValue]];

            double distance = [self.currentLocation distanceFromLocation:objectLocation];
            if (distance > 999){
                cell.distanceLabel.text = [NSString stringWithFormat:@"%.0fкм", distance/1000];
            }
            else {
                cell.distanceLabel.text = [NSString stringWithFormat:@"%dм",(int)distance];
            }
    }
    else
    {
        cell.detailsDistanceBackground.hidden = YES;
        cell.distanceLabel.hidden = YES;
    }
    CDCategory *dbCategory = [object.categorys anyObject];
    NSString *symbol = dbCategory.fontSymbol;
    NSString *tmpText = [IconConverter ConvertIconText:symbol];
    UIFont *font = [UIFont fontWithName:@"icons" size:20];
    cell.iconLabel.textColor = [UIColor colorWithRed: 1 green: 0.733 blue: 0.20 alpha: 1];
    cell.iconLabel.font = font;
    cell.iconLabel.text = tmpText;
    cell.iconLabel.textAlignment = UITextAlignmentCenter;   
    return cell;
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