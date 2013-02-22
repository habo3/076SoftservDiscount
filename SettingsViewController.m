// merge test
//  SettingsViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 28.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SettingsViewController.h"
#import "JSONParser.h"
#import "DetailsViewController.h"
#import "DiscountObject.h"


@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *manualUpdateButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *updateFrequencyChangedButtonOutlet;
@property (weak, nonatomic) IBOutlet UISwitch *manualUpdateSwitch;

@end

@implementation SettingsViewController
@synthesize managedObjectContext;

-(SettingsViewController *)init {
    
    return [super init];
}
-(IBAction)updateDB{
    JSONParser *parser = [[JSONParser alloc] init];
    parser.managedObjectContext = self.managedObjectContext;
    [parser updateDB];
}

-(IBAction)showCities{
   
    JSONParser *parser = [[JSONParser alloc] init];
    parser.managedObjectContext = self.managedObjectContext;
    [parser testDB];
}

- (IBAction)autoUpdateSwitch:(UISwitch *)sender {
    if (!sender.on){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSNumber numberWithInt:0] forKey:@"updatePeriod"];
        self.updateFrequencyChangedButtonOutlet.enabled = NO;
        self.manualUpdateButton.enabled = YES;
        self.manualUpdateButton.alpha = 1;
        
    }
    else if (sender.on){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSNumber numberWithInt:1] forKey:@"updatePeriod"];
        self.updateFrequencyChangedButtonOutlet.enabled = YES;
        self.manualUpdateButton.enabled = NO;
        self.manualUpdateButton.alpha = 0.3;
    }
}


- (IBAction)updateFrequencyChanged:(UISegmentedControl *)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    int i = sender.selectedSegmentIndex;
    switch (i) {
        case 0:
            [userDefaults setObject:[NSNumber numberWithInt:1] forKey:@"updatePeriod"];
            break;
        case 1:
            [userDefaults setObject:[NSNumber numberWithInt:60*60*24] forKey:@"updatePeriod"];
            break;
        case 2:
            [userDefaults setObject:[NSNumber numberWithInt:60*60*24*30] forKey:@"updatePeriod"];
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    self.manualUpdateButton.layer.cornerRadius = 10;
    self.manualUpdateButton.clipsToBounds = YES;
    [[self.manualUpdateButton layer] setBorderWidth:1.0f];
    [[self.manualUpdateButton layer] setBorderColor:[UIColor grayColor].CGColor];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *updatePeriod = [userDefaults objectForKey:@"updatePeriod"];
    int updatePeriodDouble = [updatePeriod intValue];
    switch (updatePeriodDouble) {
        case 0:
            self.manualUpdateButton.enabled = YES;
            [self.updateFrequencyChangedButtonOutlet setEnabled:NO ];
            self.manualUpdateSwitch.on = NO;
            break;
        case 1:
            self.manualUpdateButton.enabled = NO;
            self.manualUpdateButton.alpha = 0.3;
            self.updateFrequencyChangedButtonOutlet.enabled = YES;
            self.updateFrequencyChangedButtonOutlet.selectedSegmentIndex = 0;
            self.manualUpdateSwitch.on = YES;
            break;
        case 60*60*24:
            self.manualUpdateButton.enabled = NO;
            self.manualUpdateButton.alpha = 0.3;
            self.updateFrequencyChangedButtonOutlet.enabled = YES;
            self.updateFrequencyChangedButtonOutlet.selectedSegmentIndex = 1;
            self.manualUpdateSwitch.on = YES;
            break;
        case 60*60*24*30:
            self.manualUpdateButton.enabled = NO;
            self.manualUpdateButton.alpha = 0.3;
            self.updateFrequencyChangedButtonOutlet.enabled = YES;
            self.updateFrequencyChangedButtonOutlet.selectedSegmentIndex = 2;
            self.manualUpdateSwitch.on = YES;
            break;
        default:
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailsViewController *dvc = [segue destinationViewController];
    NSPredicate *findObjectWithId = [NSPredicate predicateWithFormat:@"id == %@",[NSNumber numberWithInt:112]];
    NSFetchRequest *objFetch=[[NSFetchRequest alloc] init];
    [objFetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
                                    inManagedObjectContext:self.managedObjectContext]];
    [objFetch setPredicate:findObjectWithId];
    NSArray *objectFound = [self.managedObjectContext executeFetchRequest:objFetch error:nil];
    DiscountObject *obj = [objectFound objectAtIndex:0];
    dvc.discountObject = obj;
}


- (void)viewDidUnload {
    [self setUpdateFrequencyChangedButtonOutlet:nil];
    [self setManualUpdateButton:nil];
    [self setManualUpdateSwitch:nil];
    [super viewDidUnload];
}
@end
