//
//  PhoneFormatter.m
//  SoftServe Discount
//
//  Created by Maxim on 19.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "PhoneFormatter.h"

@interface PhoneFormatter ()

@end

@implementation PhoneFormatter

+ (NSString *)numberForCall:(NSString *)phoneNumber withCity:(NSString *)city
{
    NSString *clearNumber = [self removeAllCharactersFromNumber:phoneNumber];
    NSString *cityNumber = [self cityNumberFromHardcodeVersionOfCityList:city];
    if(cityNumber == nil || [clearNumber hasPrefix:@"+380"] || [clearNumber hasPrefix:cityNumber])
            return clearNumber;
    else
    {
        if(clearNumber.length == 10)
            return [@"+38" stringByAppendingString:clearNumber];
        NSString *newNumber = [cityNumber stringByAppendingString:clearNumber];
        return newNumber;
    }

}

+ (NSString *)numberForView:(NSString *)phoneNumber withCity:(NSString *)city
{
    NSString *callString = [self numberForCall:phoneNumber withCity:city];
    switch (callString.length) {
        case 10:
             return [NSString stringWithFormat:@"(%@) %@-%@-%@",
                     [callString substringToIndex:3],
                     [callString substringWithRange:NSMakeRange(3, 3)],
                     [callString substringWithRange:NSMakeRange(6, 2)],
                     [callString substringWithRange:NSMakeRange(8, 2)]];
        case 13:
            return [NSString stringWithFormat:@"%@ (%@) %@-%@-%@",
                    [callString substringToIndex:3],
                    [callString substringWithRange:NSMakeRange(3, 3)],
                    [callString substringWithRange:NSMakeRange(6, 3)],
                    [callString substringWithRange:NSMakeRange(9, 2)],
                    [callString substringWithRange:NSMakeRange(11, 2)]];            
        default:
            return callString;
    }
}


+(NSString *)removeAllCharactersFromNumber:(NSString *)number
{
    NSScanner *scanner = [NSScanner scannerWithString:number];
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:number.length];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"+0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    
    return  strippedString;
}
+(NSString *)cityNumberFromHardcodeVersionOfCityList:(NSString *)cityName
{
    if([cityName isEqualToString:@"Івано-Франківськ"])
        return @"034";
    if([cityName isEqualToString:@"Дніпропетровськ"])
        return @"056";
    if([cityName isEqualToString:@"Донецьк"])
        return @"062";
    if([cityName isEqualToString:@"Київ"])
        return @"044";
    if([cityName isEqualToString:@"Кривий Ріг"])
        return @"056";
    if([cityName isEqualToString:@"Львів"])
        return @"032";
    if([cityName isEqualToString:@"Мукачеве"])
        return @"031";
    if([cityName isEqualToString:@"Одеса"])
        return @"048";
    if([cityName isEqualToString:@"Полтава"])
        return @"053";
    if([cityName isEqualToString:@"Рівне"])
        return @"036";
    if([cityName isEqualToString:@"Севастополь"])
        return @"069";
    if([cityName isEqualToString:@"Ужгород"])
        return @"031";
    if([cityName isEqualToString:@"Харків"])
        return @"057";
    if([cityName isEqualToString:@"Чернівці"])
        return @"037";
    return nil;
}

@end
