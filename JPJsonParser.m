//
//  JPJsonParser.m
//  SoftServeDiscountSimpleList
//
//  Created by Victor on 10/19/13.
//  Copyright (c) 2013 Victor. All rights reserved.
//

#import "JPJsonParser.h"

@implementation JPJsonParser

@synthesize arrayObjects = _arrayObjects;
@synthesize dictionaryObjects = _dictionaryObjects;

-(id)initArrayWithUrl:(NSString*)url
{
    self = [super init];
    if (self)
    {
        _arrayObjects = [self parseDictionaryFromUrl:url];
    }
    return self;
}

-(id)initDictionaryWithUrl:(NSString*)url
{
    self = [super init];
    if (self)
    {
        _dictionaryObjects = [self parseDictionaryFromUrl:url];
    }
    return self;
}

-(id)parseDictionaryFromUrl:(NSString*)myUrl
{
    NSURL *url = [NSURL URLWithString:myUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return [json objectForKey:@"list"];
}

+ (NSString *)getUrlWithObjectName:(NSString *)objectName
{
    return [[self class] getUrlWithObjectName:objectName WithFormat:@""];
}

+ (NSString *)getUrlWithObjectName:(NSString *)objectName WithFormat:(NSString*)format
{
    NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    NSString *apiKey = [NSString stringWithString:[dictRoot objectForKey:@"APIKey"]];
    NSString *url = @"http://softserve.ua/discount/api/v1/";
    return [NSString stringWithFormat: @"%@%@%@%@%@", url, objectName, @"/list/", apiKey, format];
}


@end
