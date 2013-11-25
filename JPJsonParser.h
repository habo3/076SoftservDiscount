//
//  JPJsonParser.h
//  SoftServeDP
//
//  Created by Maxim on 11/01/13.
//  Copyright (c) 2013 Maxim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSURLConnection.h>

@protocol JPJsonParserDelegate;

@interface JPJsonParser : NSOperation

@property (nonatomic, assign) id <JPJsonParserDelegate> delegate;
@property (nonatomic, strong) id parsedData;
@property (nonatomic) BOOL updatedDataBase;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSString *name;

- (id)initWithUrl:(NSString*)url withName:(NSString *)name delegate:(id <JPJsonParserDelegate>) delegate;

+ (NSString *)getUrlWithObjectName:(NSString *)objectName;
+ (NSString *)getUrlWithObjectName:(NSString *)objectName WithFormat:(NSString *)format;


@end

@protocol JPJsonParserDelegate <NSObject>

- (void)JPJsonParserDidFinishWithSuccess:(NSArray *)objects;

@end