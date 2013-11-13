//
//  Sortings.h
//  SoftServe Discount
//
//  Created by agavrish on 05.11.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Sortings : NSObject

+(NSArray *)sortDiscountObjectByDistance: (NSArray *)array toLocation: (CLLocation *)location;
+(NSArray *)sortDiscountObjectByName: (NSArray *)array;

@end
