//
//  NSOperationQueue+SharedQueue.m
//  SoftServe Discount
//
//  Created by Victor on 21.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "NSOperationQueue+SharedQueue.h"

@implementation NSOperationQueue (SharedQueue)

+(NSOperationQueue*)sharedOperationQueue;
{
    static NSOperationQueue* sharedQueue = nil;
    if (sharedQueue == nil) {
        sharedQueue = [[NSOperationQueue alloc] init];
    }
    return sharedQueue;
}

@end
