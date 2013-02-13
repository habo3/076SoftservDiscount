//
//  JSONParser.h
//  SoftServeDP
//
//  Created by Bogdan on 09.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONParser : NSObject
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (void)updateDBWithTimer;
- (void)updateDB;
- (void)testDB;
@end
