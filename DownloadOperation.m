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
@synthesize coreDataManager = _coreDataManager;
@synthesize completion = _completion;

- (CDCoreDataManager *)coreDataManager
{
    return [CDCoreDataManager sharedInstance];
}

-(void) performOperationWithURL:(NSString *)url withName:(NSString *)name completion:(void(^)())completion;
{
    self.downloader = [[JPJsonParser alloc] init];
    self.completion = completion;
    [self.downloader downloadDataBaseWithUrl:url withName:name withDelegate:self];
}

-(void) JPJsonParserDidFinish:(id<JPJsonParserDelegate>)sender
{
        self.completion();
}

@end
