// merge test
//  SettingsViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 28.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "DetailsViewController.h"
#import "DetailsViewController.h"
#import "CustomPicker.h"
#import "CDCity.h"
#import "CDCoreDataManager.h"
#import "CustomViewMaker.h"

@interface SettingsViewController ()

//section labels
@property (weak, nonatomic) IBOutlet UILabel *geoLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;

// section geoLocation
@property (weak, nonatomic) IBOutlet UISwitch *geoLocationSwitch;

// section update
@property (weak, nonatomic) IBOutlet UISwitch *automaticUpdateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *automaticUpdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *updatePeriodLabel;
@property (weak, nonatomic) IBOutlet UILabel *periodLabelValue;

@property (weak, nonatomic) IBOutlet UIButton *changeUpdatePeriod;
@property (nonatomic) NSArray *cities;
@property (nonatomic) NSArray *updatePeriods;
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

@synthesize geoLocationLabel,updateLabel,cityLabel,aboutLabel;
@synthesize updatePeriods,cities;
@synthesize selectedCityIndex,selectedUpdateIndex;
@synthesize periodLabelValue,changeUpdatePeriod;
@synthesize selectedCityLabel;
@synthesize versionLabelNumber,versionLabelText;
@synthesize versionDBLabelText,versionDBLabelNumber;
@synthesize automaticUpdateLabel,updatePeriodLabel;

@synthesize coreDataManager = _coreDataManager;

#pragma mark - custom getters

-(CDCoreDataManager *)coreDataManager
{
    return [(AppDelegate*) [[UIApplication sharedApplication] delegate] coreDataManager];
}

-(SettingsViewController *)init {
    
    return [super init];
}

#pragma mark - view

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [CustomViewMaker customNavigationBarForView:self];
    self.updatePeriods = [NSArray arrayWithObjects:
                          @"8 годин",
                          @"12 годин",
                          @"24 години",
                          @"48 годин",
                          @"При запуску",
                          nil];
    
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
    updateLabel.text = @"Оновлення";
    cityLabel.text = @"Місто по замовчуванню";
    aboutLabel.text = @"Про програму";
    
    automaticUpdateLabel.text = @"Автоматичне оновлення";
    updatePeriodLabel.text = @"Інтервал оновлення";
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
    BOOL automaticUpdateIsON = [[userDefaults objectForKey:@"isUpdateEnable"]boolValue];
    
    selectedCityIndex = [[userDefaults objectForKey:@"selectedCity"] integerValue];
    selectedCityLabel.text = [self.cities objectAtIndex:selectedCityIndex];
    selectedUpdateIndex = [[userDefaults objectForKey:@"selectedUpdate"] integerValue];
    periodLabelValue.text = [self.updatePeriods objectAtIndex:selectedUpdateIndex];
    
    NSDate *date = [userDefaults objectForKey:@"lastDBUpdate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc ]init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    versionDBLabelNumber.text = [dateFormatter stringFromDate:date];
    
    self.automaticUpdateSwitch.on = automaticUpdateIsON;
    self.geoLocationSwitch.on = geoLocationIsON;
    if(automaticUpdateIsON)
    {
        updatePeriodLabel.enabled = YES;
        periodLabelValue.enabled = YES;
        changeUpdatePeriod.enabled = YES;
    }
    else
    {
        updatePeriodLabel.enabled = NO;
        periodLabelValue.enabled = NO;
        changeUpdatePeriod.enabled = NO;
    }
    
    selectedCityLabel.text = [self.cities objectAtIndex: selectedCityIndex];
}

- (void)viewDidUnload {
    
    [self setGeoLocationLabel:nil];
    [self setUpdateLabel:nil];
    [self setCityLabel:nil];
    [self setSelectedCityLabel:nil];
    [self setAutomaticUpdateLabel:nil];
    [self setUpdatePeriodLabel:nil];
    [self setChangeUpdatePeriod:nil];
    [self setVersionLabelText:nil];
    [self setVersionLabelNumber:nil];
    [self setVersionDBLabelText:nil];
    [self setVersionDBLabelNumber:nil];
    [self setGeoLocationSwitch:nil];
    [self setChangeCity:nil];
    [super viewDidUnload];
}

#pragma mark - UI
- (IBAction)autoUpdateSwitch:(UISwitch *)sender {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (!sender.on){
    
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"isUpdateEnable"];
        [userDefaults setObject:[NSNumber numberWithInt:0] forKey:@"updatePeriod"];
        updatePeriodLabel.enabled = NO;
        periodLabelValue.enabled = NO;
        changeUpdatePeriod.enabled = NO;
    }
    else if (sender.on){

        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"isUpdateEnable"];
        [self periodWasSelected:[NSNumber numberWithInt:selectedUpdateIndex] element:nil];
        updatePeriodLabel.enabled = YES;
        periodLabelValue.enabled = YES;
        changeUpdatePeriod.enabled = YES;
    }
    
    [userDefaults synchronize];
}

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

#pragma mark - selectPicker

- (IBAction)selectCity:(id)sender {
    [CustomPicker showPickerWithRows:self.cities initialSelection:self.selectedCityIndex target:self successAction:@selector(cityWasSelected:element:)];
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

- (IBAction)selectUpdatePeriod:(id)sender {
    [CustomPicker showPickerWithRows:self.updatePeriods initialSelection:self.selectedUpdateIndex target:self successAction:@selector(periodWasSelected:element:)];
}

- (void)periodWasSelected:(NSNumber *)selectIndex element:(id)element {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(selectedUpdateIndex != [selectIndex integerValue])
    {
        
        selectedUpdateIndex = [selectIndex integerValue];
        switch (selectedUpdateIndex) {
            case 0:
                [userDefaults setObject:[NSNumber numberWithInt:60*60*8] forKey:@"updatePeriod"];
                break;
            case 1:
                [userDefaults setObject:[NSNumber numberWithInt:60*60*12] forKey:@"updatePeriod"];
                break;
            case 2:
                [userDefaults setObject:[NSNumber numberWithInt:60*60*24] forKey:@"updatePeriod"];
                break;
            case 3:
                [userDefaults setObject:[NSNumber numberWithInt:60*60*48] forKey:@"updatePeriod"];
                break;
            case 4:
                [userDefaults setObject:[NSNumber numberWithInt:1] forKey:@"updatePeriod"];
                break;
            default:
                break;
        }
        NSString *updatePeriod = [self.updatePeriods objectAtIndex:selectedUpdateIndex];
        periodLabelValue.text = updatePeriod;
    }
    [userDefaults setObject:[NSNumber numberWithInt:selectedUpdateIndex] forKey:@"selectedUpdate"];
    [userDefaults synchronize];
    
}


@end
