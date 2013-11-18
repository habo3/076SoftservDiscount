//
//  LoadScreenViewController.m
//  SoftServe Discount
//
//  Created by Maxim on 3.11.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import "LoadScreenViewController.h"
#import "JPJsonParser.h"
#import "AppDelegate.h"
#import "CDCoreDataManager.h"
#import "CDCity.h"
#import "ActionSheetStringPicker.h"
#import "KxIntroView.h"
#import "KxIntroViewController.h"
#import "KxIntroViewPage.h"

@interface LoadScreenViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) NSMutableArray *citiesNames;
@property (nonatomic) BOOL downloadStarted;

@end

@implementation LoadScreenViewController

@synthesize citiesNames = _citiesNames;

-(NSManagedObjectContext *)managedObjectContex
{
    return [(AppDelegate*) [[UIApplication sharedApplication] delegate] managedObjectContext];
}

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
    self.citiesNames = [[NSMutableArray alloc] init];
    self.progressView.progress = 0.0;
    self.downloadStarted = NO;
}

- (void)downloadDataBaseWithUpdateTime:(int)lastUpdate
{
    BOOL downloadedDataBase = NO;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    JPJsonParser *objects, *cities, *categories;
    JPJsonParser *favoriteObjects;
    
    objects = [[JPJsonParser alloc] initWithUrl:[JPJsonParser getUrlWithObjectName:@"object" WithFormat:[NSString stringWithFormat:@"?changed=%d", lastUpdate]]];
    cities = [[JPJsonParser alloc] initWithUrl:[JPJsonParser getUrlWithObjectName:@"city" WithFormat:[NSString stringWithFormat:@"?changed=%d", lastUpdate]]];
    categories = [[JPJsonParser alloc] initWithUrl:[JPJsonParser getUrlWithObjectName:@"category" WithFormat:[NSString stringWithFormat:@"?changed=%d", lastUpdate]]];
    
    favoriteObjects = [[JPJsonParser alloc] initWithUrl:[NSString stringWithFormat:@"http://softserve.ua/discount/api/v1/user/favorites/b1d6f099e1b5913e86f0a9bb9fbc10e5?id=%@",[JPJsonParser getUserIDFromFacebook]]];
    
    while (!downloadedDataBase) {
          self.progressView.progress = ([objects.status doubleValue] + [cities.status doubleValue] + [categories.status doubleValue]) / 220;
        [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        if (objects.updatedDataBase && cities.updatedDataBase && categories.updatedDataBase && favoriteObjects.updatedDataBase)
            downloadedDataBase = YES;
    }
    NSLog(@"%@",favoriteObjects.parsedData);
//    for (NSString *key in [favoriteObjects.parsedData allKeys]) {
//        NSLog(@"favorite object ID: %@",key);
//    }
    if (!lastUpdate) {
        [self.coreDataManager deleteAllCoreData];
    }
    
    if ([[categories parsedData] count]) {
        self.coreDataManager.categories = categories.parsedData;
        [self.coreDataManager saveCategoriesToCoreData];
    }
    if ([[cities parsedData] count]) {
        self.coreDataManager.cities = cities.parsedData;
        [self.coreDataManager saveCitiesToCoreData];
    }
    if ([[objects parsedData] count]) {
        self.coreDataManager.discountObject = objects.parsedData;
        [self.coreDataManager saveDiscountObjectsToCoreData];
    }
    if ([[favoriteObjects parsedData] count]) {
        [self.coreDataManager addDiscountObjectToFavoritesWithDictionaryObjects:[favoriteObjects parsedData]];
    }    
    NSLog(@"AppDelegate items: %@", [NSNumber numberWithUnsignedInt:self.coreDataManager.discountObject.count]);
}

-(BOOL)internetAvailable
{
    NSString *url = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.yandex.com"] encoding:NSUTF8StringEncoding error:nil];
    return (url != NULL) ? YES : NO;
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
    
    if([[userDefaults objectForKey:@"firstLaunch"]boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Перший запуск"
                                                        message:@"Програма була запущена вперше. Для зручності використання необхідно вибрати місто, яке буде використовуватися за замовчуванням."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Вибрати місто", nil];
        [alert show];
    }
    else
        [self performSegueWithIdentifier:@"Menu" sender:self];
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
    [userDefaults removeObjectForKey:@"firstLaunch"];
    [self performIntro];
    [self performSegueWithIdentifier:@"Menu" sender:self];
}

-(void) performIntro
{
    KxIntroViewPage *page0 = [KxIntroViewPage introViewPageWithTitle: @"Швидке навчання"
                                                          withDetail: @"Це швидке навчання користування програмую, якщо ви бажаєте пропустити його нажміть вiдповідну кнопку. Для переходу до наступного кроку зробіть скрол вліво."
                                                           withImage: [UIImage imageNamed:@"IntrolImage.png"]];
    
    KxIntroViewPage *page1 = [KxIntroViewPage introViewPageWithTitle: @"Карта"
                                                          withDetail: @"На карті можна побачити всі заклади. які вснесені в базу, При кліці на заклад появляється коротка інформація про нього та, якщо ввімкнена Геолокація, прокладається маршрут від вашого поточного місця знаходження до даного закладу. На навігаційній панелі ви можете найти кнопку Назад та кнопку Філтрації. Також, при ввімкненій Геолокації, знизу відображається кнопка переходу до вашого місця знаходження "
                                                           withImage: [UIImage imageNamed:@"IntroImageMap.jpg"]];
    
    KxIntroViewPage *page2 = [KxIntroViewPage introViewPageWithTitle: @"Список"
                                                          withDetail: @"В списку ви можете побачити всі заклади, де надаються знижки в альтернативному вигляді. Тут присутній пошук, а також фільтрація."
                                                           withImage: [UIImage imageNamed:@"IntroImageList.jpg"]];
    
    KxIntroViewPage *page3 = [KxIntroViewPage introViewPageWithTitle: @"Деталі"
                                                          withDetail: @"Це вікно призначення для показу детальної інформації про даний заклад, Тут ви можете: побачити категорію закладу, логотип, контактну інформацію, добавити до обраного, поскаржитися, поділитися з друзями інформацією про нього. Також клік по телефону, електроній пошті, сайту відбудеться відповідна дія."
                                                           withImage: [UIImage imageNamed:@"IntroImageDetails.jpg" ]];
    
    KxIntroViewController *vc = [[KxIntroViewController alloc ] initWithPages:@[ page0, page1, page2, page3]];
    vc.introView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"IntroBackground.png"]];;
    vc.introView.animatePageChanges = YES;
    vc.introView.gradientBackground = NO;
    [vc presentInViewController:self fullScreenLayout:YES];
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
