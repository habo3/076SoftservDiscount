//
//  DBUpdater.m
//  SoftServeDP
//
//  Created by Bogdan on 11.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "DBUpdater.h"
#import "JSONParser.h"

@implementation DBUpdater
@synthesize managedObjectContext;

-(void) updateWithOptions {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *updatePeriod = [userDefaults objectForKey:@"updatePeriod"];
    if (updatePeriod > 0) {
        int interval = [updatePeriod intValue];
        [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(runParser) userInfo:nil repeats:YES];
    }
    else if (updatePeriod == 0) {
        [self runParser];
    }
}
-(void) runParser {
    NSLog(@"starting data base update...");
    JSONParser *parser = [[JSONParser alloc] init];
    parser.managedObjectContext = self.managedObjectContext;
    [parser updateDB];
}

@end