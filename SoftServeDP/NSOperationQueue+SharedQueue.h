//
//  NSOperationQueue+SharedQueue.h
//  SoftServe Discount
//
//  Created by Victor on 21.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (SharedQueue)

+(NSOperationQueue*)sharedOperationQueue;

@end
