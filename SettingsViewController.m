// merge test
//  SettingsViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 28.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "SettingsViewController.h"
#import "JSONParser.h"


@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *manualUpdateButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *updateFrequencyChangedButtonOutlet;

@end

@implementation SettingsViewController

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
        self.updateFrequencyChangedButtonOutlet.enabled = NO;
        self.manualUpdateButton.enabled = YES;
        self.manualUpdateButton.alpha = 1;
    }
    else if (sender.on){
        self.updateFrequencyChangedButtonOutlet.enabled = YES;
        self.manualUpdateButton.enabled = NO;
        self.manualUpdateButton.alpha = 0.3;
    }
}


- (IBAction)updateFrequencyChanged:(UISegmentedControl *)sender {
    int i = sender.selectedSegmentIndex;
    NSLog(@"index: %d", i);
}

- (void)viewDidLoad {
    self.manualUpdateButton.enabled = NO;
    self.manualUpdateButton.alpha = 0.3;
}

- (void)viewDidUnload {
    [self setUpdateFrequencyChangedButtonOutlet:nil];
    [self setManualUpdateButton:nil];
    [super viewDidUnload];
}
@end
