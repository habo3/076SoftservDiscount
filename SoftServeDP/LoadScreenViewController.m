//
//  LoadScreenViewController.m
//  SoftServe Discount
//
//  Created by Maxim on 3.11.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import "LoadScreenViewController.h"
#import "AppDelegate.h"
#import "CDCoreDataManager.h"
#import "CDCity.h"
#import "ActionSheetStringPicker.h"

@interface LoadScreenViewController ()
{
    int counterOfFinishedOperations;
}

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) NSMutableArray *citiesNames;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic) BOOL downloadStarted;

@end

@implementation LoadScreenViewController

@synthesize citiesNames = _citiesNames;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.citiesNames = [[NSMutableArray alloc] init];
    self.progressView.progress = 0.1;
    counterOfFinishedOperations = 0;
    self.queue = [NSOperationQueue new];
    self.queue.maxConcurrentOperationCount = 1;
    self.downloadStarted = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (!self.downloadStarted) {
        self.downloadStarted = YES;
        int lastUpdate = [[userDefaults valueForKey:@"DataBaseUpdate"] intValue];
        if(![self.coreDataManager isCoreDataEntityExist])
        {
            [userDefaults setValue:[NSNumber numberWithInt:0] forKey:@"DataBaseUpdate"];
            lastUpdate = [[userDefaults valueForKey:@"DataBaseUpdate"] intValue];
            [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"updateData"];
            [self downloadDataBaseWithUpdateTime:lastUpdate];
        }
        else if([self internetAvailable] && [self.coreDataManager isCoreDataEntityExist] && [[userDefaults objectForKey:@"updateData"]boolValue])
        {
            [self downloadDataBaseWithUpdateTime:lastUpdate];
        }
        lastUpdate = [[userDefaults valueForKey:@"DataBaseUpdate"] intValue];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:lastUpdate];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc ]init];
        [dateFormatter setDateFormat:@"dd.MM.yy HH:mm"];
        [userDefaults setObject:[dateFormatter stringFromDate:date] forKey:@"DataBaseUpdateDateFormat"];
    }
}

- (void)downloadDataBaseWithUpdateTime:(int)lastUpdate
{
    if (!lastUpdate)
        [self.coreDataManager deleteAllCoreData];
    
    NSString *url;
    
    url = [JPJsonParser getUrlWithObjectName:@"city" WithFormat:[NSString stringWithFormat:@"?changed=%d", lastUpdate]];
    DownloadOperation *downloadCities = [[DownloadOperation alloc] init];
    [downloadCities performOperationWithURL:url completion:^{
        if([self checkDownloadedInformation: downloadCities])
        {
            self.coreDataManager.cities = downloadCities.downloader.parsedData;
            [self.coreDataManager saveCitiesToCoreData];
        }
    }];
    [self.queue addOperation:downloadCities];
    
    url = [JPJsonParser getUrlWithObjectName:@"category" WithFormat:[NSString stringWithFormat:@"?changed=%d", lastUpdate]];
    DownloadOperation *downloadCategories = [[DownloadOperation alloc] init];
    [downloadCategories performOperationWithURL:url completion:^{
        if([self checkDownloadedInformation: downloadCategories])
        {
            self.coreDataManager.categories = downloadCategories.downloader.parsedData;
            [self.coreDataManager saveCategoriesToCoreData];
            
        }
    }];
    [self.queue addOperation:downloadCategories];
    
    url = [JPJsonParser getUrlWithObjectName:@"object" WithFormat:[NSString stringWithFormat:@"?changed=%d", lastUpdate]];
    DownloadOperation *downloadObjects = [[DownloadOperation alloc] init];
    [downloadObjects performOperationWithURL:url completion:^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            if([self checkDownloadedInformation: downloadObjects])
            {
                self.coreDataManager.discountObject = downloadObjects.downloader.parsedData;
                [self.coreDataManager saveDiscountObjectsToCoreData];
            }
            [self performCityPicker];
        });

    }];
    [self.queue addOperation:downloadObjects];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:0 forKey:@"favoritesLastUpdate"];
}

- (BOOL)checkDownloadedInformation:(DownloadOperation *) downloadOperation
{
    if(downloadOperation.downloader.parsedData)
    {
        self.progressView.progress = self.progressView.progress + 0.3;
        return [downloadOperation.downloader.parsedData count]?YES:NO;        
    } else {
        [self.queue cancelAllOperations];
        return NO;
    }
}

-(void) performCityPicker
{
    self.progressView.progress = 1.0;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([[userDefaults objectForKey:@"firstLaunch"]boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Перший запуск"
                                                        message:@"Програма запущена вперше. Для зручності використання необхідно вибрати місто, яке буде використовуватися за замовчуванням."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Обрати місто", nil];
        [alert show];
    }
    else
        [self performSegueWithIdentifier:@"Menu" sender:self];
}

-(BOOL)internetAvailable
{
    NSString *url = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.yandex.com"] encoding:NSUTF8StringEncoding error:nil];
    return (url != NULL) ? YES : NO;
}

#pragma mark - Alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray *allCities = [self.coreDataManager citiesFromCoreData];
    for (CDCity *city in allCities) {
        [self.citiesNames addObject:city.name];
    }

    [ActionSheetStringPicker showPickerWithTitle:@""
                                            rows:self.citiesNames
                                initialSelection:0
                                          target:self
                                   successAction:@selector(cityWasSelected:)
                                    cancelAction:@selector(actionPickerCancelled:)
                                          origin:self.view];
}

- (void) cityWasSelected:(NSNumber *)selectedIndex{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:selectedIndex forKey:@"selectedCity"];
    [userDefaults setObject:[self.citiesNames objectAtIndex:[selectedIndex intValue] ] forKey:@"cityName"];
    [userDefaults synchronize];
    [self performSegueWithIdentifier:@"Menu" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (CDCoreDataManager *)coreDataManager
{
    return [CDCoreDataManager sharedInstance];
}


@end
