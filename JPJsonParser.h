//
//  JPJsonParser.h
//  SoftServeDP
//
//  Created by Maxim on 11/01/13.
//  Copyright (c) 2013 Maxim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSURLConnection.h>
@class CDDiscountObject;

@interface JPJsonParser : NSObject

@property (nonatomic, strong) id parsedData;
@property (nonatomic) BOOL updatedDataBase;
@property (nonatomic, strong) NSNumber *status;

- (id)initWithUrl:(NSString *)url;

+ (NSString *)getUrlWithObjectName:(NSString *)objectName;
+ (NSString *)getUrlWithObjectName:(NSString *)objectName WithFormat:(NSString *)format;

+(id)getUserIDFromFacebook;
+(BOOL)toggleUserFavoriteObject:(CDDiscountObject*)discountObject;


@end