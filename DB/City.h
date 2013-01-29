//
//  City.h
//  SoftServeDP
//
//  Created by Bogdan on 28.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Object;

@interface City : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Object *object;

@end
