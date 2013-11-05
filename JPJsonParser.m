//
//  JPJsonParser.m
//  SoftServeDP
//
//  Created by Maxim on 11/01/13.
//  Copyright (c) 2013 Maxim. All rights reserved.
//

#import "JPJsonParser.h"

@interface JPJsonParser ()

@property (nonatomic, strong) NSMutableData *responseData;

- (void)downloadDataBase:(NSString *)url;
- (void)parseDownloadedData;

@end

@implementation JPJsonParser

- (id)initWithUrl:(NSString*)url
{
    self = [super init];
    if (self) {
        [self downloadDataBase:url];
    }
    return self;
}

- (void)downloadDataBase:(NSString *)url
{
    self.updatedDataBase = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection)
        NSLog(@"Downloading Data Base object");
    else
        NSLog(@"Error downloading Data Base object");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Responce. Expected len: %@", [NSNumber numberWithLongLong: [response expectedContentLength]]);
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self parseDownloadedData];
}

- (void)parseDownloadedData
{
    NSError *error;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
    self.parsedData = [json objectForKey:@"list"];
    NSArray *arr = self.parsedData;
    self.updatedDataBase = YES;
    NSLog(@"Parsed items: %@", [NSNumber numberWithUnsignedInt:[arr count]]);
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
