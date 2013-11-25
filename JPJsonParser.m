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

@synthesize delegate = _delegate;
@synthesize name = _name;

static BOOL notification = NO;

- (id)initWithUrl:(NSString*)url withName:(NSString *)name delegate:(id <JPJsonParserDelegate>) delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.name = name;
        [self downloadDataBase:url];
    }
    return self;
}


- (void)downloadDataBase:(NSString *)url
{
    self.updatedDataBase = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        NSLog(@"Downloading Data Base object");
    } else {
        NSLog(@"Error downloading Data Base object");
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(JPJsonParserDidFinishWithSuccess:) withObject:[NSArray arrayWithObjects:self,@NO,nil] waitUntilDone:NO];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.downloadSize = [NSNumber numberWithLongLong: [response expectedContentLength]];
    NSLog(@"Responce. Expected len: %@", self.downloadSize);
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
    self.status = [NSNumber numberWithDouble:self.responseData.length * 90. / self.downloadSize.intValue];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (!notification) {
        [[[UIAlertView alloc] initWithTitle:@"Connection problems"
                                    message:error.localizedDescription
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:nil] show];
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(JPJsonParserDidFinishWithSuccess:) withObject:[NSArray arrayWithObjects:self,@NO,nil] waitUntilDone:NO];

        notification = YES;
    }
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
    NSError *error;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
    self.status = [NSNumber numberWithDouble:[self.status doubleValue] + 10.];
    self.parsedData = [json objectForKey:@"list"];
    self.updatedDataBase = YES;
    NSLog(@"Parsed items: %@", [NSNumber numberWithUnsignedInt:[self.parsedData count]]);
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(JPJsonParserDidFinishWithSuccess:) withObject:[NSArray arrayWithObjects:self,@YES, nil] waitUntilDone:NO];
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
