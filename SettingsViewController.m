// merge test
//  SettingsViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 28.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SettingsViewController.h"
//#import "JSONParser.h"
#import "DetailsViewController.h"
#import "DiscountObject.h"
#import "DetailsViewController.h"
#import "CustomPicker.h"

@interface SettingsViewController ()
{
    IBOutlet UIScrollView *scroller;
}
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

// section about
@property (weak, nonatomic) IBOutlet UILabel *versionLabelText;
@property (weak, nonatomic) IBOutlet UILabel *versionLabelNumber;
@property (weak, nonatomic) IBOutlet UILabel *versionDBLabelText;
@property (weak, nonatomic) IBOutlet UILabel *versionDBLabelNumber;

@end

@implementation SettingsViewController

@synthesize managedObjectContext;
@synthesize geoLocationLabel,updateLabel,cityLabel,aboutLabel;
@synthesize updatePeriods,cities;
@synthesize selectedCityIndex,selectedUpdateIndex;
@synthesize periodLabelValue,changeUpdatePeriod;
@synthesize selectedCityLabel;
@synthesize versionLabelNumber,versionLabelText;
@synthesize versionDBLabelText,versionDBLabelNumber;
@synthesize automaticUpdateLabel,updatePeriodLabel;

-(SettingsViewController *)init {
    
    return [super init];
}
/*-(IBAction)updateDB{
    JSONParser *parser = [[JSONParser alloc] init];
    parser.managedObjectContext = self.managedObjectContext;
    [parser updateDB];
}

-(IBAction)showCities{
   
    JSONParser *parser = [[JSONParser alloc] init];
    parser.managedObjectContext = self.managedObjectContext;
    [parser testDB];
}*/

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
    //[userDefaults setObject:loadCoordinates forKey:@"loadCity"];
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
            /*case 5:
                [userDefaults setObject:[NSNumber numberWithInt:0] forKey:@"updatePeriod"];*/
            default:
                break;
        }
        NSString *updatePeriod = [self.updatePeriods objectAtIndex:selectedUpdateIndex];
        periodLabelValue.text = updatePeriod;
    }
    [userDefaults setObject:[NSNumber numberWithInt:selectedUpdateIndex] forKey:@"selectedUpdate"];
    [userDefaults synchronize];
    
}



#pragma mark - view

- (void)viewDidLoad {

    [scroller setScrollEnabled:YES];
    [scroller setContentSize:self.view.frame.size];
    self.updatePeriods = [NSArray arrayWithObjects:
                          @"8 годин",
                          @"12 годин",
                          @"24 години",
                          @"48 годин",
                          @"При запуску",
                          /*@"Never (Update manually)",*/
                          nil];
    self.cities = [NSArray arrayWithObjects:
                   @"Дніпропетровськ",
                   @"Івано-Франківськ",
                   @"Київ",
                   @"Луцьк",
                   @"Львів",
                   @"Одеса",
                   @"Рівне",
                   @"Сімферополь",
                   @"Чернівці",
                   nil];
    
    geoLocationLabel.text = @"Геолокація";
    updateLabel.text = @"Оновлення";
    cityLabel.text = @"Місто по замовчуванню";
    aboutLabel.text = @"Про програму";
    
    automaticUpdateLabel.text = @"Автоматичне оновлення";
    updatePeriodLabel.text = @"Інтервал оновлення";
    versionLabelText.text = @"Версія";
    versionLabelNumber.text = @"1.0";
    versionDBLabelText.text = @"Версія бази даних";
    versionDBLabelNumber.text = @"1.1.1";
    
}

-(void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"]boolValue];
    //NSInteger updatePeriod = [[userDefaults objectForKey:@"updatePeriod"] integerValue];
    BOOL automaticUpdateIsON = [[userDefaults objectForKey:@"isUpdateEnable"]boolValue];
    
    selectedCityIndex = [[userDefaults objectForKey:@"selectedCity"] integerValue];
    selectedCityLabel.text = [self.cities objectAtIndex:selectedCityIndex];
    
    selectedUpdateIndex = [[userDefaults objectForKey:@"selectedUpdate"] integerValue];
    periodLabelValue.text = [self.updatePeriods objectAtIndex:selectedUpdateIndex];
    
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
    [super viewDidUnload];
}
@end
