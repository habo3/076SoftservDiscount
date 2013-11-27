//
//  DownloadOperation.m
//  SoftServe Discount
//
//  Created by agavrish on 26.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "DownloadOperation.h"

@interface DownloadOperation () {
    BOOL isCompleted;
    NSString *url;
}

@property (nonatomic, strong) void(^completion)();

@end

@implementation DownloadOperation

@synthesize downloader = _downloader;
@synthesize completion = _completion;

-(void) performOperationWithURL:(NSString *)aUrl completion:(void(^)())completion;
{
    self.downloader = [[JPJsonParser alloc] init];
    self.completion = completion;
    url = aUrl;
}

-(void) JPJsonParserDidFinish:(id<JPJsonParserDelegate>)sender
{
    isCompleted = YES;
    NSLog(@"url %@ downloaded", [url description]);
}

- (void)main {
    [self.downloader downloadDataBaseWithUrl:url withDelegate:self];
    while( !isCompleted) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    self.completion();
}

@end
