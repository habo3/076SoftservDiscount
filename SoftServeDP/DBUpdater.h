//
//  DBUpdater.h
//  SoftServeDP
//
//  Created by Bogdan on 11.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBUpdater : NSObject
-(void) updateWithOptions;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
