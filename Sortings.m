//
//  Sortings.m
//  SoftServe Discount
//
//  Created by agavrish on 05.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "Sortings.h"
#import "CDDiscountObject.h"

@implementation Sortings


+(NSArray *)sortDiscountObjectByName: (NSArray *)array
{
    NSMutableArray *mutableArray = [array mutableCopy];
    NSMutableCharacterSet *trimChars = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [trimChars addCharactersInString:@"\"\'"];
    [mutableArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CDDiscountObject *d1 = obj1;
        CDDiscountObject *d2 = obj2;
        NSString *trimmedName1 = [d1.name stringByTrimmingCharactersInSet:trimChars];
        NSString *trimmedName2 = [d2.name stringByTrimmingCharactersInSet:trimChars];
        return [trimmedName1 compare:trimmedName2];
    }];
    return mutableArray;
}

+(NSArray *)sortDiscountObjectByDistance: (NSArray *)array toLocation: (CLLocation *)location {
    NSMutableArray *mutableArray = [array mutableCopy];
    NSArray *OrderedObjectsByDistance = [mutableArray sortedArrayUsingComparator:^(id a,id b) {
        CDDiscountObject *objectA = (CDDiscountObject *)a;
        CDDiscountObject *objectB = (CDDiscountObject *)b;
        
        CGFloat aLatitude = [[objectA.geoPoint valueForKey:@"latitude"] floatValue];
        CGFloat aLongitude = [[objectA.geoPoint valueForKey:@"longitude"] floatValue];
        CLLocation *objectALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
        
        CGFloat bLatitude = [[objectB.geoPoint valueForKey:@"latitude"] floatValue];
        CGFloat bLongitude = [[objectB.geoPoint valueForKey:@"longitude"] floatValue];
        CLLocation *objectBLocation = [[CLLocation alloc] initWithLatitude:bLatitude longitude:bLongitude];
        
        CLLocationDistance distanceA = [objectALocation distanceFromLocation:location];
        CLLocationDistance distanceB = [objectBLocation distanceFromLocation:location];
        if (distanceA < distanceB) {
            return NSOrderedAscending;
        } else if (distanceA > distanceB) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    return OrderedObjectsByDistance;
}

@end
