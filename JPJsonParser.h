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

@protocol JPJsonParserDelegate;

@interface JPJsonParser : NSObject
@property (nonatomic, strong) id <JPJsonParserDelegate> delegate;
@property (nonatomic, strong) id parsedData;
@property (nonatomic) BOOL updatedDataBase;

- (void) downloadDataBaseWithUrl:(NSString*)url withDelegate:(id<JPJsonParserDelegate>)delegate;

+ (NSString *)getUrlWithObjectName:(NSString *)objectName;
+ (NSString *)getUrlWithObjectName:(NSString *)objectName WithFormat:(NSString *)format;

- (id)initWithUrl:(NSString *)url;

+(id)getUserIDFromFacebook;
+(BOOL)toggleUserFavoriteObject:(CDDiscountObject*)discountObject;

@end

@protocol JPJsonParserDelegate <NSObject>

-(void) JPJsonParserDidFinish:(id<JPJsonParserDelegate>) sender;

@end