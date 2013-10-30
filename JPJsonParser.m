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

@end
