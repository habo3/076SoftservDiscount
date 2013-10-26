//
//  JPJsonParser.h
//  SoftServeDiscountSimpleList
//
//  Created by Victor on 10/19/13.
//  Copyright (c) 2013 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPJsonParser : NSObject

@property (nonatomic, strong) NSArray *arrayObjects;
@property (nonatomic, strong) NSDictionary *dictionaryObjects;

-(id)initArrayWithUrl:(NSString*)url;
-(id)initDictionaryWithUrl:(NSString*)url;

@end
