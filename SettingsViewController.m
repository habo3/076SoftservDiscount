// merge test
//  SettingsViewController.m
//  SoftServeDP
//
//  Created by Andrew Gavrish on 28.01.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "DetailsViewController.h"
#import "DetailsViewController.h"
#import "CDCity.h"
#import "CDCoreDataManager.h"
#import "CustomViewMaker.h"
#import "ActionSheetStringPicker.h"

@interface SettingsViewController ()

//section labels
@property (weak, nonatomic) IBOutlet UILabel *geoLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateDataLabel;

// section geoLocation
@property (weak, nonatomic) IBOutlet UISwitch *geoLocationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *updateDataSwitch;

@property (nonatomic) NSArray *cities;
@property (nonatomic) NSInteger selectedUpdateIndex;
@property (nonatomic) NSInteger selectedCityIndex;
// section city
@property (weak, nonatomic) IBOutlet UILabel *selectedCityLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeCity;

// section about
@property (weak, nonatomic) IBOutlet UILabel *versionLabelText;
@property (weak, nonatomic) IBOutlet UILabel *versionLabelNumber;
@property (weak, nonatomic) IBOutlet UILabel *versionDBLabelText;
@property (weak, nonatomic) IBOutlet UILabel *versionDBLabelNumber;

@end

@implementation SettingsViewController

@synthesize geoLocationLabel,cityLabel,aboutLabel,updateDataLabel;
@synthesize cities;
@synthesize selectedCityIndex,selectedUpdateIndex;
@synthesize selectedCityLabel;
@synthesize versionLabelNumber,versionLabelText;
@synthesize versionDBLabelText,versionDBLabelNumber;

@synthesize coreDataManager = _coreDataManager;

#pragma mark - custom getters

-(CDCoreDataManager *)coreDataManager
{
    return [CDCoreDataManager sharedInstance];
}

-(SettingsViewController *)init {
    
    return [super init];
}

#pragma mark - view

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [CustomViewMaker customNavigationBarForView:self];

    
    NSArray *arrayOfCities = [self.coreDataManager citiesFromCoreData];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (CDCity *city in arrayOfCities) {
        [names addObject:city.name];
    }
    self.cities = [names copy];    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Default Lviv
    if(![userDefaults objectForKey:@"selectedCity"])
    {
        [userDefaults setObject:[NSNumber numberWithInt:4]  forKey:@"selectedCity"];
    }
    
    geoLocationLabel.text = @"Геолокація";
    updateDataLabel.text=@"Оновлення даних";
    cityLabel.text = @"Місто за замовчуванням";
    aboutLabel.text = @"Про програму";
    versionLabelText.text = @"Версія";
    versionLabelNumber.text = @"1.0";
    versionDBLabelText.text = @"Дата оновлення даних";
    versionDBLabelNumber.text = @"1.1.1";
}

-(void)viewWillAppear:(BOOL)animated
{
    //Sending event to analytics service
    [Flurry logEvent:@"SettingsViewLoaded"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"]boolValue];
    
    selectedCityIndex = [[userDefaults objectForKey:@"selectedCity"] integerValue];
    selectedCityLabel.text = [self.cities objectAtIndex:selectedCityIndex];
    selectedUpdateIndex = [[userDefaults objectForKey:@"selectedUpdate"] integerValue];

    NSDate *date = [userDefaults objectForKey:@"lastDBUpdate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc ]init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    versionDBLabelNumber.text = [dateFormatter stringFromDate:date];

    self.geoLocationSwitch.on = geoLocationIsON;
    self.updateDataSwitch.on=[[userDefaults objectForKey:@"updateData"]boolValue];

    selectedCityLabel.text = [self.cities objectAtIndex: selectedCityIndex];
}

- (void)viewDidUnload {
    
    [self setGeoLocationLabel:nil];
    [self setCityLabel:nil];
    [self setSelectedCityLabel:nil];
    [self setVersionLabelText:nil];
    [self setVersionLabelNumber:nil];
    [self setVersionDBLabelText:nil];
    [self setVersionDBLabelNumber:nil];
    [self setGeoLocationSwitch:nil];
    [self setChangeCity:nil];
    [super viewDidUnload];
}

#pragma mark - UI

- (IBAction)geoLocationSwitch:(UISwitch*)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (!sender.on){
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"geoLocation"];
    }
    else if (sender.on){
        
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"geoLocation"];
    }
    [userDefaults synchronize];
}
- (IBAction)updateDataSwitch:(UISwitch *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (!sender.on){
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"updateData"];
    }
    else if (sender.on){
        
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"updateData"];
    }
    [userDefaults synchronize];
    
}


#pragma mark - selectPicker

- (IBAction)selectCity:(id)sender {
    NSArray *allCities = [self.coreDataManager citiesFromCoreData];
    NSMutableArray *names = [NSMutableArray new] ;
    for (CDCity *city in allCities) {
        [names addObject:city.name];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"" rows:names initialSelection:self.selectedCityIndex target:self successAction:@selector(cityWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

- (void) cityWasSelected:(NSNumber *)selectIndex element:(id)element {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(selectedCityIndex != [selectIndex integerValue])
    {
        selectedCityIndex = [selectIndex integerValue];
        selectedCityLabel.text = [self.cities objectAtIndex:selectedCityIndex];
    }
    [userDefaults setObject:[NSNumber numberWithInt: selectedCityIndex] forKey:@"selectedCity"];
    [userDefaults setObject:[self.cities objectAtIndex:selectedCityIndex] forKey:@"cityName"];
    [userDefaults synchronize];
}

@end
