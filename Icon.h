//
//  Icon.h
//  SoftServeDP
//
//  Created by Bogdan on 29.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface Icon : NSManagedObject

@property (nonatomic, retain) NSNumber * json_id;
@property (nonatomic, retain) NSString * mime;
@property (nonatomic, retain) NSString * json_size;
@property (nonatomic, retain) NSString * json_src;
@property (nonatomic, retain) Category *category;

@end
