//
//  LoadScreenViewController.m
//  SoftServe Discount
//
//  Created by agavrish on 17.10.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "LoadScreenViewController.h"

@interface LoadScreenViewController ()


@end


@implementation LoadScreenViewController

@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
