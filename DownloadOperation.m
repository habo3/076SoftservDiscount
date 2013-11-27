//
//  DownloadOperation.m
//  SoftServe Discount
//
//  Created by agavrish on 26.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "DownloadOperation.h"

@interface DownloadOperation ()

@property (nonatomic, strong) void(^completion)();
@end

@implementation DownloadOperation

@synthesize downloader = _downloader;
@synthesize completion = _completion;

-(void) performOperationWithURL:(NSString *)url completion:(void(^)())completion;
{
    self.downloader = [[JPJsonParser alloc] init];
    self.completion = completion;
    [self.downloader downloadDataBaseWithUrl:url withDelegate:self];
}

-(void) JPJsonParserDidFinish:(id<JPJsonParserDelegate>)sender
{
        self.completion();
}

@end
