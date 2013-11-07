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
@property (nonatomic, strong) NSNumber* downloadSize;

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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        self.status = @"Connecting to server";
        NSLog(@"Downloading Data Base object");
    } else {
        self.status = @"Error: connecting to server";
        NSLog(@"Error downloading Data Base object");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.downloadSize = [NSNumber numberWithLongLong: [response expectedContentLength]];
    NSLog(@"Responce. Expected len: %@", self.downloadSize);
    self.status = [NSString stringWithFormat: @"Responce. Expected len: %@ bytes", self.downloadSize];
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];    
    self.status = [NSString stringWithFormat: @"Downloaded: %.1f %%", self.responseData.length * 100. / self.downloadSize.intValue];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Connection problems"
                                message:error.localizedDescription
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:nil] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *currentDate = [[NSDate alloc] init];
    int lastUpdate = [currentDate timeIntervalSince1970];
    [userDefaults setValue:[NSNumber numberWithInt:lastUpdate] forKey:@"DataBaseUpdate"];
    [self parseDownloadedData];
}

- (void)parseDownloadedData
{
    self.status = @"Parsing";
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
    NSString *url = [NSString stringWithFormat:@"%@%@", [dictRoot objectForKey:@"WebSite"], @"/discount/api/v1/"];
    NSString *apiKey = [NSString stringWithString:[dictRoot objectForKey:@"APIKey"]];
    return [NSString stringWithFormat: @"%@%@%@%@%@", url, objectName, @"/list/", apiKey, format];
}


@end
